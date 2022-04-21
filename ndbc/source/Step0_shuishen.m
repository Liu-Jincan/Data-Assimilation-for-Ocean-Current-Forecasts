clc, clear all
load ndbc_station_info_needed.mat
disp('已加载ndbc_station_info_needed.mat！'); pause(1);

%%%%%%%%%%%  水深  %%%%%%%%%%%
lon = ncread('m_map\ETOPO1\etopo1.nc', 'lon');
lat = ncread('m_map\ETOPO1\etopo1.nc', 'lat');
water = ncread('m_map\ETOPO1\etopo1.nc', 'z');

%%%% 提取特定位置的水深 %%%%%
point_lon=[108 116 119 114 116 110]';
point_lat=[20 21 20 17 11 14]';
depth = zeros(1,length(point_lon));

for i = 1:1:length(point_lon)
    a = find(lat==point_lat(i));
    b = find(lon==point_lon(i));
    c = water(b,a);
    
    depth(i) = c;
end