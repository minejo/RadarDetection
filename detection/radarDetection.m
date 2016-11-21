%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all;
clear all;
clc;
%全局变量设置
global T f0 B Fs N M RCS c
global map VW RL RW map_l map_w map_length map_width R_pre_lmp R_pre_wmp objectNum big_beam small_beam deltaR points_num;
load('simuConfig.mat');%导入雷达参数配置文件
fprintf('加载参数完毕\n');
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
outOfRange = zeros(points_num, 1);
prePath = cell(1,points_num);
%波束相关参数
beamPos_w = 1;
beamPos_l = 1;%波束的位置
big_has_small_num = ceil(big_beam/small_beam); %大波束内包含的小波束个数
num_l = floor(map_length / big_beam); %大波束横轴扫描次数
num_w = floor(map_width / big_beam);%大波束纵轴扫描次数
track_flag = 0; %判断是否进入跟踪模式，0为不跟踪，大波束扫描模式，1为大波束跟踪，2为小波束扫描
points = []; %保存扫描模式下扫描完整个区域的点迹的一个周期的点迹，分为多行，每行分别为[横向距离 纵向距离 纵向速度]
object = cell(1, time_num);%保存每个整周期的扫描目标信息(大波束扫描模式），如果一个周期内有多个目标，用多行表示，每行分别为[横向距离 纵向距离 纵向速度]
BigBeamScanningCount = 1;%扫描模式下大波束扫描的周期次数
trackingobject = cell(1, smallScanningNum);%保存这个跟踪周期的每次扫描整个区域的目标信息，如果一个周期内有多个目标，用多行表示，每行分别为[横向距离 纵向距离 纵向速度]
trackingAllObject = {};%保存所有时间的跟踪整个区域的综合信息
integraObject = [];%保存每个大波束扫描整个周期后综合点信息，用多行表示，每行分别为[横向距离 纵向距离 纵向速度]
isWarning = 0; %判断是否需要预警，1为大规模预警，2为小规模预警
smallScanningCount = 1; %计算小波束扫描完整个区域的次数，大于smallScanningNum时则需要重置为大波束扫描
BigBeamTrackingObject = []; %大波束跟踪窗口的目标队列
SmallPoint = [];
fprintf('开始大波束扫描.....................\n');
for i = 1:len
    updatemap(i); %实时更新map
    figure(3)
    plot(RL(:,i),RW(:,i),'*');
    axis([0 map_length 0 map_width]);
    title('运动目标原始点迹信息');
    for index = 1:points_num
        if outOfRange(index) == 0
            prePath{1,index} = [prePath{1,index} [R_pre_lmp(index)*map_l; R_pre_wmp(index)*map_w]]; %模拟的理论运动模型轨迹
        end
    end
    if track_flag == 0 %扫描模式
        [hasObject, objects_l, objects_w, objects_v] = BeamFindObject(beamPos_l, beamPos_w, 1);%判断当前波束是否有目标，如果有，记录下点迹
        if hasObject
            for k = 1:size(objects_l,1)
                fprintf('大波束扫描发现目标,坐标(%f,%f)，速度%f\n',objects_l(k), objects_w(k), objects_v(k));
            end
            points = [points ;objects_l objects_w objects_v];
        end
        
        beamPos_l = beamPos_l + 1;%切换下一个波束，先横着扫，当扫到行尾时切换到下一行
        if beamPos_l > num_l
            beamPos_w = beamPos_w + 1; %换行
            beamPos_l = 1;%切换到行首
        end
        
        if beamPos_w > num_w
            i
            fprintf('一个整周期扫描结束，开始后续的分析处理\n');
            beamPos_w = 1;
            beamPos_l = 1;
            if ~isempty(points)
                if size(points,1) > maxPointsNum
                    isWarning = 1;
                    fprintf('哇，好多点迹啊，肯定发生泥石流了,先跑再说！\n');
                end
                [objectCell, clusternum] = handlePoints(points, minPts, distanceWDoor, velocityDoor, parameterWeight, 1);%大波束点迹聚合处理
                fprintf('点迹聚合完毕，发现%d个疑似目标\n', clusternum);
                %更新每个簇的目标大概尺寸，根据平均值方法计算
                for j = 1:clusternum
                    cludisl = objectCell{j}(:,1);%取簇中的横向距离维
                    cludisw = objectCell{j}(:,2);%取簇中的纵向距离维
                    cluv = objectCell{j}(:,3);%去簇中的速度维
                    clustersize = max(cludisw) - min(cludisw);
                    %将整个周期的分析出来的目标信息和大小信息放入ojbect矩阵
                    fprintf('点迹过滤，将大小很小的物体滤除，将速度为正的目标剔除\n');
                    if clustersize > minObjectSize && mean(cluv) < 0
                        if clustersize > maxObjectSize
                            isWarning = 1;
                            fprintf('出现了一个好大的物体啊，有危险，需要预警下\n');
                        end
                        if(isempty(object{BigBeamScanningCount}))
                            object{BigBeamScanningCount} = [mean(cludisl) mean(cludisw) mean(cluv) clustersize];
                        else
                            object{BigBeamScanningCount} = [object{BigBeamScanningCount};mean(cludisl) mean(cludisw) mean(cluv) clustersize];
                        end
                    end
                end
                %得到物体数量，大小，得到整个探测区域的综合点信息
                BigBeamScanningCount
                if ~isempty(object{BigBeamScanningCount})
                    effectiveNum = size(object{BigBeamScanningCount},1); %本周期有威胁性的目标数量
                    integraDisL = mean(object{BigBeamScanningCount}(:,1));%整个周期内的所有目标的质心点横向距离
                    integraDisW = max(object{BigBeamScanningCount}(:,2));%整个周期内的所有目标的纵向距离最大值
                    integraV = mean(object{BigBeamScanningCount}(:,3));%整个周期内的所有目标的质心点速度
                    fprintf('有%d个威胁性目标出现，综合位置为(%f,%f),速度为%f\n',effectiveNum, integraDisL, integraDisW, integraV);
                    
                    figure(2)
                    if isWarning == 1
                        plot(object{BigBeamScanningCount}(:,1),object{BigBeamScanningCount}(:,2), 'r*');
                    else
                        plot(object{BigBeamScanningCount}(:,1),object{BigBeamScanningCount}(:,2), 'b*');
                    end
                    axis([0 map_length 0 map_width]);
                    title('分析处理后目标实时运动信息');
                    figure(1)
                    plot(object{BigBeamScanningCount}(:,1),object{BigBeamScanningCount}(:,2), 'r*');
                    axis([0 map_length 0 map_width]);
                    hold on
                    title('分析处理后运动轨迹');
                    for k = 1:effectiveNum
                        fprintf('第%d个威胁性目标位置(%f,%f),速度为%f\n，大小为%f\n',k, object{BigBeamScanningCount}(k,1), object{BigBeamScanningCount}(k,2), object{BigBeamScanningCount}(k,3),object{BigBeamScanningCount}(k,4));
                        plotObject(object{BigBeamScanningCount}(k,1), object{BigBeamScanningCount}(k,2),object{BigBeamScanningCount}(k,4)/2);
                    end
                    pause(0.1);
                    if effectiveNum < trackObjectNum
                        fprintf('由于目标数量较少，切换到大波束跟踪模式\n');
                        track_flag = 1; %切换到大波束跟踪模式
                        BigBeamTrackingObject = object{BigBeamScanningCount};%设定需要跟踪的目标
                        %TODO: movingTrendL = zeros(1, effectiveNum);%横向移动的趋势，-1为向左，1为向右，默认为0
                        BigBeamTrackingWindow = getBigBeamTrackingWindow(BigBeamTrackingObject);%根据要跟踪的目标，确定大波束的跟踪扫描窗
                        %相关变量状态的初始化
                        points = [];
                        %integraObject = [];
                        % BigBeamScanningCount = 1;
                    else
                        if isempty(integraObject)
                            integraObject = [integraDisL integraDisW integraV];
                        else
                            if integraDisW < integraObject(end, 2) %与上一次的纵向距离比较，如果小于则是物体在接近中
                                integraObject = [integraObject;integraDisL integraDisW integraV];%将该综合点信息加入
                                if size(integraObject,1) >= continuousCount %如果连续接近的次数达到设定的门限则预警
                                    isWarning = 1;
                                    fprintf('夭寿啦！大规模异物入侵啦！\n');
                                    fprintf('夭寿啦！大规模异物入侵啦！\n');
                                    fprintf('夭寿啦！大规模异物入侵啦！\n');
                                    %TODO:考虑下画图的事情
                                end
                            else
                                %物体出现远离的趋势，将之前的趋势清除，重新开始计算趋势
                                isWarning = 0;
                                integraObject = [integraDisL integraDisW integraV];
                            end
                        end
                        points = []; %清空points
                    end
                else
                    fprintf('本扫描周期未发现有威胁性目标\n');
                end
                BigBeamScanningCount = BigBeamScanningCount + 1;
                points = [];
            else
                fprintf('本大波束扫描周期未发现可疑点迹，all clear!\n');
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
                    fprintf('该大波束内发现%d个点迹\n', size(objects_l,1));
                    for k = 1:size(objects_l,1)
                        fprintf('大波束跟踪发现目标,坐标(%f,%f)，速度%f\n',objects_l(k), objects_w(k), objects_v(k));
                    end
                    fprintf('切换到小波束扫描\n')
                    track_flag = 2;
                    %points = [points ;objects_l objects_w objects_v];%大波束跟踪探测到的点用于辅助判断
                    SmallBeamTrackingWindow = getSmallBeamScanningWindow(objects_l, objects_w);%根据要跟踪的目标，确定小波束的顺序扫描窗
                end
            else
                fprintf('一个跟踪周期扫描完，开始处理数据\n');
                effectiveNum = 0;
                if ~isempty(points)
                    [objectCell, clusternum] = handlePoints(points, minPts, distanceWDoor, velocityDoor, parameterWeight, 2);%小波束点迹聚合处理
                    fprintf('点迹聚合完毕，发现%d个疑似目标\n', clusternum);
                    
                    for j = 1:clusternum
                        cludisl = objectCell{j}(:,1);%取簇中的横向距离维
                        cludisw = objectCell{j}(:,2);%取簇中的纵向距离维
                        cluv = objectCell{j}(:,3);%去簇中的速度维
                        clustersize = max(cludisw) - min(cludisw);
                        %将整个周期的分析出来的目标信息和大小信息放入ojbect矩阵
                        fprintf('点迹过滤，将大小很小的物体滤除，将速度为正的目标剔除\n');
                        if clustersize > 1 && mean(cluv) < 0
                            if(isempty(trackingobject{smallScanningCount}))
                                trackingobject{smallScanningCount} = [mean(cludisl) mean(cludisw) mean(cluv) clustersize];
                            else
                                trackingobject{smallScanningCount} = [trackingobject{smallScanningCount};mean(cludisl) mean(cludisw) mean(cluv) clustersize];
                            end
                        end
                    end
                    trackingAllObject = [trackingAllObject trackingobject{smallScanningCount}];
                    figure(2)
                    if isWarning == 2
                        plot(trackingAllObject{end}(:,1),trackingAllObject{end}(:,2), 'g*');
                    else
                        plot(trackingAllObject{end}(:,1),trackingAllObject{end}(:,2), '*');
                    end
                    axis([0 map_length 0 map_width]);
                    title('分析处理后目标实时运动信息');
                    figure(1)
                    plot(trackingAllObject{end}(:,1),trackingAllObject{end}(:,2), '*');
                    axis([0 map_length 0 map_width]);
                    hold on
                    
                    %得到物体数量，大小，得到整个探测区域的综合点信息
                    if ~isempty(trackingobject{smallScanningCount})
                        effectiveNum = size(trackingobject{smallScanningCount},1); %本周期有威胁性的目标数量
                        integraDisL = mean(trackingobject{smallScanningCount}(:,1));%整个周期内的所有目标的质心点横向距离
                        integraDisW = mean(trackingobject{smallScanningCount}(:,2));%整个周期内的所有目标的纵向距离最大值
                        integraV = mean(trackingobject{smallScanningCount}(:,3));%整个周期内的所有目标的质心点速度
                        fprintf('有%d个威胁性目标出现，综合位置为(%f,%f),速度为%f\n',effectiveNum, integraDisL, integraDisW, integraV);
                        for k = 1:effectiveNum
                            fprintf('第%d个威胁性目标位置(%f,%f),速度为%f\n，大小为%f\n',k, trackingobject{smallScanningCount}(k,1), trackingobject{smallScanningCount}(k,2), trackingobject{smallScanningCount}(k,3),trackingobject{smallScanningCount}(k,4));
                            plotObject(trackingobject{smallScanningCount}(k,1), trackingobject{smallScanningCount}(k,2),trackingobject{smallScanningCount}(k,4)/2);
                        end
                        pause(0.1);
                        %TODO：画图
                        if effectiveNum > trackObjectNum
                            fprintf('目标数量较多，改为大波束扫描模式\n');
                            track_flag = 0;
                            %相关变量状态的初始化
                            points = [];
                        else
                            %继续跟踪模式
                            fprintf('继续进行大波束跟踪模式\n');
                            if isempty(integraObject)
                                integraObject = [integraDisL integraDisW integraV];
                            else
                                if integraDisW < integraObject(end, 2) %与上一次的纵向距离比较，如果小于则是物体在接近中
                                    integraObject = [integraObject;integraDisL integraDisW integraV];%将该综合点信息加入
                                    if size(integraObject,1) >= continuousCount %如果连续接近的次数达到设定的门限则预警
                                        isWarning = 2;
                                        fprintf('咦！异物入侵啦！\n');
                                        fprintf('咦！异物入侵啦！\n');
                                        fprintf('咦！异物入侵啦！\n');
                                        %TODO:考虑下画图的事情
                                    end
                                else
                                    %物体出现远离的趋势，将之前的趋势清除，重新开始计算趋势
                                    fprintf('物体出现远离的趋势，将之前的趋势清除，重新开始计算趋势\n');
                                    integraObject = [integraDisL integraDisW integraV];
                                    isWarning = 0;
                                end
                            end
                        end
                        %相关参数初始化
                        points = [];
                        BigBeamTrackingObject = trackingobject{smallScanningCount};%设定新一轮需要跟踪的目标
                        BigBeamTrackingWindow = getBigBeamTrackingWindow(BigBeamTrackingObject);%根据要跟踪的目标，确定大波束的跟踪扫描窗
                        
                        smallScanningCount = smallScanningCount + 1;
                        if smallScanningCount > smallScanningNum
                            fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%大于规定的小波束跟踪整个周期的次数，重新用大波束全局扫描%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
                            track_flag = 0; %大于规定的小波束跟踪整个周期的次数，重新用大波束全局扫描
                            beamPos_w = 1; %波束重新初始化
                            beamPos_l = 1;
                            points = [];
                            trackingobject = cell(1, smallScanningNum);
                            smallScanningCount = 1;
                        else
                            track_flag = 1; %继续大波束跟踪
                        end
                    else
                        fprintf('跟踪处理后未发现有威胁性目标,重新用大波束扫描\n');
                        track_flag = 0;
                        isWarning = 0;
                        beamPos_w = 1; %波束重新初始化
                        beamPos_l = 1;
                        points = [];
                        trackingobject = cell(1, smallScanningNum);
                        smallScanningCount = 1;
                        BigBeamTrackingWindow = [];
                    end
                else
                    fprintf('大波束跟踪未发现目标，跟踪丢失，重新用大波束扫描\n');
                    track_flag = 0;
                    isWarning = 0;
                    beamPos_w = 1; %波束重新初始化
                    beamPos_l = 1;
                    points = [];
                    trackingobject = cell(1, smallScanningNum);
                    smallScanningCount = 1;
                    BigBeamTrackingWindow = [];
                end
            end
        else %小波束扫描模式
            if ~isempty(SmallBeamTrackingWindow)
                beamPos_l = SmallBeamTrackingWindow(1, 1); %取出参考窗
                beamPos_w = SmallBeamTrackingWindow(1, 2); %取出参考窗
                SmallBeamTrackingWindow(1, :) = [];
                [hasObject, objects_l, objects_w, objects_v] = BeamFindObject(beamPos_l, beamPos_w, 2);%判断当前波束是否有目标，如果有，记录下点迹
                if hasObject
                    fprintf('大波束中的小波束发现%d个点迹\n', size(objects_l,1));
                    for k = 1:size(objects_l,1)
                        fprintf('小波束扫描发现目标,坐标(%f,%f)，速度%f\n',objects_l(k), objects_w(k), objects_v(k));
                    end
                    points = [points ;objects_l objects_w objects_v];
                end
            else
                %大波束内的小波束全部扫描完，切回到大波束跟踪
                fprintf('大波束内的小波束全部扫描完，切回到大波束跟踪\n');
                track_flag = 1;
            end
        end
    end
end
%测试运动模型轨迹路径
% figure
% for index = 1:points_num
%     plot(prePath{1,index}(1,:),prePath{1,index}(2,:),'*');
%     hold on
% end

