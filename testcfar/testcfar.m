close all;
CFAR_N_w=8; %速度维参考窗长度
CFAR_N_l=16; %距离维参考窗长度
load('mapdata.mat');
objects = []; %单波束内所有物体
window_r = 1;
pfa_d = 1e-6;
pfa_v = 5e-8;
K1=(pfa_d)^(-1/CFAR_N_l)-1; %虚警门限
K2=(pfa_v)^(-1/CFAR_N_w)-1;
M = 46;
N = 2000;
hasObject = 0;
big_beam = 9;
small_beam = 3;
Rmax = 300;
T = 8e-5;
c = 3e8;
f0 = 2e10;


for i = 1:M/2
    for j = 1:N/2
        %速度维cfar
        referWindow_w = [];
        value = data(i,j);
        if(i>(CFAR_N_w/2+window_r) && i <= (M-CFAR_N_w/2-window_r))
            referWindow_w=[data(i-CFAR_N_w/2-window_r:i-window_r-1,j)' data(i+window_r+1:i+CFAR_N_w/2+window_r,j)'];
        elseif (i <= CFAR_N_w/2+window_r)
            referWindow_w=data(i+window_r+1:i+CFAR_N_w/2+window_r,j)';
        else
            referWindow_w=data(i-CFAR_N_w/2-window_r:i-window_r-1,j)';
        end
        hasObject_w = cacfar(referWindow_w, value,  K2);
        
        %距离维cfar
        referWindow_l = [];
        %testplot = [];
        if(j>(CFAR_N_l/2+window_r) && j <= (N - CFAR_N_l / 2 - window_r))
            referWindow_l=[data(i,j-CFAR_N_l/2-window_r:j-window_r-1)' data(i, j+window_r+1:j+CFAR_N_l/2+window_r)'];
            %testplot = [data(i,j-CFAR_N_l/2-window_r:j-window_r-1) zeros(1,window_r) data(i,j) zeros(1,window_r) data(i, j+window_r+1:j+CFAR_N_l/2+window_r)];
        elseif (j <= CFAR_N_l/2+window_r)
            referWindow_l=data(i, j+window_r+1:j+CFAR_N_l/2+window_r)';
            %testplot = [data(i,j) zeros(1,window_r) data(i, j+window_r+1:j+CFAR_N_l/2+window_r)];
        else
            referWindow_l=data(i, j-CFAR_N_l/2-window_r:j-window_r-1)' ;
            %testplot=[data(i, j-CFAR_N_l/2-window_r:j-window_r-1) zeros(1,window_r) data(i,j)] ;
        end
        hasObject_l = cacfar(referWindow_l, value, K1);
        
        if (hasObject_l * hasObject_w == 1)
            hasObject = 1;
            %%%%%%%%%%%%%%%%判断该点是否是顶点%%%%%%%%%%%%%%%%%%%%
            isTop=1;
            if(i>1&&i<M&&j>1&&j<N/2)
                isTop= (data(i,j) > data(i+1,j)) && (data(i,j) > data(i-1,j)) && (data(i,j) > data(i,j-1)) && (data(i,j) > data(i,j+1));
            end
            if isTop == 1
                %toTestPoints = data(i, j-20:j+20);
                testLen = 20;
                for k = j - 20: j + 20
                    if(data(i, k) >= 0.45*value)
                        dis = k*2*Rmax/N;
                        vel = i*c/(T*M*2*f0);                        
                       objects = [objects; dis vel]; 
                    end
                end
                
            end
        end
    end
end
unique(objects, 'rows');
x_distance=(linspace(0,Fs,N));
y_velocity=linspace(0, 1/T, M);
meshx=x_distance(1:N/2)*c/(2*B/T);
figure(1);
contour(meshx,c*y_velocity/(2*f0),data(:,1:N/2));
figure(3);
mesh(meshx,c*y_velocity/(2*f0),data(:,1:N/2));
title('差频信号二维频谱仿真图');
xlabel('distance/m');
ylabel('velocity/(m/s)');

figure(2);
plot(objects(:,1), objects(:,2), '*r');
axis([0 300 0 90]);
