function fft2 =after2fft(response,N,fs,T,B,f0)
%返回二维fft变换后的矩阵
c=3e8;
M=size(response,1); %积累周期
fft1=zeros(M,N);
fft2=zeros(M,N);


%一维fft变换
for k=1:M
  fft1(k,:)=fft(response(k,:),N);
end

%二维fff变换
for i=1:N
    fft2(:,i) = fft(fft1(:,i),M);
end
% x_distance=(linspace(0,fs*(N-1)/N,N));
% y_velocity=linspace(0, 1/T*(M-1)/M, M);
% meshx=x_distance(1:N/2)*c/(2*B/T);
% mesh(meshx,c*y_velocity/(2*f0),(abs(fft2(:,1:N/2))));
% title('差频信号二维频谱仿真图');
% xlabel('distance/m');
% ylabel('velocity/(m/s)');
% figure;
% subplot(211)
% test=abs((fft1(1,:)));
% plot(linspace(0,fs,N)*c/(2*B/T),test);
% title('理想回波信号的一维频谱仿真图');
% xlabel('距离/m');
% ylabel('幅度');
% grid on;axis tight;
% 
% subplot(212)
% plot(1:M,real(fft1(:,234)));
% hold
% plot(1:M,imag(fft1(:,234)),'r--');
% title('一维处理结果的相位调制图');
% xlabel('积累周期k');
% ylabel('相位角度');
% legend('实部','虚部');
%figure resize
% set(gcf,'Position',[100 100 260 220]);
% set(gca,'Position',[.13 .17 .80 .74]);  %调整 XLABLE和YLABLE不会被切掉
% figure_FontSize=8;
% set(get(gca,'XLabel'),'FontSize',figure_FontSize,'Vertical','top');
% set(get(gca,'YLabel'),'FontSize',figure_FontSize,'Vertical','middle');
% set(findobj('FontSize',10),'FontSize',figure_FontSize);
% set(findobj(get(gca,'Children'),'LineWidth',0.5),'LineWidth',2);
end
