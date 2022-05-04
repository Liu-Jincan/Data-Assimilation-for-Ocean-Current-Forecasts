function [ndbc_station_info_needed] = ndbc_station_info_needed_etopo1(ndbc_station_info_needed,path_save)
% author:
%    liu jin can, UPC

% revison history
%    2022-02-19 second verison, function, path_save.
%
% ps:
%    etopo1的经度范围是0~360
%    ndbc_station_info_needed的经度范围是-180~180

%clc, clear all
%load ndbc_station_info_needed.mat
%disp('已加载ndbc_station_info_needed.mat！'); pause(1);

disp('-----------------------ndbc_station_info_needed_etopo1')
%%%%%%%%%%%  水深  %%%%%%%%%%%
cd(path_save)
cd('..')
%ncdisp('m_map\ETOPO1\etopo1.nc')
lon = ncread('m_map\ETOPO1\etopo1.nc', 'lon');
lat = ncread('m_map\ETOPO1\etopo1.nc', 'lat');
water = ncread('m_map\ETOPO1\etopo1.nc', 'z');

%%%% 提取特定位置的水深 %%%%%
% 经度范围是-180~180，变成0~360
point_lon = ndbc_station_info_needed.lon;
tf = find(point_lon<0);
point_lon(tf) = point_lon(tf)+360;
%
point_lat = ndbc_station_info_needed.lat;
depth = zeros(length(point_lon),1);
% 查找每个浮标对应NC文件的最近网格点经纬度（索引）
for i=1:1:size(point_lon,1)
    % lat 最近网格点经纬度
    [~,a] = min(abs(lat(:)-point_lat(i))); 
    % lon 最近网格点经纬度
    [~,b] = min(abs(lon(:)-point_lon(i))); 
    % 
    c = water(b,a);
    depth(i) = c;
end

ndbc_station_info_needed.etopo1 = depth;

%% 可以去 https://www.ndbc.noaa.gov/to_station.shtml 查找一些浮标的水深，验证etopo1的准确性


end