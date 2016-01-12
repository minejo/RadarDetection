function [v R sita] = mbpara(R0, v0, a, sita0, sita_a, sita_v0)
%移动物体参数设置,R0为初始距离，v0为初始速度，接近雷达方向为负，a为加速度，
%sita0为初始角度，sita_a为角度变化加速度，sita_v0为角度变化初始速度
v=v0+a.*t;
R=R0-(v0.*t + 0.5*a.*t.^2);
sita=sita0 + sita_v0.*t + 0.5*sita_a.*t.^2;
end

