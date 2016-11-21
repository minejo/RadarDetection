%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function response = getresponse(beamPos_l, beamPos_w, beam_type)
%得到某个波束内的回波信号，beamPos_l,
%beamPos_w分别代表波束的横向位置和纵向位置，beam_type为波束类型，1为大波束，2为小波束
global map_l map_w big_beam small_beam
response = 0;
if beam_type == 1
    num_l = big_beam / map_l; %大波束内横向有多少个分辨单元
    num_w = big_beam / map_w; %大波束内纵向有多少个分辨单元
else
    num_l = small_beam / map_l; %小波束内横向有多少个分辨单元
    num_w = small_beam / map_w; %小波束内纵向有多少个分辨单元
end
for j = 1:num_w
    for i = 1:num_l
        index_l = fix((beamPos_l - 1) * num_l + i);
        index_w = fix((beamPos_w - 1) * num_w + j);
        if(map(index_l, index_w) ~= 1000)%TODO:改用回波处理算法，目前为了测试
            response = response + getdisg(index_l * map_l, map(index_l, index_w));
        end
    end
end

end