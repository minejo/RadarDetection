%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

function [track_normal, ones_result] = maintain_formaltrack(track_normal, ones_result, TT, t)
%轨迹维持函数，判断一个点与正式轨迹是否匹配。主要通过获取正式轨迹后三点，进行轨迹预测，然后与所测点进行
%比较，判断是否在误差范围内
formal_num = length(track_normal); %正式轨迹的数目
scan_num = size(ones_result, 1); %单次扫描结果经过聚合后的数目
time_diff = 2*TT; %目标与最近的轨迹目标相差的时间不能超过两个周期
fangwei_diff = 5; %目标与最近轨迹目标相差的方位不能超过fangwei_diff 度
dis_diff = 10; %目标与最近轨迹目标相差的距离不能超过dis_diff m
v_diff = 5; %目标速度与预计速度相差不能超过v_diff
track_normal1 = track_normal; %由于track_normal处于一级循环中，集合变化导致参数i遍历失败，因而操作副本
for i=1:formal_num
    oneformaltrack = track_normal{i}; %获取一个正式轨迹
    scan_result = 1; %假定最符合要求的目标的序号为1
    minWeight = 10000; %初始化最小权重值为一个很大的值
    for j = 1:scan_num
        one = ones_result(j,:); %获取一个扫描目标
        [isTrue, Weightmean] = formaltrackfindobject(oneformaltrack, one, time_diff, dis_diff, v_diff, fangwei_diff,TT,t);%该点是否多个条件都符合，如果符合权重加和为多少
        if(Weightmean < minWeight && isTrue)
            minWeight = Weightmean;
            scan_result = j;
        end
    end


end