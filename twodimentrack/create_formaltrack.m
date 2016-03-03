%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

function [track_temp1, track_normal, ones_result] = create_formaltrack(track_temp, track_normal, ones_result, TT, t)
%根据暂时轨迹与新目标创造正式轨迹，3点即可形成正式轨迹
temp_num = length(track_temp);%临时轨迹的数目
scan_num = size(ones_result,1); %单次扫描结果经过聚合后的数目
time_diff = 2*TT;%目标与最近的轨迹目标相差的时间不能超过两个周期
fangwei_diff = 4; %目标与最近轨迹目标相差的方位不能超过fangwei_diff 度
dis_diff = 3; %目标与最近轨迹目标相差的距离不能超过dis_diff m
v_diff = 3; %目标速度与预计速度相差不能超过v_diff
track_temp1 = track_temp; %由于track_temp处于一级循环中，集合变化导致参数i遍历失败，因而操作副本
for i=1:temp_num
    onetemptrack = track_temp{i}; %获取一个临时轨迹
    scan_result = 1; %假定最符合要求的目标的序号为1
    minWeight = 10000; %初始化最小权重值为一个很大的值
    for j = 1:scan_num
        if(~isempty(ones_result))
            one = ones_result(j,:); %获取一个扫描目标
            [isTrue, Weightmean] = temptrackfindobject(onetemptrack, one, time_diff, dis_diff, v_diff, fangwei_diff,TT,t);%该点是否多个条件都符合，如果符合权重加和为多少
            if(Weightmean < minWeight && isTrue)
                minWeight = Weightmean;
                scan_result = j;
            end
        end
    end
    if(minWeight ~= 10000) %确定找到合适的目标
        formal = [onetemptrack; ones_result(j,:)];
        track_normal = [track_normal formal];%生成正式轨迹并加入到集合中
        track_temp1(i) = []; %删除临时轨迹
        ones_result(j,:) = []; %删除已处理的目标
    end
end
end