function [ v1, R1, sita1 ] = obmutipoint( R,v, sita, deltaR, deltaV, deltaSita, deltat )
%模拟一个物体的多点点迹，输入是一个物体的运动模型参数，输出是多个与该点类似的运动模型参数，模拟一个物体的多点模型
%v是实时速度数组，R是实时距离数组，sita是实时角度数组，deltaR为平均距离误差
n = length(R);
R_error = (rand(1, n) *2-1)* deltaR; %产生随机距离误差
v_error = (rand(1,n)*2-1).*deltaV;%产生随机速度误差
sita_error = (rand(1,n)*2-1).*deltaSita;%产生随机角度误差
v1=zeros(1,n);
R1=zeros(1,n);
sita1=zeros(1,n);
for i=1:n
    R1(i) = R(i) + deltaR + R_error(i);
    v1(i) = v(i) + v_error(i);
    sita1(i) = sita(i) + sita_error(i);
end
end

