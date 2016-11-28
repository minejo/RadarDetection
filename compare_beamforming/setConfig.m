%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

%%
clear
close all
clc
if exist('simuConfig.mat')
delete simuConfig.mat
end
c=3e8;
%连续波雷达系统参数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T=80e-6; %连续波扫频周期
f0=20e9; %调频初始频率
B=500e6; %发射机调频带宽
deltaR=c/(2*B); %二维变换后的距离分辨率
deltaV=2; %二维变换后速度维分辨率
%%%%%%%%%确定分辨率%%%%%%%%%%%%%%
Rmax=90; %最大处理距离
Fs=4*B*Rmax/(T*c); %差频信号采样率
N=round(Fs*T); %距离维采样点数
M=fix(c/(deltaV*2*T*f0)); %速度维采样点数
Vmax=M*deltaV;  %最大不模糊距离
RCS = 10; %目标rcs值
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%波束赋形相关参数
T1 = M*T; %单波束驻留时间，波束切换时间不考虑
big_beam = 9; %大波束的正方形边长
small_beam = 3; %小波束正方形边长
allow_T = 1.5; %跟踪扫描时全局容忍空白时间(s)
time_num = 40;%仿真时扫描整个探测区域的次数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%场景模型设计
map_l = 0.3;%运动模型的分辨率
map_w = 0.3;
map_length = 90;%探测区域长度
map_width = 60;%探测区域宽度
map=ones(map_length/map_l, map_width/map_w)*1000; %初始map数组，初始化为1000,一个不可能达到的速度，如果map的位置出现为1000，表示该地方没有目标
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%运动物体设定
objectNum = 1;
%R_init_l = []; %目标的初始横向距离
%R_init_w = []; %目标的初始纵向距离
%V_init_l = []; %目标的初始横向速度
%V_init_w = []; %目标的初始纵向速度
%A_init_l = []; %目标的初始横向加速度
%A_init_w = []; %目标的初始纵向加速度
[R_init_l, R_init_w, V_init_l, V_init_w, A_init_l, A_init_w, objectSizeinfo] = getRandomInitObject(objectNum, map_length, map_width, deltaR, map_l, map_w); %采取随机的方式确定以上参数
figure
plot(R_init_l, R_init_w, '*');
axis([0 map_length 0 map_width]);
%%%%%初始目标在map中的标示%%%%%
points_num = size(R_init_l, 1); %所有点迹的数量
for index = 1:points_num    
      map(fix(R_init_l(index)/map_l), fix(R_init_w(index)/map_w)) = V_init_w(index);   
end
R_pre_lmp = fix(R_init_l/map_l); %对应前一时刻的横向距离的map坐标
R_pre_wmp = fix(R_init_w/map_w); %对应前一时刻的纵向距离的map坐标
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%点迹聚合与过滤相关参数
distanceWDoor = deltaR; %纵向距离门设置为两倍的距离分辨率
%distanceLDoor=2*small_beam; %横向距离门默认为小波束分辨率的两倍，当使用大波束扫描时应更改成大波束边长的两倍
velocityDoor = 1; %速度门
minPts = 4; %number of objects in a neighborhood of an object
parameterWeight = [0.2 0.4 0.4];%计算欧几里得时的权重，分别对应[横向距离 纵向距离 纵向速度]
%目标跟踪相关参数
trackObjectNum = 3; %跟踪模式下可以跟踪的最大目标数量
%目标预警相关参数
continuousCount = 3; %目标连续几个周期靠近雷达就预警
%小波束连续扫描整个周期的最大数，如果到达次数，需要重新用大波束扫描这个区域，确保其他区域不会出现漏警
smallScanningNum = fix(allow_T/(objectNum*(6+big_beam/small_beam*7)*T1));
maxPointsNum = 1000; %一个周期设定的点迹数量上限，探测到的点迹超过这个上限直接预警，很有可能直接发生了泥石流
maxObjectSize = 10;%点击聚合后如果有物体体积大于这个上限，可直接预警
minObjectSize = 1;%小于这个界限的物体可认为没有威胁吧
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%恒虚警相关参数
alpha = 0.5;%s-cfar参数
beta = 22.5;%s-cfar参数
scfar_r = 3;%容忍目标的个数
KVI = 4.56; %svi-cfar方法判断均匀性参数
KMR = 2.9; %svi-cfar方法判断均匀性参数
CFAR_N_l = 16;%横向参考窗长度
CFAR_N_w = 8;%纵向参考窗长度
window_r = 1;%选择参考窗时隔离的目标数
pfa_d = 1e-6;
pfa_v = 1e-6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save simuConfig.mat