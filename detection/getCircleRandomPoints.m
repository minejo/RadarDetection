%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%
%在指定半径内，随机生成若干个随机的点,一个分辨率内只出现一个点
function [R_init_ls, R_init_ws] = getCircleRandomPoints(objectSize, RL, RW, deltaR)
radius = objectSize; %物体的半径
R_init_ls = [];
R_init_ws = [];
for i = RL - radius:2*deltaR: RL + radius
    for j = RW - radius:deltaR: RW + radius
        flag = randi([0 1]);
        if flag == 1
            R_init_ls = [R_init_ls; i];
            R_init_ws = [R_init_ws; j];
        end
    end
end