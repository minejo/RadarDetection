%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

function [R_init_l, R_init_w, V_init_l, V_init_w, A_init_l, A_init_w] = getRandomInitObject(objectNum, map_length, map_width)
R_init_l = randi([0.3*map_length 0.7*map_length], objectNum, 1); %目标的初始横向距离
R_init_w = randi([0.3*map_width 0.7*map_width], objectNum, 1); %目标的初始纵向距离
vmin = -15;
vmax = 15;
V_init_l = randi([vmin vmax], objectNum, 1); %目标的初始横向速度
V_init_w = randi([vmin vmax], objectNum, 1); %目标的初始纵向速度
amin = -5;
amax = 5;
A_init_l = randi([amin amax], objectNum, 1); %目标的初始横向加速度
A_init_w = randi([amin amax], objectNum, 1); %目标的初始纵向加速度
end