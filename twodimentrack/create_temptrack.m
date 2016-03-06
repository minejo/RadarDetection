%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

function [track_temp, track_head1, ones_result1] = create_temptrack(track_temp, track_head, ones_result, TT)
%根据轨迹头，匹配合适的临时轨迹
head_num = size(track_head, 1);%轨迹头的数量
scan_num = size(ones_result,1);%单次扫描结果经过聚合后的数目
time_diff = 2*TT;%轨迹头与目标相差的时间不能超过两个周期
time_diff_min = 0.5*TT;%不能小于一个周期
dis_diff = 4; %轨迹头与目标相差的距离不能超过dis_diff m
v_diff = 3; %轨迹头与目标相差的速度不能超过v_diff
fangwei_diff = 3; %轨迹头与目标相差的方位不能超过fangwei_diff 度
track_head1 = track_head; %由于track_head处于一级循环中，集合变化导致参数i遍历失败，因而操作副本
ones_result1 = ones_result;
k=0;
for i=1: head_num
    head = track_head(i, :); %获取一个轨迹头
    scan_result = 1; %假定最符合要求的目标的序号为1
    minWeignt = 10000;%初始化最小权重值为一个很大的值
    for j = 1:scan_num
        if(~isempty(ones_result1))
            one = ones_result(j,:); %获取一个扫描目标
            [isTrue, Weightmean]= headfindobject(head, one, time_diff,time_diff_min,dis_diff,v_diff,fangwei_diff); %该点是否多个条件都符合，如果符合权重加和为多少
            if(Weightmean < minWeignt && isTrue)
                minWeignt = Weightmean;
                scan_result = j;
            end
        end
    end
    if(minWeignt ~= 10000)%确定找到合适的目标
        temp = [head; ones_result(j,:)];
        track_temp = [track_temp temp];%生成临时轨迹并加入到集合中
        track_head1(i,:) = [];%删除该轨迹头
        ones_result1(j-k,:) = [];%删除该目标
        k=k+1;
    end
    
end
end