%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%
close all;
clear all;
%建立多目标运动物体模型
deltat=0.2;
t=0:deltat:3;


%   物体运动模型设置     %

%[实时速度，实时距离，实时角度] = mbpara(初始距离，初始速度，加速度，初始角度，角度变化加速度，角度变化初始速度, 散射体的距离范围、速度范围、角度范围）
objectinfo = [
    140, 0, 3, 98, 2, 2, 1, 2, 2;
    70, -4, -3, 50 ,1, 1, 1, 2, 2;
    130, 2, 2,  90, 1, 2, 2, 2, 2    
    ];

n = size(objectinfo, 1);
[distanceData, velocityData, angleData] = getmultidata(t, objectinfo);
%plot data
for i = 1:3*n
    if(mod(i,3) == 1)
        polar(angleData(i,:)/180*pi, distanceData(i,:), '*');
    elseif mod(i,3) == 2
        polar(angleData(i,:)/180*pi, distanceData(i,:), 'r');
    else
        polar(angleData(i,:)/180*pi, distanceData(i,:), 'g');
    end
    hold on
end

%点迹聚合
distanceDoor = 4; %距离门
angleDoor=3; %方位门
velocityDoor = 2; %速度门
object = cell(1,length(t)); %每个扫描段的目标凝聚结果
figure
for n = 1:length(t)
    X=[distanceData(:,n) [velocityData(:,n) angleData(:,n)]];
    [class, type] = dbscan(X,2,5);
    clusternum = class(end);%簇的个数
    objectnum = size(X,1); %出现目标的个数
    objectcell=cell(1, clusternum); %存放各个簇的cell单元
    objectsize = zeros(1, clusternum);%每个簇的物体大概尺寸
    %object = cell(1,length(t));


    %把目标分别分到对应的cell簇单元中
    for i = 1:objectnum
        if(isempty(objectcell{class(i)}))
            objectcell{class(i)} = X(i,:);
        else
            objectcell{class(i)} = [objectcell{class(i)};X(i,:)];
        end
    end
    %更新每个簇的目标大概尺寸，根据k-means方法目标凝聚
    for i = clusternum:-1:1
        dis = objectcell{i}(:,1); %取簇中的距离维
        vel = objectcell{i}(:,2); %取簇中的速度维
        angle = objectcell{i}(:,3);%取簇中方位维
        objectsize = max(dis)-min(dis);
        if(isempty(object{n}))
            object{n} = [mean(dis) mean(vel) mean(angle) objectsize];
        else
            object{n} = [object{n};mean(dis) mean(vel) mean(angle) objectsize];
        end
        polar(mean(angle)/180*pi ,mean(dis),'*');
        hold on;
    end

end

