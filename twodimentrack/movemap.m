function [map,p_pre,sita_pre] = movemap(map,p,p_pre,sita,sita_pre,map_x,v)
%改变物体的map中映射的位置,p_pre,sita_pre为前一时刻物体的位置，p,sita为此刻物体对应的位置
[x,y]=size(map);
x_t=1:x;
y_t=1:y;
map(p_pre,sita_pre)=-1;
p=max(find(x_t<=p));
sita=max(find(y_t<=sita));
map(p,sita)=v;
p_pre=p;
sita_pre=sita;
end