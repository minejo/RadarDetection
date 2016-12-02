%SVI-CFAR算法仿真--杂波边缘
clc
clear all
N=24; %参考单元长度
M=1e7; %蒙特卡洛仿真次数
pfa=1e-3;
alpha=0.4;
beta1=10.87;
beta2=10.87;
Nt=12;
KVI=4.56;
KMR=2.9;
SNR_dB=10;
SNR=10.^(SNR_dB./10);
pd_svi=0;
pd_vi=0;
pd_s=0;
pd_so=0;
pd_go=0;
pd_ca=0;

for Nc=0:N
    count_svi=0;
    count_vi=0;
    count_go=0;
    count_ca=0;
    count_so=0;
    count_s=0;        
           for j=1:M
               if(Nc<=N/2)
               lambda=SNR;
               u1=rand(1,Nc);%%xiu gai
               u2=rand(1,N-Nc);
               exp_noise(1:Nc)=log(u1)*(-lambda);
               exp_noise(Nc+1:N)=log(u2)*(-1);

               u=rand(1,2);
               exp_target=log(u(1))*(-1);
               else
                lambda=SNR;
                u1=rand(1,Nc);
                u2=rand(1,N-Nc);
                exp_noise(1:Nc)=log(u1)*(-lambda);
                exp_noise(Nc+1:N)=log(u2)*(-1);
                u=rand(1,2);
                exp_target=log(u(1))*(-lambda);
               end

               %调用svi-cfar方法
                [hasObject_svi ,choice_svi(j)]= svicfar(exp_noise,exp_target,KVI,KMR,pfa,alpha,beta1,beta2,Nt);
                if(hasObject_svi==1)
                    count_svi=count_svi+1;
                end

                %调用vi-cfar方案
%                 [hasObject_vi ,choice_vi(j)]= vicfar(exp_noise,exp_target,KVI,KMR,pfa);
%                 if(hasObject_vi==1)
%                     count_vi=count_vi+1;
%                 end
                %调用ca-cfar方案
                K=pfa^(-1/N)-1;
                hasObject_ca=cacfar(exp_noise,exp_target,K);
                if(hasObject_ca==1)
                    count_ca=count_ca+1;
                end
                 %调用so-cfar方案
                K=pfa^(-1/(N/2))-1;
                hasObject_so=socfar(exp_noise,exp_target,K);
                if(hasObject_so==1)
                    count_so=count_so+1;
                end
                %调用go-cfar方案
                K=pfa^(-1/(N/2))-1;
                hasObject_go=gocfar(exp_noise,exp_target,K);
                if(hasObject_go==1)
                    count_go=count_go+1;
                end
                
                %调用s-cfar方案               
                hasObject_s=scfar(exp_noise,exp_target,alpha,beta1,beta2,Nt);
                if(hasObject_s==1)
                    count_s=count_s+1;
                end
           end
           pd_svi(Nc+1)=count_svi/M;
           %pd_vi(Nc+1)=count_vi/M;
           pd_s(Nc+1)=count_s/M;
           pd_so(Nc+1)=count_so/M;
           pd_go(Nc+1)=count_go/M;
           pd_ca(Nc+1)=count_ca/M;        
       [AB(Nc+1), go(Nc+1), B(Nc+1),  A(Nc+1) ,S(Nc+1)]=getsvichoice(choice_svi);
end

figure;
semilogy(0:N,pd_svi,'r*-');
hold on
% semilogy(0:N,pd_vi,'m+-');
% hold on
semilogy(0:N,pd_s,'ks-');
hold on
semilogy(0:N,pd_ca,'rv-');
hold on
semilogy(0:N,pd_go,'g.-');
%hold on
%semilogy(0:N,pd_so,'k>-');
grid on
xlim([0 24]);
ylim([1e-6 1e-0]);
legend('SVI-CFAR','S-CFAR','CA-CFAR','GO-CFAR');
xlabel('Nc');
ylabel('Pfa');
title('边缘杂波背景下SVI-CFAR性能仿真');

figure;
plot(0:N,AB,'bx-');
hold on
plot(0:N,go,'k>-');
hold on
plot(0:N,B,'r*-');
hold on
plot(0:N,A,'m+-');
hold on
plot(0:N,S,'ks-');
grid on
xlabel('Nc');
legend('AB','GO','B','A','S');
ylabel('选窗概率Pd');
title('边缘杂波背景下SVI-CFAR的选窗策略');

