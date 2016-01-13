%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%
close all;
clear all;
%建立多目标运动物体模型
deltat=0.2;
t=0:deltat:3;
%   物体运动模型设置     %
%[实时速度，实时距离，实时角度] = mbpara(初始距离，初始速度，加速度，初始角度，角度变化加速度，角度变化初始速度）
[v1, R1, sita1] = mbpara(70,-4,-3,50,1,1,t); %一个动物体以及多点
[v1_1, R1_1, sita1_1] = obmutipoint(R1,v1,sita1,2, deltat);
[v1_2, R1_2, sita1_2] = obmutipoint(R1,v1,sita1,-2,deltat);

[v2, R2, sita2] = mbpara(130,2,2,90,1,2,t); %一个动物体以及多点
[v2_1, R2_1, sita2_1] = obmutipoint(R2,v2,sita2,1,deltat);
[v2_2, R2_2, sita2_2] = obmutipoint(R2,v2,sita2,-1,deltat);

% %      静止物体         %
% R4=72;sita4=50;
% %R2=80;sita2=50;
% %                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%
polar(sita2/180*pi, R2,'*');
hold on;
polar(sita2_1/180*pi,R2_1,'r');
hold on;
polar(sita2_2/180*pi,R2_2,'g');

hold on;

polar(sita1/180*pi, R1,'*');
hold on;
polar(sita1_1/180*pi,R1_1,'r');
hold on;
polar(sita1_2/180*pi,R1_2,'g');

%点迹聚合

%航迹起始

%航迹维持

%航迹管理