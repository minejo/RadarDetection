%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [hasObject] = gocfar(refer,value)
%data为要检测的数组，i为要检测的单元，N为检测单元两边的比较单元数
global Pfa
N = length(refer);
K=(Pfa)^(-1/(N/2))-1;
hasObject=0;

left=sum(refer(1:N/2));
right=sum(refer(N/2+1:N));
juage=max(left,right)*K;
if(value>juage)
    hasObject=1;
end
end

