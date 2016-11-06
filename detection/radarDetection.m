%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%
close all;
clear all;
clc;
%全局变量设置
global map VW RL RW map_l map_w map_length map_width R_pre_lmp R_pre_wmp objectNum;
load('simuConfig.mat');%导入雷达参数配置文件

Tb = map_length*map_width/(big_beam*big_beam)*T1; %大波束扫描完整个区域的时间
t = 0:T1:time_num*Tb; %时间轴
len = size(t,2);
VL = V_init_l*ones(1,len) + A_init_l*t;%横向目标速度时间轴
VW = V_init_w*ones(1,len) + A_init_w*t;%纵向目标速度时间轴
RL = R_init_l*ones(1,len) + (V_init_l*t + 0.5*A_init_l*t.^2);
RW = R_init_w*ones(1,len) + (V_init_w*t + 0.5*A_init_w*t.^2);
%TDODO:加速度可以在一定范围内浮动


%%
%智能波束方案
global outOfRange;
outOfRange = zeros(objectNum, 1);
prePath = cell(1,objectNum);
for i = 1:len
    updatemap(i); %实时更新map
    for index = 1:objectNum
       if outOfRange(index) == 0
           prePath{1,index} = [prePath{1,index} [R_pre_lmp(index)*map_l; R_pre_wmp(index)*map_w]];
       end
    end
end
%测试运动模型轨迹路径
figure
for index = 1:objectNum
    plot(prePath{1,index}(1,:),prePath{1,index}(2,:),'*');
    hold on
end
