%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function BigBeamTrackingWindow = getBigBeamTrackingWindow(BigBeamTrackingObject)
%BigBeamTrackingObject里面存的是要扫描的多个目标，用多行表示，每行分别为[横向距离 纵向距离 纵向速度]
%%TODO: movingTrendL表示横向的运动趋势，可以用来减少扫描窗的范围,默认为0，-1向左，1向右
%BigBeamTrackingWindow为计算出来的针对每个目标的扫描窗，分为多行，每行分别为[横向波束位置 纵向波束位置]
global big_beam map_length map_width
objectNum = size(BigBeamTrackingObject, 1);
BigBeamTrackingWindow = [];
for i = 1:objectNum
    singleObject = BigBeamTrackingObject(i, :); %单个目标信息，[L W V]
    beamPos_l = floor(singleObject(1) / big_beam) + 1;
    beamPos_w = floor(singleObject(2) / big_beam) + 1;
    
    %处理的时候需要考虑极端的情况，比如波束处于左上，左下，右上，右下，还有位于边界情况下的扫描窗情况
    if beamPos_l == 1
        if beamPos_w == floor(map_width / big_beam) %左下
            BigBeamTrackingWindow = [beamPos_l beamPos_w; beamPos_l+1 beamPos_w];
        else
            BigBeamTrackingWindow = [beamPos_l beamPos_w;
                beamPos_l+1 beamPos_w;
                beamPos_l beamPos_w+1;
                beamPos_l+1 beamPos_w+1];
        end
    else
        if beamPos_l == floor(map_length / big_beam)
            if beamPos_w == floor(map_width / big_beam) %右下
                BigBeamTrackingWindow = [beamPos_l beamPos_w; beamPos_l-1 beamPos_w];
            else
                BigBeamTrackingWindow = [beamPos_l beamPos_w;
                    beamPos_l-1 beamPos_w;
                    beamPos_l beamPos_w-1;
                    beamPos_l-1 beamPos_w-1];
            end
        else%中间的情形
            if beamPos_w == floor(map_width / big_beam)
                BigBeamTrackingWindow = [beamPos_l-1 beamPos_w; beamPos_l beamPos_w; beamPos_l+1 beamPos_w];
            else
                BigBeamTrackingWindow = [beamPos_l-1 beamPos_w; beamPos_l beamPos_w; beamPos_l+1 beamPos_w;
                    beamPos_l-1 beamPos_w+1; beamPos_l beamPos_w+1; beamPos_l+1 beamPos_w+1];
            end
        end
    end
end
end