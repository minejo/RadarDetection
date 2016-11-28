%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%通过反变换法生产Serliing I型截面积RCS
function rcs = generateRcs(RCS, len)
x = rand(1, len);
rcs = -RCS*log(x)/log(exp(1));
end