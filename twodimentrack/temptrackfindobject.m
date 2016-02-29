function [isTrue, Weightmean] = temptrackfindobject(onetemptrack, one, time_diff, dis_diff, v_diff, fangwei_diff,TT,t)
%该函数主要判断某点与某临时轨迹能否关联，形成正式轨迹，由于临时轨迹有两点，可以通过该两点预测下一个点的信息，然后设立
%相应的波门，在波门内寻找目标，由于波门内可能有多个目标，此时可以通过多个方面的信息进行参考，比如时间，距离，速度，方位
%等信息，计算多个方面的差异的权重和值，设定距离占30%，时间20%，方位20%，速度30%，权值越小越合适

%一个临时轨迹有两个点，分别取出来
point1 = onetemptrack(1,:);
point2 = onetemptrack(2,:);
%根据两个点预测第三个点
point3 = twoPredict(point1, point2,t);
distance = point3(1); %获取预测点的距离
velocity = point3(2);%获取预测点的速度
fangwei = point3(3);%获取预测点的方位
time = point3(4); %获取预测点的时间戳


one_distance = one(1); %获取目标的距离
one_velocity = one(2);%获取目标的速度
one_fangwei = one(3);%获取目标的方位
one_time = one(4); %获取目标的时间戳
%根据设置合理的误差范围来判断实际点与预测点是否符合
isTrue = 0;
if( abs(distance-one_distance) <= dis_diff && abs(velocity - one_velocity) <= v_diff && abs(fangwei - one_fangwei) <= fangwei_diff && abs(time-one_time) <= time_diff)
  isTrue = 1;
  Weightmean = 0.3*(distance-one_distance) + 0.2*(time-one_time) + 0.3*(velocity - one_velocity) + 0.2*(fangwei - one_fangwei);%计算权重
end
end