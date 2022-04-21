%% 
path(path,'m_map');

%% 南海
figure('NumberTitle', 'off', 'Name', 'NanHai','color',[1,1,1]);
a = ncread('G:\ERA5_China_nanhai\ERA5_195806.nc','longitude');
b = ncread('G:\ERA5_China_nanhai\ERA5_195806.nc','latitude');
c = ncread('G:\ERA5_China_nanhai\ERA5_195806.nc','swh');

%% m_proj
while(1)
    LatMin = 9; 
    LatMax = 24;
    LonMin = 105;
    LonMax = 120;
    m_proj('miller','long',[LonMin LonMax],... %121.1667
        'lat',[LatMin LatMax],...
        'clo',119.3750,... %子午线
        'rec','on');% 正方形
    break
end

%% 海岸线
% m_gshhs_f('save','.\mat\NanHai.mat'); %保存海岸线
m_usercoast('Step0_NanHaiMmap.mat','patch',[.5 .5 .5],'edgecolor','none'); %路径  大陆颜色  
% m_gshhs('fb2','linestyle','--','linewidth',0.2,'color','r'); %绘制省界，后绘制

%% 网格
grid on


%% contourf, Step1_Hs_NBFWZJD
%{
doc meshgrid
doc contourf

[xi,yi]=meshgrid([105:0.5:125],[24:-0.5:4]);  %%加密网格，为下面的数据插值做准备
z_obs = interp2(x,y,data_obs,xi,yi,'linear');  %%linear:线性插值，cubic:三次插值；neare
contourf(z_obs,20,'LineStyle','none');
%}
%{
doc interp2

[X,Y] = meshgrid(-3:3);
V = peaks(X,Y);
[Xq,Yq] = meshgrid(-3:0.25:3);
Vq = interp2(X,Y,V,Xq,Yq);
%}
jingdu = 105:0.125:120;
weidu = 24:-0.125:9; %纬度为什么是这样？为了结点对应
jingdu2 = zeros(1,length(jingdu));
for i=1:1:length(jingdu)
    [jingdu2(i),~] = m_ll2xy(jingdu(i),weidu(1));
end
weidu2 = zeros(1,length(weidu));
for i=1:1:length(weidu)
    [~,weidu2(i)] = m_ll2xy(jingdu(1),weidu(i));
end
[X,Y] = meshgrid(jingdu2,weidu2); %结点对应（横坐标经度！！lon*lat）
hold on
% figure(2);contourf(X,Y,CL_All,20,'LineStyle','none'); %还是不对应
% figure(1);contourf(CL_All,20,'LineStyle','none'); %验证了矩阵行是经度，列是纬度
% figure(3);contourf(X,Y,CL_All',10,'LineStyle','none'); %对应了

figure(3);hold on
contourf(X,Y,CL_All',...%10个圈
    [0.95 1],...
    'LineStyle','none'); %对应了
contourf(X,Y,CL_All',...%10个圈
    [0.9 0.95],...
    'LineStyle','none'); %对应了






