%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

function point = threePredict(point1, point2, point3, t)
%利用三点的状态信息进行第三个点的预测,每个点为一个行向量，分别为距离，速度，方位，时间,使用阿发-贝塔-伽马滤波器方法预测
%滤波器参数
alpha = 0.271;
beta=0.0285;
gamma=0.0005;

Rs2 = point2(1); %对第二点的距离估计
Fs2 = point2(3); %对第二点的方位估计
T1=point2(4)-point1(4); %两点之间的时间差
Fvs2 = (point2(3) - point1(3))/T1; %对第二点的方位变化速度估计
Vs2 = (point2(1) - point1(1))/T1; %对第二点的速度估计
As2 = (point2(2) - point1(2))/T1;%对第二点的加速度估计
%上时刻对本时刻预测的作用
T2=point3(4)-point2(4);
Rp3 = Rs2 + T2 * Vs2 + T2*T2/2*As2; %对第三点距离的预测
Vp3 = Vs2+As2*T2; %对第三点速度的预测
Ap3= As2;%对第三点加速度的预测
Fp3 = Fs2 + T2*Fvs2;

%滤波
Rs3 = Rp3 + alpha*(point3(1) - Rp3);
Vs3 = Vp3 + beta/T2*(point3(1) - Rp3);
As3 = Ap3 + 2*r/(T2*T2)*(point3(1) - Rp3);
Fs3 = Fp3 + alpha*(point3(3) - Fp3);
Fvs3 = (point3(3)-point2(3))/T2;

%对第四点的预测
T3 = t - point3(4);
Rp4 = Rs3 + Vs3*T3 + As3*(T3*T3/2);
Vp4 = Vs3 + As3*T3;
Ap4 = As3;
Fp4 = Fs3 + Fvs3*T3;

point = [Rp4 Vp4 Fp4 t];
end