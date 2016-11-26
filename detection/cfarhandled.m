%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  [hasObject, objects] = cfarhandled(data, beamPos_l, beamPos_w, beam_type)
%通过距离维与速度维各做一次cacfar，综合判断是否出现目标
global M N deltaR deltaV big_beam small_beam Rmax T f0 c map_length map_width
objects = []; %单波束内所有物体,分为三列，分别为[横坐标 纵坐标 速度];
CFAR_N_w=8; %速度维参考窗长度
CFAR_N_l=16; %距离维参考窗长度
window_r = 1;
hasObject = 0;
position = [];
pfa_d = 1e-6;
pfa_v = 1e-6;
K1=(pfa_d)^(-1/CFAR_N_l)-1; %虚警门限
K2=(pfa_v)^(-1/CFAR_N_w)-1;
MaxPower = 0;
result = [];
for i = 1:M/2
    for j = 1:N/2
        %fprintf('理论距离%f, 速度%f\n', j*2*Rmax/N, i*c/(T*M*2*f0));
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
        hasObject_w = cacfar(referWindow_w, value, K2);
        
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
            if beam_type == 1
                dis_l = (beamPos_l - 1)* big_beam + 0.5 * big_beam;
            else
                dis_l = (beamPos_l - 1)* small_beam + 0.5 * small_beam;
            end
            dis_w = j*2*Rmax/N;
            vel = i*c/(T*M*2*f0);
            if MaxPower < data(i, j)
                MaxPower = data(i,j);
            end
            if( dis_l < map_length && dis_w < map_width)
                result = [result;  dis_l dis_w vel];
                position = [position; i j];
            end
        end
    end
end
for p = 1: size(result, 1)
    i = position(p, 1);
    j = position(p, 2);
    if data(i,j) >=  0.5*MaxPower
        %%%%%%%%%%%%%%%%判断该点是否是顶点%%%%%%%%%%%%%%%%%%%%
        if(i>1&&i<M&&j>1&&j<N)
            isTop= (data(i,j) > data(i+1,j)) && (data(i,j) > data(i-1,j)) && (data(i,j) > data(i,j-1)) && (data(i,j) > data(i,j+1));
        end
        if isTop == 1
            testLen = 20;
            for k = j - testLen: j + testLen
                if( k > 0 && k <= N/2 && data(i, k) >= 0.45*data(i,j))
                    dis_w = k*2*Rmax/N;
                    vel = i*c/(T*M*2*f0);
                    objects = [objects;  dis_l dis_w vel];
                end
            end
        end
    end
end
objects = unique(objects, 'rows');
%figure(8);
% if ~isempty(objects)
%     plot(objects(:,2), objects(:,3), '*r');
%     axis([0 300 0 90]);
% end
end