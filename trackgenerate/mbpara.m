function [VV, RR, Ssita] = mbpara(R0, v0, a, sita0, sita_a, sita_v0, t, deltaR, deltaV, deltaSita)
%移动物体参数设置,R0为初始距离，v0为初始速度，接近雷达方向为负，a为加速度，
%sita0为初始角度，sita_a为角度变化加速度，sita_v0为角度变化初始速度,t为时间
%模拟一个物体的多点点迹，输出是多个与该点类似的运动模型参数，模拟一个物体的多点模型
v=v0+a.*t;
R=R0-(v0.*t + 0.5*a.*t.^2);
sita=sita0 + sita_v0.*t + 0.5*sita_a.*t.^2;

n = length(R);
R_error = (rand(1, n) *2-1)* 0.2 * deltaR; %产生随机距离误差
v_error = (rand(1,n)*2-1).*deltaV;%产生随机速度误差
sita_error = (rand(1,n)*2-1).*deltaSita;%产生随机角度误差

R1 = R + R_error + ones(1,n)*deltaR;
V1 = v + v_error;
Sita1 = sita + sita_error;

R_error = (rand(1, n) *2-1)* 0.2 * deltaR; %产生随机距离误差
v_error = (rand(1,n)*2-1).*deltaV;%产生随机速度误差
sita_error = (rand(1,n)*2-1).*deltaSita;%产生随机角度误差

R2 = R + R_error - ones(1,n)*deltaR;
V2 = v + v_error;
Sita2 = sita + sita_error;

VV = [v;V1;V2];
RR = [R;R1;R2];
Ssita = [sita; Sita1; Sita2];
end

