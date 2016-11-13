%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear all;
clc;
%全局变量设置
global map VW RL RW map_l map_w map_length map_width R_pre_lmp R_pre_wmp objectNum big_beam small_beam deltaR;
load('simuConfig.mat');%导入雷达参数配置文件

Tb = map_length*map_width/(big_beam*big_beam)*T1; %大波束扫描完整个区域的时间
t = 0:T1:time_num*Tb; %时间轴
len = size(t,2);
VL = V_init_l*ones(1,len) + A_init_l*t;%横向目标速度时间轴
VW = V_init_w*ones(1,len) + A_init_w*t;%纵向目标速度时间轴
RL = R_init_l*ones(1,len) + (V_init_l*t + 0.5*A_init_l*t.^2);%横向目标距离时间轴
RW = R_init_w*ones(1,len) + (V_init_w*t + 0.5*A_init_w*t.^2);%纵向目标距离时间轴
%TODO:加速度可以在一定范围内浮动


%%
%智能波束方案
global outOfRange;
outOfRange = zeros(objectNum, 1);
prePath = cell(1,objectNum);
%波束相关参数
beamPos_w = 1;
beamPos_l = 1;%波束的位置
big_has_small_num = ceil(big_beam/small_beam); %大波束内包含的小波束个数
num_l = floor(map_length / big_beam); %大波束横轴扫描次数
num_w = floor(map_width / big_beam);%大波束纵轴扫描次数
track_flag = 0; %判断是否进入跟踪模式，0为不跟踪，大波束扫描模式，1为大波束跟踪，2为小波束扫描
points = []; %保存扫描模式下扫描完整个区域的点迹的一个周期的点迹，分为多行，每行分别为[横向距离 纵向距离 纵向速度]
object = cell(1, time_num);%保存每个整周期的扫描目标信息，如果一个周期内有多个目标，用多行表示，每行分别为[横向距离 纵向距离 纵向速度]
integraObject = [];%保存每个大波束扫描整个周期后综合点信息，用多行表示，每行分别为[横向距离 纵向距离 纵向速度]
isWarning = 0; %判断是否需要预警
smallScanningCount = 0; %计算小波束扫描完整个区域的次数，大于smallScanningNum时则需要重置为大波束扫描
BigBeamTrackingObject = []; %大波束跟踪窗口的目标队列
SmallPoint = [];

