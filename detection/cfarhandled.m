%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  [hasObject, objects_l, objects_w, objects_v] = cfarhandled(data, beamPos_l, beamPos_w, beam_type)
%通过距离维与速度维各做一次cacfar，综合判断是否出现目标
global M N CFAR_N_l CFAR_N_w window_r deltaR deltaV big_beam small_beam Rmax T f0 c Pfa
objects_l = []; %单波束内所有物体的横坐标，每行代表一个物体
objects_w = []; %单波束内所有物体的纵坐标，每行代表一个物体
objects_v = []; %单波束内所有物体的速度，每行代表一个物体

hasObject = 0;
for i = 1:M
    for j = 1:N/2
        %速度维cfar
        referWindow_w = [];
        value = data(i,j);
        if(i>(CFAR_N_w/2+window_r) && i <= (M-CFAR_N_w/2-window_r))
            referWindow_w=[data(i-CFAR_N_w/2-window_r:i-window_r-1,j)' data(i+window_r+1:i+CFAR_N_w/2+window_r,j)'];
        elseif (i==1 || i ==2)
            referWindow_w=data(i+window_r+1:i+CFAR_N_w+window_r,j)';
        elseif(2<i && i<=CFAR_N_w/2+window_r)
            referWindow_w=[data(1:i-window_r-1,j)' data(i+window_r+1:CFAR_N_w+2*window_r+1,j)'];
        elseif(i<M-1&&i>M-CFAR_N_w/2-window_r)
            referWindow_w=[data(-2*window_r-CFAR_N_w+M:i-window_r-1,j)' data(i+window_r+1:M,j)'];
        elseif( i==M || i==M-1)
            referWindow_w=data(i-CFAR_N_w-window_r:i-window_r-1,j)';
        end
        hasObject_w = gocfar(referWindow_w, value, Pfa^(-1/(length(referWindow_w)/2))-1);
        %距离维cfar
        referWindow_l = [];
        if(j>(CFAR_N_l/2+window_r)&&j<=N-CFAR_N_l/2-window_r)
            referWindow_l=[data(i,j-CFAR_N_l/2-window_r:j-window_r-1) data(i,j+window_r+1:j+CFAR_N_l/2+window_r)];
        elseif (j==1 || j ==2)
            referWindow_l=data(i,j+window_r+1:j+CFAR_N_l+window_r);
        elseif(2<j && j<=CFAR_N_l/2+1)
            referWindow_l=[data(i,1:j-window_r-1) data(i,j+window_r+1:CFAR_N_l+2*1+window_r)];
        elseif(j<N-1&&j>N-CFAR_N_l/2-1)
            referWindow_l=[data(i,-2*window_r-CFAR_N_l+N:j-window_r-1) data(i,j+window_r+1:N)];
        elseif( j==N || j==N-1)
            referWindow_l=data(i,j-CFAR_N_l-window_r:j-window_r-1);
        end
       % [hasObject_l, choice] = vicfar(referWindow_l, data(i, j));
       [hasObject_l, choice] = vicfar(referWindow_l, value);
        %%%%%%%%%%%%%%%%判断该点是否是顶点%%%%%%%%%%%%%%%%%%%%
       % isTop=1;
%         if(i>1&&i<M&&j>1&&j<N/2)
%             isTop= (data(i,j) > data(i+1,j)) && (data(i,j) > data(i-1,j)) && (data(i,j) > data(i,j-1)) && (data(i,j) > data(i,j+1));
%         end
       
        
        if (hasObject_l ) == 1
            hasObject = 1;
            objects_w = [objects_w; j*2*Rmax*(N-1)/(N*N)];
            if beam_type == 1
                objects_l = [objects_l; (beamPos_l - 1)* big_beam + 0.5 * big_beam];
            else
                objects_l = [objects_l; (beamPos_l - 1)* small_beam + 0.5 * small_beam];
            end
            objects_v = [objects_v; i*c*(M-1)/(T*M*M*2*f0)];
        end
    end
end