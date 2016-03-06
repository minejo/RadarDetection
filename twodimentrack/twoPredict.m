%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

function point = twoPredict(point1, point2, t)
%利用两点的状态信息进行第三个点的预测,每个点为一个行向量，分别为距离，速度，方位，时间
Rs2 = point2(1); %对第二点的距离估计
Fs2 = point2(3); %对第二点的方位估计
T=point2(4)-point1(4); %两点之间的时间差
Vs2 = (point2(1) - point1(1))/T; %对第二点的速度估计
Fvs2 = (point2(3) - point1(3))/T; %对第二点的方位变化速度估计
Rp3 = Rs2 + (t - point2(4)) * Vs2; %对第三点距离的预测
Vp3 = Vs2; %对第三点速度的预测
Fp3 = Fs2; %对第三点的方位的预测
point = [Rp3 Vp3 Fp3 t];
end