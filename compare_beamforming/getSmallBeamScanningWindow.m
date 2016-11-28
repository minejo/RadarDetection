%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SmallBeamTrackingWindow = getSmallBeamScanningWindow(objects_l, objects_w)
%根据要跟踪的目标，确定小波束的顺序扫描窗
%objects_l为大波束里扫描到的多个物体的横向距离
%objects_w为大波束里扫描到的多个物体的纵向距离
global small_beam big_beam map_length map_width
Object_l = objects_l(1); %由于大波束内无法分辨物体的方位向，因此每个目标的纵向距离相等，取大波束的中心
minObejctW = min(objects_w); %所有目标的纵向距离最小的
maxObjectW = max(objects_w);
minBeamPos_l = floor((Object_l - big_beam / 2) / small_beam) + 1;%大波束内横向小波束的最小位置
maxBeamPos_l = floor((Object_l + big_beam / 2) / small_beam);%大波束内横向小波束的最大位置
minBeamPos_w = floor(minObejctW / small_beam) + 1;
maxBeamPos_w = floor(maxObjectW / small_beam) + 1;
SmallBeamTrackingWindow = zeros((maxBeamPos_w - minBeamPos_w + 1) * (maxBeamPos_l - minBeamPos_l + 1), 2); %保存所有小波束的扫描窗，分为多行，每行分别为[横向波束位置 纵向波束位置]
index = 1;
for j = 1:maxBeamPos_w - minBeamPos_w + 1
    for i = 1:maxBeamPos_l - minBeamPos_l + 1
        SmallBeamTrackingWindow(index, :) = [minBeamPos_l - 1 + i minBeamPos_w - 1 + j];
        index = index + 1;
    end
end
end