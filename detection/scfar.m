%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function hasObject = scfar(refer,value)
%data为要检测的数组，i为要检测的单元，N为检测单元两边的比较单元数，r为保护单元数，Pf为虚警概率
global alpha beta scfar_r
beta1 = beta;
beta2 = beta;
S0=[];
S1=[];
hasObject=0;
N=length(refer);
Nt = N - scfar_r - 1;
for t=1:N
   if(refer(t)>=alpha*value)
       S1=[S1 refer(t)];
   else
       S0=[S0 refer(t)];
   end
end

n0=length(S0);
if(n0 > Nt)
   if(beta1/n0*sum(S0)<value)
       hasObject=1;
   end
else
   if(beta2/N*sum(refer)<value)
       hasObject=1;
   end
end 

end