for i = 1:len
    updatemap(i); %实时更新map
    for index = 1:objectNum
        if outOfRange(index) == 0
            prePath{1,index} = [prePath{1,index} [R_pre_lmp(index)*map_l; R_pre_wmp(index)*map_w]]; %模拟的理论运动模型轨迹
        end
    end
    if track_flag == 0 %扫描模式
        [hasObject, objects_l, objects_w, objects_v] = BeamFindObject(beamPos_l, beamPos_w, 1);%判断当前波束是否有目标，如果有，记录下点迹
        if hasObject
            points = [points ;objects_l objects_w objects_v];
        end
        
        beamPos_l = beamPos_l + 1;%切换下一个波束，先横着扫，当扫到行尾时切换到下一行
        if beamPos_l > num_l
            beamPos_w = beamPos_w + 1; %换行
            beamPos_l = 1;%切换到行首
        end
        
        if beamPos_w > num_w
            %一个整周期扫描结束，开始后续的分析处理
            beamPos_w = 1;
            beamPos_l = 1;
            if ~isempty(points)
                pointsnum = size(points, 1); %所有点迹的个数
                %开始点迹凝聚
                [class, type] = dbscan(points, minPts, sqrt(distanceLDoor^2 + (2 * big_beam)^2 + velocityDoor^2));
                clusternum = max(class); %聚合后簇的数量
                objectCell = cell(1, clusternum);%存放各个簇的cell单元
                objectSize = zeros(1, clusternum); %保存各个簇的大概尺寸，用户后续的点迹过滤
                
                %把目标根据dbscan分类后的class变量分别分到对应的cell簇单元中
                for j = 1:pointsnum
                    if isempty(objectCell{class(j)})
                        objectCell{class(j)} = points(j,:);
                    else
                        objectCell{class(j)} = [objectCell{class(j)}; points(j,:)];
                    end
                end
                %更新每个簇的目标大概尺寸，根据平均值方法计算
                for j = 1:clusternum
                    cludisl = objectCell{j}(:,1);%取簇中的横向距离维
                    cludisw = objectCell{j}(:,2);%取簇中的纵向距离维
                    cluv = objectCell{j}(:,3);%去簇中的速度维
                    clustersize = max(clsdisw) - min(clsdisw);
                    %将整个周期的分析出来的目标信息和大小信息放入ojbect矩阵
                    %点迹过滤，将大小很小的物体滤除，将速度为正的目标剔除
                    if clustersize > 1 && cluv < 0
                        if(isempty(object{i}))
                            object{i} = [mean(cludisl) mean(cludisw) mean(cluv) clustersize];
                        else
                            object{i} = [object{i};mean(cludisl) mean(cludisw) mean(cluv) clustersize];
                        end
                    end
                end
                %得到物体数量，大小，得到整个探测区域的综合点信息
                effectiveNum = size(object{i},1); %本周期有威胁性的目标数量
                integraDisL = mean(object{i}(:,1));%整个周期内的所有目标的质心点横向距离
                integraDisW = mean(object{i}(:,2));%整个周期内的所有目标的质心点纵向距离
                integraV = mean(object{i}(:,3));%整个周期内的所有目标的质心点速度
                if effectiveNum < trackObjectNum
                    track_flag = 1; %切换到大波束跟踪模式
                    BigBeamTrackingObject = object{i};%设定需要跟踪的目标
                    %TODO: movingTrendL = zeros(1, effectiveNum);%横向移动的趋势，-1为向左，1为向右，默认为0
                    BigBeamTrackingWindow = getBigBeamTrackingWindow(BigBeamTrackingObject);%根据要跟踪的目标，确定大波束的跟踪扫描窗
                else
                    if isempty(integraObject)
                        integraObject = [integraDisL integraDisW integraV];
                    else
                        if integraDisW < integraObject(end, 2) %与上一次的纵向距离比较，如果小于则是物体在接近中
                            integraObject = [integraObject;integraDisL integraDisW integraV];%将该综合点信息加入
                            if size(integraObject,1) >= continuousCount %如果连续接近的次数达到设定的门限则预警
                                isWarning = 1;
                                fprintf('夭寿啦！异物入侵啦！\n');
                                fprintf('夭寿啦！异物入侵啦！\n');
                                fprintf('夭寿啦！异物入侵啦！\n');
                                %TODO:考虑下画图的事情
                            end
                        else
                            %物体出现远离的趋势，将之前的趋势清除，重新开始计算趋势
                            integraObject = [integraDisL integraDisW integraV];
                        end
                    end
                end
            end
        end
    else
        if track_flag == 1 %大波束跟踪模式
            %从跟踪窗序列中确定大波束扫描的位置
            if ~isempty(BigBeamTrackingWindow)               
                beamPos_l = BigBeamTrackingWindow(1, 1); %取出参考窗
                beamPos_w = BigBeamTrackingWindow(1, 2); %取出参考窗
                BigBeamTrackingWindow(1, :) = [];
                [hasObject, objects_l, objects_w, objects_v] = BeamFindObject(beamPos_l, beamPos_w, 1);%判断当前波束是否有目标，如果有，记录下点迹
                if hasObject == 1
                    track_flag = 2;
                    SmallBeamTrackingWindow = getSmallBeamScanningWindow(objects_l, objects_w);%根据要跟踪的目标，确定小波束的顺序扫描窗
                end
            else
                %一个跟踪周期扫描完，开始处理数据
                smallScanningCount = smallScanningCount + 1;
                if smallScanningCount > smallScanningNum
                    track_flag = 0; %大于规定的小波束跟踪整个周期的次数，重新用大波束全局扫描
                else
                    track_flag = 1; %继续大波束跟踪
                end
            end
        else %小波束扫描模式
            if ~isempty(SmallBeamTrackingWindow)
                beamPos_l = SmallBeamTrackingWindow(1, 1); %取出参考窗
                beamPos_w = SmallBeamTrackingWindow(1, 2); %取出参考窗
                SmallBeamTrackingWindow(1, :) = [];
                [hasObject, objects_l, objects_w, objects_v] = BeamFindObject(beamPos_l, beamPos_w, 2);%判断当前波束是否有目标，如果有，记录下点迹
            else
                %大波束内的小波束全部扫描完，切回到大波束跟踪
                track_flag = 1;
            end
        end
    end
end
%测试运动模型轨迹路径
figure
for index = 1:objectNum
    plot(prePath{1,index}(1,:),prePath{1,index}(2,:),'*');
    hold on
end

