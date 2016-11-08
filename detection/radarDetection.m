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
num_l = map_length / big_beam; %大波束横轴扫描次数
num_w = map_width / big_beam;%大波束纵轴扫描次数
track_flag = 0; %判断是否进入跟踪模式，0为不跟踪，扫描模式，1为大波束跟踪，2为小波束跟踪
points = []; %保存扫描模式下扫描完整个区域的点迹的一个周期的点迹，分为多行，每行分别为[横向距离 纵向距离 纵向速度]
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
            %开始点迹凝聚
            
            %点迹过滤
            
            %得到物体数量，大小
            
            %得到整个探测区域的综合点信息
            
        end
    end
end
%测试运动模型轨迹路径
figure
for index = 1:objectNum
    plot(prePath{1,index}(1,:),prePath{1,index}(2,:),'*');
    hold on
end

