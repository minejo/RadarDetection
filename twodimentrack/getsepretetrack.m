%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

function getsepretetrack(track_normal)
%根据正式轨迹的cell集合画出各个单独轨迹
tracknum = length(track_normal);%单独轨迹数
for i = 1:tracknum
   figure;
   track = track_normal{i};%获取一个轨迹 
   distance = track(:,1);%获取该轨迹的距离维
   fangwei = track(:,3);%获取方位维
   polar(fangwei/180*pi, distance, 'r');
end