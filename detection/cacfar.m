%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [hasObject] = cacfar(data,value,K)
%data为要检测的参考单元数组，r为保护单元数，Pf为虚警概率
N = length(data);
hasObject=0;
%K=(Pf)^(-1/N)-1;

juage=K*sum(data);
if(value>juage)
    hasObject=1;
end
end

