%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%给定坐标和大小，画一个
function  plotObject(x,y,r)
%PLOTOBJECT Summary of this function goes here
%   Detailed explanation goes here
figure(2)
rectangle('Position',[x-r,y-r,2*r,2*r])
end

