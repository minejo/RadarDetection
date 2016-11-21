function [hasObject] = gocfar( data,value,K )
%data为要检测的数组，i为要检测的单元，N为检测单元两边的比较单元数，r为保护单元数，Pfa为虚警概率
N = length(data);
%K=(Pfa)^(-1/(N/2))-1;
hasObject=0;

left=sum(data(1:N/2));
right=sum(data(N/2+1:N));
juage=max(left,right)*K;
if(value>juage)
    hasObject=1;
end
end

