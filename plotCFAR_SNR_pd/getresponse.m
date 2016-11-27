%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li                 %%%
%%% Email: jonathan.swjtu@gmail.com %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%得到某个波束内的回波信号，beamPos_l,
%beamPos_w分别代表波束的横向位置和纵向位置，beam_type为波束类型，1为大波束，2为小波束
response = 0;
objects = [];
for j = 1:map_width/map_w
    for i = 1:map_length/map_l
        if(map(i, j) ~= 1000)%TODO:改用回波处理算法，目前为了测试
            %fprintf('理论点迹(%f,%f),速度为%f\n', index_l*map_l, index_w*map_w, map(index_l, index_w));
            objects = [objects; j * map_w  map(i, j)];
        end
    end
end
RCS = 10;
if ~isempty(objects)
    allvel = objects(:,2);
    allvel = unique(allvel, 'rows');
    %objectcell = cell(1, length(allvel));
    for i = 1:length(allvel)
        L = objects(:,2) == allvel(i);
        one = objects(L,:);
        %构建sweling分布的rcs幅值
        rcs = generateRcs(RCS, size(one, 1));
        for j = 1:size(one, 1)
            response = response + getdisg(one(j,1), one(j,2), rcs(j));
        end
    end
end
save('response.mat');