%clear
close all;
%clear;
config = 'hor.mat';
[smart_path, prePath] = SmartDetection(config);
bigscan = BigScan(config);
points = [];
maxLen = 0;
points_num = size(prePath, 2);
for index = 1:points_num
    if size(prePath{index}, 2) > maxLen
        maxLen = size(prePath{index}, 2);
    end
end
theoryPoint = [];
for j = 1:maxLen
    points = [];
    for index = 1:points_num
        if size(prePath{index}, 2) >= j
            points = [points; prePath{index}(1,j) prePath{1,index}(2,j) prePath{1,index}(3,j)];
        end
    end
    if ~isempty(points)
        theoryPoint = [theoryPoint; mean(points(:,1)) mean(points(:,2))];
    end
end
figure
plot(theoryPoint(:,1), theoryPoint(:,2),'k'); 
hold on
plot(smart_path(:,1), smart_path(:,2), 'r*');
axis([0 90 0 60]);
hold on
plot(bigscan(:,1), bigscan(:,2), 'bV');
hold on
 xlabel('探测区域横向坐标/m');
ylabel('探测区域纵向坐标/m');
legend('理论运动轨迹','智能波束扫描','大波束扫描','Location','northwest');