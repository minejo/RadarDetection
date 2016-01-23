function [isTrue, Weightmean]= headfindobject(head, one,time_diff,dis_diff,v_diff,fangwei_diff)
%该函数主要判断某点与某轨迹头是否可以形成轨迹，主要通过时间，距离，速度，方位等多方面信息进行关联，
%如果可以，计算多个方面的差异的权重和值，设定距离占30%，时间20%，方位20%，速度30%，权值越小越合适
distance = head(1); %获取轨迹头的距离
velocity = head(2);%获取轨迹头的速度
fangwei = head(3);%获取轨迹头的方位
time = head(4); %获取轨迹头的时间戳

one_distance = one(1); %获取目标的距离
one_velocity = one(2);%获取目标的速度
one_fangwei = one(3);%获取目标的方位
one_time = one(4); %获取目标的时间戳
isTrue = 0;
if( abs(distance-one_distance) <= dis_diff && abs(velocity - one_velocity) <= v_diff && abs(fangwei - one_fangwei) <= fangwei_diff && abs(time-one_time) <= time_diff)
  isTrue = 1;
  Weightmean = 0.3*(distance-one_distance) + 0.2*(time-one_time) + 0.3*(velocity - one_velocity) + 0.2*(fangwei - one_fangwei);%计算权重
end
end