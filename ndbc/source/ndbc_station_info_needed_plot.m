function [ndbc_station_info_needed] = ndbc_station_info_needed_plot(ndbc_station_info_needed,lat_max,lat_min,lon_max,lon_min,path_save)
% author:
%    liu jin can, UPC
%
% revison history
%    2022-02-13 first verison.
%    2022-02-19 second, function, path_save.
%
% ps：许多 m_* 函数的应用，可以在 https://www.eoas.ubc.ca/~rich/map.html 网页，crtl+F搜索使用其的例子。

%clc, clear all
%load ndbc_station_info_needed.mat
%disp('已加载ndbc_station_info_needed.mat！'); pause(1);

%%
disp('-----------------------ndbc_station_info_needed_plot')
cd(path_save)

%% 可调参数
% 区域范围信息
lon1 = lon_min; %100
lon2 = lon_max; %125
lat1 = lat_min; %0
lat2 = lat_max; %30

% 经度和纬度显示的刻度信息
xtick_lon = lon1:5:lon2;%
xticklabels_lon = num2str(xtick_lon');%
ytick_lat = lat1:2:lat2;
yticklabels_lat = num2str(ytick_lat');

% 水深colorbar信息
water_min = -6000; %水深范围；（先用jet去试试，确定后再用blue，因为blue中的白色容易漏掉，有特别深的水深数据）
etopo2_contourf = [water_min:-water_min/100:0]; % /10，/100，分母越大好像越好
CM_piece_num = 80;%colorbar平均分的块数
CM_type = 'blue'; % jet, gland
% CM_type 可以组合：CM = colormap([m_colmap('jet',CM_piece_num);m_colmap('gland',48)]);
%                 自己去对应位置调；
CM_Ytick = fliplr([0 -1200  -2400 -3600 -4800 -6000]);  %colorbar刻度信息
CM_position = [0.8 0.1 0.0288 0.8]; %colorbar位置
CM_TickLength = [0.01 10]; %colorbar刻度长



% 浮标点的信息
point_lon = ndbc_station_info_needed.lon; %[108 116 119 114 116 110]';
point_lat = ndbc_station_info_needed.lat; %[20 21 20 17 11 14]';
% point_name=['P1', 'P2', 'P3', 'P4', 'P5'];
%point_name={'P1', 'P2', 'P3', 'P4', 'P5', 'P6'};
%buoy_name={'1','2','3','4','5','6','7','8','9'};


%% m_map
F1 = figure(1);
% m_map
%cd(path_save);
%cd('..'); % 跳到上一级路径下
%path(path,'\m_map');
%cd(path_save) % 返回之前的路径


% m_proj：投影
m_proj('Mercator','lon',[lon1 lon2],'lat',[lat1 lat2]);%%矩形

% m_etopo2, m_contfbar：水深数据及其 colorbar
[CS,CH] = m_etopo2('contourf',etopo2_contourf,'edgecolor','none');
[ax,h] = m_contfbar(0.9,[0.2,0.8],CS,CH,'endpiece','no','axfrac',.05,'edgecolor','none',...
    'fontname','times new roman','fontsize',14);

% m_plot, m_text ：画点及标出名称
hold on
for ii=1:size(point_lon,1)
    m_plot(point_lon(ii),point_lat(ii),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','markersize',5.2);
    hold on
    m_text(point_lon(ii),point_lat(ii),num2str(ii),'fontname','times new roman','FontSize',9);
    hold on
end




% m_gshhs_*：海岸线数据
%m_coast('patch',[.6 .6 .7]);
% m_gshhs_c('patch',[.7 .7 .7]);
%m_gshhs_l('patch',[.5 .5 .5]);
m_gshhs_i('patch',[.7 .7 .7]);
%m_gshhs_f('patch',[.7 .7 .7]); %full


% m_grid：网格
m_grid('box','fancy','tickdir','in','tickstyle','dm','xtick',xtick_lon,...
    'xticklabels',xticklabels_lon,'ytick',ytick_lat,...
    'yticklabels',yticklabels_lat,'fontname','times new roman','FontSize',14,...
    'linestyle','none');
XL1 = xlabel('Longitude(°E)','fontsize',14,'fontname','Times New Roman');
YL1 = ylabel('Latitude(°N)','fontsize',14,'fontname','Times New Roman');

%% colorbar的设置
% figure 背景为白色
set(gcf,'color','w');  % otherwise 'print' turns lakes black

% 水深colorbar信息
CM = colormap(m_colmap(CM_type,CM_piece_num));
% CM = colormap([m_colmap('jet',CM_piece_num);m_colmap('gland',48)]); %colormap选取

set(ax.YLabel,'string','Water Depth (m)','fontname','times new roman','fontsize',14'); %colorbar对应的名称
set(ax,'position',CM_position,...
    'Ytick',CM_Ytick,...%'Yticklabel',{'0';'600';'1200';'1800';'2400';'3000';'3600';'4200';'4800';'5400';'6000'},...
    'YTickLabelMode','auto',...
    'TickLength',CM_TickLength,...
    'Ydir','reverse'); %colorbar位置，刻度

%% 添加map到ndbc_station_download_NC_analyse
%load ndbc_station_download_NC_analyse
mkdir fig
savefig(F1,strcat(path_save,'fig/区域ndbc浮标图','.fig'));
ndbc_station_info_needed.BuoyPointsMap{1,1} = strcat('cd(path_save); openfig("./fig/区域ndbc浮标图','.fig")');
%ndbc_station_download_NC_analyse.BuoyPointsMap{1,1} = strcat('openfig(".\fig\区域ndbc浮标图','.fig")');
close(F1)
%save ndbc_station_download_NC_analyse ndbc_station_download_NC_analyse
end


