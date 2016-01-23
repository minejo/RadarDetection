%%%%%%%%%%%%%%%%%%%%%%%
%%% Author: Chao Li %%%
%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%铁道隧道或沿线口崩塌落石场景%%%%%%%%%%
function fallstone(T,f0,B,deltaR, deltaV)
c=3e8;
%%%%%%%%%确定分辨率%%%%%%%%%%%%%%
Rmax=300; %最大处理距离
Fs=4*B*Rmax/(T*c); %差频信号采样率
N=round(Fs*T); %距离维采样点数
M=fix(c/(deltaV*2*T*f0)); %速度维采样点数
Vmax=M*deltaV;  %最大不模糊速度
%%%%%%%%%%设置参数%%%%%%%%%%%%%%%%%%%%%%%
angle=3; %方位向波束角度
T1=M*T; %单波束驻留时间
scan_angle=30:angle:150; %波束扫描角度范围
TT=T1*length(scan_angle); %扫描覆盖区域一周期时间
t=0:T1 :25*TT; %设置扫描时间为10周期

%%%%%%%%%%%%%%%初始化map图%%%%%%%%%%%%%%%%%
map=ones(fix(Rmax/0.1), 180)*(-1); %map图距离维最小单元为0.1m，角度维最小距离为1度
%%%%%%%%%%%%%%%%%%%%%%%%%%
%   物体运动模型设置     %
R0=70; %初始距离
v0=-4; %初始速度,接近雷达方向为正
a=-3; %加速度

sita0=50;%初始角度
sita_a=1;%角度变化加速度
sita_v0=1;%角度变化初始速度

v=v0+a.*t;
R=R0-(v0.*t + 0.5*a.*t.^2);
sita=sita0 + sita_v0.*t + 0.5*sita_a.*t.^2;

%      静止物体         %
R1=72;sita1=50;
%R2=80;sita2=50;
%                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%
map(fix(R0/0.1), sita0)=abs(v0);
map(fix(R1/0.1), sita1)=0;
%map(fix(R2/0.1), sita2)=0;

R_pre=fix(R0/0.1); %map更新时对应的上一时刻的值
sita_pre=sita0;
%%%%%%%%%%%%%%轨迹相关设置%%%%%%%%%%%%%%%%%
track_head = []; %运动轨迹头，分为3列，分别是距离，速度，方位，初始为空
track_temp = {}; %临时运动轨迹集合，每个临时轨迹为一个cell单元，cell单元中包含小于5个点的轨迹，每个点的结构同轨迹头
track_normal = {};%正式轨迹集合，每个轨迹为一个cell，cell单元中包含多于5个点的轨迹
%%%%%%%%%%%%%扫描map得到回波并处理%%%%%%%%%%%%%
search_sita=30;
search_result = {}; %所有波束扫描的动目标集合，每个波束的结果为一个cell单元
for i=1:length(t)
    %实时更新map
    [map, R_pre, sita_pre] = updatemap(map, R(i)/0.1, R_pre, sita(i), sita_pre, abs(v(i)));
    %获得回波差频信号
    response=getresponse(map,0.1,angle,search_sita,M,T,Fs,B,f0);
    
    if response
        %添加噪声与杂波
        SNR=1; %热噪声信噪比
        response = awgn(response, SNR);
        %添加杂波信号
        za=zeros(M,N);
        %         Z=terrain; %生成地形数据矩阵
        %         hangza=zabo(B,f0,fs,T,B/T,3,Rmax,Z);
        for k=1:M
            za(k,:)=wbfb(1.5,2.2);
        end
        response = response + (za);
        
        %%%%%%%%%%对差频信号进行二维fft变换%%%%%%%%%
        data = after2fft(response, N, Fs, T, B, f0); %二维变换后的矩阵
        data=abs(data);
        %去除低频率的杂波与静止物体
        %         for i=1:N
        %             data(1,i)=data(2,i);
        %         end
        data = data(2:M, :);
        
        %%%%%%%%%%%%%CFAR处理%%%%%%%%%%%%%%%
        ones_result = cfarhandled(data,search_sita,deltaR, deltaV);
        %扫描结果加上时间戳
        for k=1:size(ones_result,1)
            ones_result(k, :) = [ones_result(k, :) t];
        end
        %单波束结果聚合操作
        %todo
        search_result = [search_result; ones_result];
        %         x_distance=(linspace(0,Fs*(N-1)/N,N));
        %         y_velocity=linspace(0, 1/T*(M-1)/M, M);
        %         meshx=x_distance(1:N/2)*c/(2*B/T);
        %         figure;
        %         mesh(meshx,c*y_velocity/(2*f0),hasObject);
        %         title('恒虚警检测结果');
        %         xlabel('distance/m');
        %         ylabel('velocity/(m/s)');
        
        %%%%%%%%%%轨迹处理%%%%%%%%%%%
        %轨迹处理的优先顺序：1.轨迹维持 2.创建轨迹 3.创建临时轨迹 4.创建轨迹头
        if (~isempty(track_normal))
            if(~isempty(ones_result))
                %轨迹维持todo
            end
            %如果点迹经过轨迹维持后没有了，则清空临时轨迹和轨迹头
            if(isempty(ones_result))
                track_temp = {};
                track_head = [];
            end
        end
        
        if(~isempty(track_temp))
            if(~isempty(ones_result))
                %创建轨迹todo
            end
            %如果点迹经过创建轨迹后没有了，则清空轨迹头
            if(isempty(ones_result))
                track_head = [];
            end
        end
        
        if(~isempty(track_head))
            if(~isempty(ones_result))
                %创建临时轨迹todo
                [track_temp, track_head, ones_result] = create_temptrack(track_temp, track_head, ones_result);
            end
        end
        
        if(~isempty(ones_result))
            %创建轨迹头
            track_head = [track_head; ones_result];
        end
        
        
        %%%%%%%%波束方位角%%%%%%%%%%
        disp('当前波束扫描角度为：');
        search_sita = search_sita + angle %波束指向下一个方位
        if(search_sita > 150)
            search_sita = 30;
        end
    end
end