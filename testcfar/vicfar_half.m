%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%主要处理边界情况，只有半边扫描窗的情况
function [ hasObject, choice ] = vicfar_half(refer,value, Pfa)
%refer 为参考单元数据，value为有数据的点 ,KVI统计量VI阀值门限，统计量MR阀值门限
global KVI KMR
%Pfa = 1e-2;
N=length(refer); %参考单元长度
VI =1;
hasObject=0; %是否检测出目标
avg_x=mean(refer(1:N));
for i=1:N
    VI=VI+1/(N-1)*(refer(i)-avg_x)^2/avg_x^2;
end

isAve=1;  %半划窗是否是均匀环境，1为均匀

if(VI>KVI)
    isAve = 0;
end

CN=Pfa^(-1/N)-1;
CN2=Pfa^(-1/(N/2))-1;

%选用第一种策略
if(isAve == 1)
    hasObject=cacfar(refer,value,CN);
    choice=1;
else
    %选用第二种策略    
    hasObject=scfar(refer,value);
    choice=3;
end
end

