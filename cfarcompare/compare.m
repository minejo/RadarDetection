%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

%仿真一维ca-cfar算法, 二维十字窗相与算法，二维十字窗改进尖峰算法的性能
c=3e8;
%%%%%%%%%%%%%连续波雷达系统参数%%%%%%%%%%%%%%%%%%%
T=80e-6; %连续波扫频周期
f0=20e9; %调频初始频率
B=500e6; %发射机调频带宽
deltaR=c/(2*B); %二维变换后的距离分辨率
deltaV=2; %二维变换后速度维分辨率
Rmax=300; %最大处理距离
Fs=4*B*Rmax/(T*c); %差频信号采样率
N=round(Fs*T); %距离维采样点数
M=fix(c/(deltaV*2*T*f0)); %速度维采样点数
Vmax=M*deltaV;  %最大不模糊距离

disg1 = getdisg(100,5,B,f0,T,Fs,M); %设置一个动目标
disg2 = getdisg(99,0,B,f0,T,Fs,M); %设置一个静目标

response = disg1 + disg2; %差频回波信号
response  = awgn(response, 1); %加噪声
%添加杂波
za=zeros(M,N);
for k=1:M
    za(k,:)=wbfb(1.5,2.2);
end
response = response + za;
%一维变换
fft1=zeros(M,N);
for k=1:M
    fft1(k,:)=fft(response(k,:),N);
end
%二维fff变换
fft2=zeros(M,N);
for i=1:N
    fft2(:,i) = fft(fft1(:,i),M);
end

%% CFAR处理
%仿真10000次，看检测出物体的个数，虚警个数以及漏警个数
for k=1:10000
    for i= 1:N
        for j = 1:M            
            %使用一维ca-cfar方案 
            %使用二维十字窗相与算法
            %使用二维十字窗改进尖峰算法
        end
    end
end