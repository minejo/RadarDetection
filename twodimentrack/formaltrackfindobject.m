%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

function  [isTrue, Weightmean] = formaltrackfindobject(oneformaltrack, one, time_diff,time_diff_min, dis_diff, v_diff, fangwei_diff,TT,t)
%该函数主要用于判断某点与某正式轨迹能否关联，由于正式轨迹大于等于3点，因此为了减少运算量，取正式轨迹后三点用于预测下一点的信息，
%然后在预测的位置设置相应波门，在波门内寻找目标，由于目标可能拥有多个，此时可以通过多方面的信息进行参考，比如时间，距离，速度，方位
%等信息，计算多个方面的差异的权重和值，设定距离占30%，时间20%，方位20%，速度30%，权值越小越合适

%取出正式轨迹的后三点
p1 = oneformaltrack(end-2,:);
p2 = oneformaltrack(end-1,:);
p3 = oneformaltrack(end,:);
%根据三个点预测第四个点
p4 = threePredict(p1, p2, p3, t);
%p4 = twoPredict(p2,p3,t);

distance = p4(1); %获取预测点的距离
velocity = p4(2);%获取预测点的速度
fangwei = p4(3);%获取预测点的方位
time = p4(4); %获取预测点的时间戳

one_distance = one(1); %获取目标的距离
one_velocity = one(2);%获取目标的速度
one_fangwei = one(3);%获取目标的方位
one_time = one(4); %获取目标的时间戳
%根据设置合理的误差范围来判断实际点与预测点是否符合
isTrue = 0;
Weightmean = 1;
if( abs(distance-one_distance) <= dis_diff && abs(velocity - one_velocity) <= v_diff && abs(fangwei - one_fangwei) <= fangwei_diff && abs(time-one_time) <= time_diff && abs(p3(4)-one_time) >= time_diff_min)
  isTrue = 1;
  Weightmean = 0.3*abs(distance-one_distance) + 0.4*abs(velocity - one_velocity) + 0.3*abs(fangwei - one_fangwei);%计算权重
end
end