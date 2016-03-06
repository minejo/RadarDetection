%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

%探测系统主要解决铁路异物侵限场景，分为3大类，第一类是公跨铁桥，第二类是公铁并行段，第三类是铁道隧道或沿线口崩塌落石
%系统场景只能为其中一种
clear all;
close all; 
clc;
warning off;
c=3e8;
type=3;
%%%%%%%%%%%%%连续波雷达系统参数%%%%%%%%%%%%%%%%%%%
T=80e-6; %连续波扫频周期
f0=20e9; %调频初始频率
B=500e6; %发射机调频带宽
deltaR=c/(2*B); %二维变换后的距离分辨率
deltaV=2; %二维变换后速度维分辨率
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%公跨铁桥场景
if type == 1
   % roadrailcross(T,N,f0,B,deltaR);
end
%公铁并行段场景
if type == 2
   % roadrailparal(T,N,f0,B,deltaR);
end
 
%铁道隧道或沿线口崩塌落石场景
if type == 3
    [search_result,track_head,track_temp,track_normal] =fallstone(T,f0,B,deltaR,deltaV);    
end