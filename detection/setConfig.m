%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

%%
clear
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
Rmax=300; %最大处理距离
Fs=4*B*Rmax/(T*c); %差频信号采样率
N=round(Fs*T); %距离维采样点数
M=fix(c/(deltaV*2*T*f0)); %速度维采样点数
Vmax=M*deltaV;  %最大不模糊距离
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%波束赋形相关参数
T1 = M*T; %单波束驻留时间，波束切换时间不考虑
big_beam = 8; %大波束的正方形边长
small_beam = 2; %小波束正方形边长
allow_T = 1.5; %跟踪扫描时全局容忍空白时间(s)
time_num = 30;%仿真时扫描整个探测区域的次数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%场景模型设计
map_l = 0.5;%运动模型的分辨率
map_w = 0.5;
map_length = 160;%探测区域长度
map_width = 80;%探测区域宽度
map=zeros(map_length/map_l, map_width/map_w); %初始map数组，初始化为0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%运动物体设定
objectNum = 5;
%R_init_l = []; %目标的初始横向距离
%R_init_w = []; %目标的初始纵向距离
%V_init_l = []; %目标的初始横向速度
%V_init_w = []; %目标的初始纵向速度
%A_init_l = []; %目标的初始横向加速度
%A_init_w = []; %目标的初始纵向加速度
[R_init_l, R_init_w, V_init_l, V_init_w, A_init_l, A_init_w] = getRandomInitObject(objectNum, map_length, map_width, deltaR); %采取随机的方式确定以上参数
%%%%%初始目标在map中的标示%%%%%
for index = 1:objectNum    
      map(fix(R_init_l(index)/map_l), fix(R_init_w(index)/map_w)) = abs(V_init_w(index));   
end
R_pre_lmp = R_init_l/map_l; %对应前一时刻的横向距离的map坐标
R_pre_wmp = R_init_w/map_w; %对应前一时刻的纵向距离的map坐标
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%点迹聚合与过滤相关参数
distanceWDoor = 2*deltaR; %纵向距离门设置为两倍的距离分辨率
distanceLDoor=2*small_beam; %横向距离门默认为小波束分辨率的两倍，当使用大波束扫描时应更改成大波束边长的两倍
velocityDoor = 2; %速度门
minPts = 6; %number of objects in a neighborhood of an object
%目标跟踪相关参数
trackObjectNum = 4; %跟踪模式下可以跟踪的最大目标数量
%目标预警相关参数
continuousCount = 4; %目标连续几个周期靠近雷达就预警
%小波束连续扫描整个周期的最大数，如果到达次数，需要重新用大波束扫描这个区域，确保其他区域不会出现漏警
smallScanningNum = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save simuConfig.mat