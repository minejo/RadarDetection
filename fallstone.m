%%%%%%%%%%%铁道隧道或沿线口崩塌落石场景%%%%%%%%%%
function fallstone(T,f0,B,deltaR, deltaV)
c=3e8;
%%%%%%%%%确定分辨率%%%%%%%%%%%%%%
Rmax=300; %最大处理距离
Fs=4*B*Rmax/(T*c); %差频信号采样率
N=Fs*T; %距离维采样点数
M=fix(c/(deltaV*2*T*f0)); %速度维采样点数
Vmax=M*deltaV;  %最大不模糊距离
%%%%%%%%%%设置参数%%%%%%%%%%%%%%%%%%%%%%%
angle=3; %方位向波束角度
T1=M*T; %单波束驻留时间
scan_angle=30:angle:150; %波束扫描角度范围
TT=T1*length(scan_angle); %扫描覆盖区域一周期时间
t=0:T1:15*TT; %设置扫描时间为10周期

%%%%%%%%%%%%%%%初始化map图%%%%%%%%%%%%%%%%%
map=ones(fix(Rmax/0.1), 180)*(-1); %map图距离维最小单元为0.1m，角度维最小距离为1度
%%%%%%%%%%%%%%%%%%%%%%%%%%
%   物体运动模型设置     %
R0=70; %初始距离
v0=-2; %初始速度,接近雷达方向为正
a=-3; %加速度

sita0=50;%初始角度
sita_a=1;%角度变化加速度
sita_v0=1;%角度变化初始速度

v=v0+a.*t;
R=R0-(v0.*t + 0.5*a.*t.^2);
sita=sita0 + sita_v0.*t + 0.5*sita_a.*t.^2;
%                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%
map(fix(R0/0.1), sita0)=abs(v0);
R_pre=fix(R0/0.1); %map更新时对应的上一时刻的值
sita_pre=sita0;

%%%%%%%%%%%%%扫描map得到回波并处理%%%%%%%%%%%%%
search_sita=30;
for i=1:length(t)
    %实时更新map
    [map, R_pre, sita_pre] = updatemap(map, R(i)/0.1, R_pre, sita(i), sita_pre, abs(v(i)));
    %获得回波差频信号
    response=getresponse(map,0.1,angle,search_sita,M,T,Fs,B,f0);
    
    if response
        %添加噪声与杂波
        SNR=1; %热噪声信噪比
        response = awgn(response, SNR);
        %todo 杂波
        
        %%%%%%%%%%对差频信号进行二维fft变换%%%%%%%%%
        data = after2fft(response, N, Fs, T, B, f0); %二维变换后的矩阵
        data=abs(data);
        
        %%%%%%%%%%%%%CFAR处理%%%%%%%%%%%%%%%
        hasObject = cfarhandled(data,search_sita,deltaR);
    end
    %%%%%%%%波束方位角%%%%%%%%%%
    disp('当前波束扫描角度为：');
    search_sita = search_sita + angle %波束指向下一个方位
    if(search_sita > 150)
        search_sita = 30;
    end
end
%轨迹处理
end