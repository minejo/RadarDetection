%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%
clc
clear all
close all
%模式识别测试，使用frechet distance判断曲线的相似度，同时辅助以速度、大小、位置等信息进行辅助判断
% create data
t = 0:pi/8:2*pi;
y = linspace(1,3,6);
P = [(2:7)' y']+0.3.*randn(6,2);
Q = [t' sin(t')]+2+0.3.*randn(length(t),2);
[cm, cSq] = DiscreteFrechetDist(P,Q);
% plot result
figure
plot(Q(:,1),Q(:,2),'o-r','linewidth',3,'markerfacecolor','r')
hold on
plot(P(:,1),P(:,2),'o-b','linewidth',3,'markerfacecolor','b')
title(['Discrete Frechet Distance of curves P and Q: ' num2str(cm)])
legend('Q','P','location','best')
line([2 cm+2],[0.5 0.5],'color','m','linewidth',2)
text(2,0.4,'dFD length')
for i=1:length(cSq)
  line([P(cSq(i,1),1) Q(cSq(i,2),1)],...
       [P(cSq(i,1),2) Q(cSq(i,2),2)],...
       'color',[0 0 0]+(i/length(cSq)/1.35));
end
axis equal
% display the coupling sequence along with each distance between points
disp([cSq sqrt(sum((P(cSq(:,1),:) - Q(cSq(:,2),:)).^2,2))])