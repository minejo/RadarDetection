%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

function [ R, V,  SITA] = getmultidata(t, objectinfo)
%objectinfo为保存所有物体信息的矩阵，一行为一个物体，分别有初始距离，初始速度，加速度，初始角度，角度变化加速度，角度变化初始速度等信息，
%之后为每个物体周围生成N个散射体目标，模拟多个散射点，结果返回所有点的实时距离、速度、方位信息
originobnum = size(objectinfo, 1); %原始目标数目
n = length(t);
V = zeros(3*originobnum, n);
R = zeros(3*originobnum, n);
SITA = zeros(3*originobnum, n);
obcount = 1;
for i=1:originobnum
    Ri = objectinfo(i,1);
    Vi = objectinfo(i,2);
    ai = objectinfo(i,3);
    Sitai = objectinfo(i,4);
    Sita_ai = objectinfo(i,5);
    Sita_v0i = objectinfo(i,6);
    deltaRi = objectinfo(i,7);
    deltaVi = objectinfo(i,8);
    deltaSitai = objectinfo(i,9);
    [V(obcount:obcount+2, :), R(obcount:obcount+2, :), SITA(obcount:obcount+2, :)] = mbpara(Ri, Vi, ai, Sitai, Sita_ai, Sita_v0i, t, deltaRi, deltaVi, deltaSitai);
    obcount = obcount + 3;
end 
end  

