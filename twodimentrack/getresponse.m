%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

function response = getresponse( map,map_x,map_y,angle,M,T,fs,B,f0)
%根据二维map数组得到所有回波之和,map_x距离轴分辨单元，map_y角度轴分辨单元,map数组中保存的是物体的速度（如果存在),angle为当前扫描角度
distance=size(map,1);
response=0; %回波数据
%匹配角度到一个小区间
if(mod(angle,map_y))
   start=angle-mod(angle,map_y)+1;
else
    start=angle-map_y;
end
for i=1:distance
    for j=start:start+map_y-1
        if(map(i,j)>=0)
            response=response + getdisg(i*map_x, map(i,j),B,f0,T,fs,M);            
        end
    end
end
