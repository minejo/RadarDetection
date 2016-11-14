%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

function [R_init_l, R_init_w, V_init_l, V_init_w, A_init_l, A_init_w] = getRandomInitObject(objectNum, map_length, map_width, deltaR)
% R_init_l = randi([0.2*map_length 0.8*map_length], objectNum, 1); %目标的初始横向距离
% R_init_w = randi([0.2*map_width 0.8*map_width], objectNum, 1); %目标的初始纵向距离
% vmin = -15;
% vmax = 15;
% V_init_l = randi([vmin vmax], objectNum, 1); %目标的初始横向速度
% V_init_w = randi([vmin vmax], objectNum, 1); %目标的初始纵向速度
% amin = -5;
% amax = 5;
% A_init_l = randi([amin amax], objectNum, 1); %目标的初始横向加速度
% A_init_w = randi([amin amax], objectNum, 1); %目标的初始纵向加速度
vmin = -15;
vmax = 15;
amin = -5;
amax = 5;
R_init_l = []; %目标的初始横向距离
R_init_w = []; %目标的初始纵向距离
V_init_l = []; %目标的初始横向速度
V_init_w = []; %目标的初始纵向速度
A_init_l = []; %目标的初始横向加速度
A_init_w = []; %目标的初始纵向加速度
for i = 1:objectNum
   RL = randi([0.2*map_length 0.8*map_length]); %目标的初始横向距离
   RW = randi([0.2*map_width 0.8*map_width]); %目标的初始纵向距离
   VL = randi([vmin vmax]); %目标的初始横向速度
   VW = randi([vmin vmax]); %目标的初始纵向速度
   AL = randi([amin amax]); %目标的初始横向加速度
   AW = randi([amin amax]); %目标的初始纵向加速度
   objectSize = randi([2 12])*deltaR; %目标大小
   [R_init_ls, R_init_ws] = getCircleRandomPoints(objectSize, R_init_l, R_init_w, deltaR); %同一个物体的所有距离信息，分为多行，每行分别为[L W]
   pointNum = size(R_init_ls, 1);%该目标的点迹数
   R_init_l = [R_init_l; R_init_ls];
   R_init_w = [R_init_w; R_init_ws];
   V_init_l = [V_init_l; ones(pointNum, 1)* VL];
   V_init_w = [V_init_w; ones(pointNum, 1)* VW];
   A_init_l = [A_init_l; ones(pointNum, 1)* AL];
   A_init_w = [A_init_w; ones(pointNum, 1)* AW];
end
end