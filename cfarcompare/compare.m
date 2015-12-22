%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%
clear all;
close all;
clc;
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
%M=16;
Vmax=M*deltaV;  %最大不模糊距离

disg1 = getdisg(100,30,B,f0,T,Fs,M); %设置一个动目标
disg2 = getdisg(98,0,B,f0,T,Fs,M); %设置一个静目标

response = disg1 + disg2; %差频回波信号
response  = awgn(response, 1); %加噪声

%仿真N次，看检测出物体的个数，虚警个数以及漏警个数
cfarrightnum=0; %cfar算法正确检测的个数
cfarclosewrongnum=0; %cfar算法动目标邻近虚警的个数
cfarawaywrongnum=0; %cfar算法其他区域虚警的个数
cfarmissnum=0; %cfar算法漏警的个数

% CFAR处理
L_v=16; %速度维参考窗长度
L_d=20; %距离维参考窗长度
r=1; %保护单元长度
pfa_d=5e-3; %距离维虚警率
pfa_v=5e-3; %速度维虚警率
K1=(pfa_d)^(-1/L_d)-1; %虚警门限
K2=(pfa_v)^(-1/L_v)-1;

for k=1:50
    %添加杂波
    za=zeros(M,N);
    for t=1:M
        za(t,:)=wbfb(1.5,2.2);
    end
    response = response + za;
    %一维变换
    fft1=zeros(M,N);
    for t=1:M
        fft1(t,:)=fft(response(t,:),N);
    end
    %二维fff变换
    fft2=zeros(M,N);
    for i=1:N
        fft2(:,i) = fft(fft1(:,i),M);
    end
    data = abs(fft2(:,1:N/2));
    %去除速度维0的杂波与静止物体
    data=data(2:M,:);
    H=M-1;
    right=0;
    wrong1=0;
    wrong2=0;
    
    for i= 1:H
        for j = 100:800
            %获取纵轴cfar参考窗
            cankao1=zeros(L_v); %参考窗
            if(i>(L_v/2+r)&&i<=H-L_v/2-r)
                cankao1=[data(i-L_v/2-r:i-r-1,j)' data(i+r+1:i+L_v/2+r,j)'];
            elseif (i==1 || i ==2)
                cankao1=data(i+r+1:i+L_v+r,j)';
            elseif(2<i && i<=L_v/2+r)
                cankao1=[data(1:i-r-1,j)' data(i+r+1:L_v+2*r+1,j)'];
            elseif(i<H-1&&i>H-L_v/2-r)
                cankao1=[data(-2*r-L_v+H:i-r-1,j)' data(i+r+1:H,j)'];
            elseif( i==H || i==H-1)
                cankao1=data(i-L_v-r:i-r-1,j)';
            end
            
            %获取横轴cfar参考窗
            cankao2=zeros(L_d);
            if(j>(L_d/2+1)&&j<=N-L_d/2-1)
                cankao2=[data(i,j-L_d/2-r:j-r-1) data(i,j+r+1:j+L_d/2+r)];
            elseif (j==1 || j ==2)
                cankao2=data(i,j+r+1:j+L_d+r);
            elseif(2<j && j<=L_d/2+1)
                cankao2=[data(i,1:j-r-1) data(i,j+r+1:L_d+2*1+r)];
            elseif(j<N-1&&j>N-L_d/2-1)
                cankao2=[data(i,-2*r-L_d+N:j-r-1) data(i,j+r+1:N)];
            elseif( j==N || j==N-1)
                cankao2=data(i,j-L_d-r:j-r-1);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%使用一维ca-cfar方案%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                hasObject1=cacfar(data(i,j),cankao1,K2);
                                                hasObject = hasObject1;
            % %
            %%%%%%%%%%%%%%%%%%%%使用二维十字窗相与算法%%%%%%%%%%%%%%%%%%%%%%%%%
%             hasObject1=cacfar(data(i,j),cankao1,K2);
%             hasObject2=cacfar(data(i,j),cankao2,K1);
%             hasObject = hasObject1*hasObject2;
            %%%%%%%%%%%%%%%%%%%使用二维十字窗改进尖峰算法%%%%%%%%%%%%%%%%%%%%%%
%                         %判断该点是否是顶点
%                         isTop=1;
%                         if(i>1&&i<H&&j>1&&j<N/2)
%                             isTop= (data(i,j) > data(i+1,j)) && (data(i,j) > data(i-1,j)) && (data(i,j) > data(i,j-1)) && (data(i,j) > data(i,j+1));
%                         end
%                         hasObject1=cacfar(data(i,j),cankao1,K2);
%                         hasObject2=cacfar(data(i,j),cankao2,K1);
%                         hasObject = hasObject1*hasObject2*isTop;
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if hasObject
                if(j == 335 && i ==15)%动物体对应的横坐标
                    right = right + 1;
                else
                    if( (i<=19||i>=13) && (j>=331||j<=338))
                        wrong1 = wrong1 + 1;
                    else
                        wrong2 = wrong2 + 1;
                    end
                end
            end
        end
        
    end
    miss = 1 - right;
    cfarrightnum = cfarrightnum + right;
    cfarclosewrongnum = cfarclosewrongnum + wrong1;
    cfarawaywrongnum = cfarawaywrongnum + wrong2;
    cfarmissnum = cfarmissnum + miss;
    k
end