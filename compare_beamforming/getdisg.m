%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dsig = getdisg(R0,v0, rcs)
%得到单个物体的差频信号
global c B f0 T Fs M
A= 100*sqrt(rcs); %发射信号幅值
t=0:1/Fs:T-1/Fs; %采样时间维
u=B/T;
%t时刻物体距离
Rn=R0+v0.*t;
%速度多普勒频率
fd=2*f0*v0/c;
%距离多普勒频率
fw=2*u.*Rn/c;
%phase0 初始相位
phase0=2*pi*f0*2*R0/c;
%采样点数
fa_num=round(Fs*T);
freq=zeros(M,fa_num);

%差频频率
for k=1:M
  freq(k,:)=2*pi*((fw+fd).*t + fd*(k-1)*T) + phase0;
end

%差频信号
dsig=A*cos(freq);
end

