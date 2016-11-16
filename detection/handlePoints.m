%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ objectCell, clusternum ] = handlePoints(points, minPts, distanceWDoor, velocityDoor, type)
%HANDLEPOINTS Summary of this function goes here
% 根据一个周期收集到的点迹进行集中处理，返回当前周期的物体数量，大小和综合点信息
%points为所有的点迹信息，minPts，distanceLDoor,
%velocityDoor为DBSCAN聚合用的参数，type为波束的类型，1为大波束，2为小波束
global big_beam small_beam
pointsnum = size(points, 1); %所有点迹的个数

%开始点迹凝聚
if type == 1
    [class, type] = dbscan(points, minPts, sqrt(distanceWDoor^2 + (big_beam/2)^2 + velocityDoor^2));
else
    [class, type] = dbscan(points, minPts, sqrt(distanceWDoor^2 + (small_beam/2)^2 + velocityDoor^2));
end
clusternum = max(class); %聚合后簇的数量
objectCell = cell(1, clusternum);%存放各个簇的cell单元
%objectSize = zeros(1, clusternum); %保存各个簇的大概尺寸，用户后续的点迹过滤
%把目标根据dbscan分类后的class变量分别分到对应的cell簇单元中
for j = 1:pointsnum
    if class(j) ~= -1
        if isempty(objectCell{class(j)})
            objectCell{class(j)} = points(j,:);
        else
            objectCell{class(j)} = [objectCell{class(j)}; points(j,:)];
        end
    end
end
end

