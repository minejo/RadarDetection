%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function BigBeamTrackingWindow = getBigBeamTrackingWindow(BigBeamTrackingObject, disL, disW)
%BigBeamTrackingObject里面存的是要扫描的多个目标，用多行表示，每行分别为[横向距离 纵向距离 纵向速度]
%%TODO: movingTrendL表示横向的运动趋势，可以用来减少扫描窗的范围,默认为0，-1向左，1向右
%disL为目标的平均横向距离
%disW为目标的平均纵向距离
%BigBeamTrackingWindow为计算出来的针对每个目标的扫描窗，分为多行，每行分别为[横向波束位置 纵向波束位置]
global big_beam map_length map_width
beamPos_l = floor(disL / big_beam) + 1;
beamPos_w = floor(disW / big_beam) + 1;
BigBeamTrackingWindow = [];
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