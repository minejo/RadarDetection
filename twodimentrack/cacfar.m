%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

function [hasObject] = cacfar(value,refer,K)
%refer为要检测的参考单元数组，Pf为虚警概率
hasObject=0;
%K=(Pf)^(-1/N)-1;

juage=K*sum(refer);
if(value>juage)
    hasObject=1;
end
end

