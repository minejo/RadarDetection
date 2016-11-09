%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function BigBeamTrackingWindow = getBigBeamTrackingWindow(BigBeamTrackingObject)
%BigBeamTrackingObject里面存的是要扫描的多个目标，用多行表示，每行分别为[横向距离 纵向距离 纵向速度]
%BigBeamTrackingWindow为计算出来的针对每个目标的扫描窗，每个目标扫描的范围为周围的九宫格，如果有目标则加入队列。FIFO队列。
end