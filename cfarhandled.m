function hasObject = cfarhandled(data,search_sita,deltaR)
%通过距离维与速度维各做一次cacfar，综合判断是否出现目标
[M N]=size(data); %获取一维变化点数与二维变换点数

L_v=14; %速度维参考窗长度
L_d=32; %距离维参考窗长度
r=1; %保护单元长度
pfa_d=1e-2; %距离维虚警率
pfa_v=1e-2; %速度维虚警率
K1=(pfa_d)^(-1/L_d)-1; %虚警门限
K2=(pfa_v)^(-1/L_v)-1;

hasObject=zeros(M,N/2);

figure(1)
%铁路距离
rail_dis=100;
rail_x=30:150;
rail_y=abs(rail_dis./sin(rail_x*pi/180));
rail_y1=abs((rail_dis-8)./sin(rail_x*pi/180));
polar(rail_x*pi/180, abs(rail_y),'r-');
hold on;
polar(rail_x*pi/180,rail_y1,'r-');
hold on;

for i=1:M
    for j=1:N/2
        %纵轴oscfar
        cankao1=zeros(L_v); %参考窗
        if(i>(L_v/2+r)&&i<=M-L_v/2-r)
            cankao1=[data(i-L_v/2-r:i-r-1,j)' data(i+r+1:i+L_v/2+r,j)'];
        elseif (i==1 || i ==2)
            cankao1=data(i+r+1:i+L_v+r,j)';
        elseif(2<i && i<=L_v/2+r)
            cankao1=[data(1:i-r-1,j)' data(i+r+1:L_v+2*r+1,j)'];
        elseif(i<M-1&&i>M-L_v/2-r)
            cankao1=[data(-2*r-L_v+M:i-r-1,j)' data(i+r+1:M,j)'];
        elseif( i==M || i==M-1)
            cankao1=data(i-L_v-r:i-r-1,j)';
        end
        hasObject1=cacfar(data(i,j),cankao1,K1);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %横轴cfar
        cankao2=zeros(L_d);
        if(j>(L_d/2+1)&&j<=N-L_d/2-1)
            cankao2=[data(i,j-L_d/2-r:j-r-1) data(i,j+r+1:j+L_d/2+r)];
        elseif (j==1 || j ==2)
            cankao2=data(i,j+r+1:j+L_d+r);
        elseif(2<j && j<=L_d/2+1)
            cankao2=[data(i,1:j-r-1) data(i,j+r+1:L_d+2*1+r)];
        elseif(j<N-1&&j>N-L_d/2-1)
            cankao2=[data(i,-2*r-L_d+N:j-r-1) data(i,j+r+1:N)];
        elseif( j==N || j==N-1)
            cankao2=data(i,j-L_d-r:j-r-1);
        end
        hasObject2=cacfar(data(i,j), cankao2,K2);
        %%%%%%%%%%%%%%%%判断该点是否是顶点%%%%%%%%%%%%%%%%%%%%
        isTop=1;
        if(i>1&&i<M&&j>1&&j<N/2)
            isTop= (data(i,j) > data(i+1,j)) && (data(i,j) > data(i-1,j)) && (data(i,j) > data(i,j-1)) && (data(i,j) > data(i,j+1));
        end
        hasObject(i,j) = hasObject1*hasObject2*isTop;
        if hasObject(i,j) == 1
            polar(search_sita/180*pi, j*deltaR, '*r');
            hold on;
        end
    end
end
end