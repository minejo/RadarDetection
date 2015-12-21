function za=wbfb(p,q)
fs=25e6;
ts=1/fs;
p=1.5;
q=2.2;
h=60; %铁塔高60米
R=150;
B=10e6;           %带宽100MHz
thetar=asin(h/R);
theta3=5;
c=3*10^8;
T=80e-6;           %调频周期10-5秒
tm=1/B;       %脉冲宽度
N=fs*T;
M=T/tm;
G=100;
pi=3.1415926;
f0=17*10^9;
lamda=c/f0;
u=B/T;            %调频斜率
tao=2*R/c;
sj=1/2*c*R*theta3*sec(thetar);
sigma0=-42.27+45.21*exp(-0.19*thetar)+(-10.88)*cos(-0.25*thetar+1.19);
K=sqrt(sj*sigma0*lamda^2*G^2/((4*pi)^3*R^4));
f3db=40;
f=-f3db:2*f3db/N:f3db;
S=exp(-(1.665*f/f3db).^2);
s=ifft(S(1:N));
ec=linspace(0,2*pi,1000);
t=linspace(-T/2,T/2,N);
st = K*exp(j*pi*u*(t-tao).^2);
r=sqrt(s*(gamma(3)-gamma(2).^2)/gamma(2).^2);
R=fft(r);
RF=abs(R);
a0=RF(1,1);
RF=RF./a0;
HW=sqrt(RF);%频域法产生滤波器。

sigmav=q^p/2;
v1=rands(sigmav,N);
V1=fft(v1);
%W1=conv(HW,V1)
W1=HW.*V1;

w1=ifft(W1);

v2=rands(sigmav,N);
V2=fft(v2);
%W2=conv(HW,V1)
W2=HW.*V2;

w2=ifft(W2);

w1=w1*sqrt((q.^p)/2);
w2=w2*sqrt((q.^p)/2);
u=w1.^2+w2.^2;

z=u.^(1/p);
z=z.*st;
% figure,plot(t,z);
% title('单个杂波单元信号时域图');
% xlabel('t');
% ylabel('幅值');
y=xcorr(z);%计算自相关函数
Z=fft(y(1:N+1));
Z=10*log10(abs(Z(1:N/2+1))/sum(abs(Z)));
%Z=abs(Z(1:N/2+1))/sum(abs(Z));
% figure,plot(Z);
% title('单个杂波单元信号频谱幅值归一化');
% xlabel('f');
% ylabel('归一化幅值');



%r=exp(j*unifrnd(0,pi,1,length(z)));
% s1=r.*z;
% r=exp(j*unifrnd(0,pi,1,length(z)));
% s2=r.*z;
% r=exp(j*unifrnd(0,pi,1,length(z)));
% s3=r.*z;
za=0;
for i=1:M
    % r=exp(j*unifrnd(0,pi,1,length(z)));
    r=gamrnd(0.5,1,1);
    q=r.*z;
    za=za+q;
end

% for r=1:N
%     for i=1:M
%         r=exp(j*unifrnd(0,pi,1,length(z)));
%         q=r.*z;
%         za=za+q;
%     end
%     d(r,:)=za;
% end
% for r=1:N
%   fft1(r,:)=abs(fft(d(r,:),N));
% end
%
% distance=(linspace(-fs/2,fs/2,N));
% figure;
% plot(distance,fftshift(fft1(1,:)));
% x1=0:N-1;
% y1=distance;
% figure;
% mesh(y1,x1,fftshift(fft1));

% figure,plot(t,za);
% title('Nc个杂波单元信号叠加时域图');
% xlabel('t');
% ylabel('幅值');
% ya=xcorr(za);%计算自相关函数
% Za=fft(ya(1:N));
% Za=10*log10(abs(Za(1:N/2+1))/sum(abs(Za)));
% figure,plot(Za);
% title('Nc个杂波单元信号叠加频谱幅值归一化');
% xlabel('');
% ylabel('归一化幅值');
end



