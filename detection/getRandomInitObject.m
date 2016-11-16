%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%
%随机获得N个目标的若干个点迹
function [R_init_l, R_init_w, V_init_l, V_init_w, A_init_l, A_init_w, objectSizeinfo] = getRandomInitObject(objectNum, map_length, map_width, deltaR, map_l, map_w)
vmin = -6;
vmax = -1;
amin = -2;
amax = 0;
R_init_l = []; %目标的初始横向距离
R_init_w = []; %目标的初始纵向距离
V_init_l = []; %目标的初始横向速度
V_init_w = []; %目标的初始纵向速度
A_init_l = []; %目标的初始横向加速度
A_init_w = []; %目标的初始纵向加速度
maxIndexL = 0.8*map_length / map_l; %随机取的目标的横坐标的最大范围，避免取到边界的极端情况
minIndexL = 0.2*map_length / map_l;
maxIndexW = 0.8*map_width / map_w;
minIndexW = 0.2*map_width / map_w;
objectSizeinfo = ones(objectNum, 1);
for i = 1:objectNum
   RL = randi([minIndexL maxIndexL])*map_l; %目标的初始横向距离，取运动模型分辨率的整数倍，确定可以整除
   RW = randi([minIndexW maxIndexW])*map_w; %目标的初始纵向距离
   VL = randi([-6 6]); %目标的初始横向速度
   VW = randi([vmin vmax]); %目标的初始纵向速度
   AL = randi([amin amax]); %目标的初始横向加速度
   AW = randi([amin amax]); %目标的初始纵向加速度
   objectSize = randi([2 9])*deltaR; %目标大小
   objectSizeinfo(i, 1) = 2*objectSize;
   [R_init_ls, R_init_ws] = getCircleRandomPoints(objectSize, RL, RW, deltaR); %同一个物体的所有距离信息，分为多行，每行分别为[L W]
   pointNum = size(R_init_ls, 1);%该目标的点迹数
   R_init_l = [R_init_l; R_init_ls];
   R_init_w = [R_init_w; R_init_ws];
   V_init_l = [V_init_l; ones(pointNum, 1)* VL];
   V_init_w = [V_init_w; ones(pointNum, 1)* VW];
   A_init_l = [A_init_l; ones(pointNum, 1)* AL];
   A_init_w = [A_init_w; ones(pointNum, 1)* AW];
end
end