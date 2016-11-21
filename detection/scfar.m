%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function hasObject = scfar(data,value,alpha,beta1,beta2,Nt)
%data为要检测的数组，i为要检测的单元，N为检测单元两边的比较单元数，r为保护单元数，Pf为虚警概率
S0=[];
S1=[];
hasObject=0;

N=length(data);
for t=1:N
   if(data(t)>=alpha*value)
       S1=[S1 data(t)];
   else
       S0=[S0 data(t)];
   end
end

n0=length(S0);
if(n0>Nt)
   if(beta1/n0*sum(S0)<value)
       hasObject=1;
   end
else
   if(beta2/N*sum(data)<value)
       hasObject=1;
   end
end 

end

