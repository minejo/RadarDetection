%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [hasObject, objects_l, objects_w, objects_v] = BeamFindObject(beamPos_l, beamPos_w, beam_type)
%判断波束所在方位有无目标，beamPos_l波束横向的位置，beamPos_w波束纵向的位置，beam_type波束的类型，1为大波束，2为小波束
global M N
hasObject = 0;
% if beam_type == 1
%     num_l = big_beam / map_l; %大波束内横向有多少个分辨单元
%     num_w = big_beam / map_w; %大波束内纵向有多少个分辨单元
% else
%     num_l = small_beam / map_l; %小波束内横向有多少个分辨单元
%     num_w = small_beam / map_w; %小波束内纵向有多少个分辨单元
% end
objects_l = []; %单波束内所有物体的横坐标，每行代表一个物体
objects_w = []; %单波束内所有物体的纵坐标，每行代表一个物体
objects_v = []; %单波束内所有物体的速度，每行代表一个物体
% for j = 1:num_w
%     for i = 1:num_l
%         index_l = fix((beamPos_l - 1) * num_l + i);
%         index_w = fix((beamPos_w - 1) * num_w + j);
%         if(map(index_l, index_w) ~= 1000)%TODO:改用回波处理算法，目前为了测试
%             hasObject = 1;
%             if beam_type == 1
%                 objects_l = [objects_l;(beamPos_l - 1) *  big_beam + 0.5 * big_beam];
%             else
%                 objects_l = [objects_l;(beamPos_l - 1) *  small_beam + 0.5 * small_beam];
%             end
%             objects_w = [objects_w; index_w * map_w];
%             objects_v = [objects_v; map(index_l, index_w)];
%         end
%     end
% end
response = getresponse(beamPos_l, beamPos_w, beam_type);
if response
    %添加噪声与杂波
    SNR=1; %热噪声信噪比
    %response = awgn(response, SNR);
    %添加杂波信号
    za=zeros(M,N);
    for k=1:M
        za(k,:)=wbfb(1.5,2.2);
    end
    %response = response + (za);
    %%%%%%%%%%对差频信号进行二维fft变换%%%%%%%%%
    data = after2fft(response); %二维变换后的矩阵
    data=abs(data);
    %去除低频率的杂波与静止物体
    for p=1:N
        data(1,p)=data(2,p);
    end
    %%%%%%%%%%%%%CFAR处理%%%%%%%%%%%%%%%
    [hasObject, objects_l, objects_w, objects_v] = cfarhandled(data,beamPos_l, beamPos_w, beam_type);
end
end