%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

function  [isTrue, Weightmean] = formaltrackfindobject(oneformaltrack, one, time_diff, dis_diff, v_diff, fangwei_diff,TT,t)
%该函数主要用于判断某点与某正式轨迹能否关联，由于正式轨迹大于等于3点，因此为了减少运算量，取正式轨迹后三点用于预测下一点的信息，
%然后在预测的位置设置相应波门，在波门内寻找目标，由于目标可能拥有多个，此时可以通过多方面的信息进行参考，比如时间，距离，速度，方位
%等信息，计算多个方面的差异的权重和值，设定距离占30%，时间20%，方位20%，速度30%，权值越小越合适

%取出正式轨迹的后三点
p1 = oneformaltrack(end-2,:);
p2 = oneformaltrack(end-1,:);
p3 = oneformaltrack(end,:);
%根据三个点预测第四个点
p4 = threePredict(p1, p2, p3, t);

end