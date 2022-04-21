function [ndbc_station_info_needed] = ndbc_station_info_needed(ndbc_station_info,lat_max,lat_min,lon_max,lon_min,path_save)
% author:
%    liu jin can, UPC

% revison history
%    2022-02-13 first verison.
%    2022-02-19 second, function, path_save.

%clc, clear all
%load ndbc_station_info.mat
%disp('已加载ndbc_station_info.mat！'); pause(1);

%%
disp('-----------------------ndbc_station_info_needed')
cd(path_save)

%% 区域，needed
% 从gridgen.east-USA_P25.nml得到的经纬度范围
%lat_max = 46;  % 纬度为负数，表示南纬
%lat_min = 36;
%lon_max = -58; % 经度为负数，表示西经
%lon_min = -75;

% 将ndbc_station_info中的经纬度字符串信息转为数字，
% 例如
% '17.984 S'转换为-17.984
% '17.984 W'转换为-17.984
% cell类型的NaN转为数值的NaN
lat = [];
lon = [];
for i=1:1:size(ndbc_station_info,1)
    temp = cell2mat(ndbc_station_info{i,2}); %判断是否为nan
    if isnan(temp)
        lat = [lat;nan];
        lon = [lon;nan];
    else
        temp = char(ndbc_station_info{i,2}); %lat
        if temp(end)=='N'
            lat = [lat;str2num(temp(1:end-2))];
        elseif temp(end)=='S'
            lat = [lat;-str2num(temp(1:end-2))];
        end
        
        temp = char(ndbc_station_info{i,3}); %lon
        if temp(end)=='E'
            lon = [lon;str2num(temp(1:end-2))];
        elseif temp(end)=='W'
            lon = [lon;-str2num(temp(1:end-2))];
        end
    end
end

disp('已将ndbc_station_info中的经纬度字符串信息转为数字！'); pause(1);
ndbc_station_info.lat = lat;
ndbc_station_info.lon = lon;


% 选取所需区域的浮标
temp = find( ndbc_station_info.lat>=lat_min & ...
    ndbc_station_info.lat<=lat_max & ...
    ndbc_station_info.lon<=lon_max & ...
    ndbc_station_info.lon>=lon_min);
ndbc_station_info_needed0 = ndbc_station_info(temp,:);
disp('已将所需区域的浮标选取出来！'); pause(1);

%% 年份，needed
% 将所需区域浮标SM历史年份数据为nan的去除；
%ndbc_station_info_needed0.station__historyYear_SM{34}
temp = [];
for i=1:1:size(ndbc_station_info_needed0,1)
    try
        if isnan(ndbc_station_info_needed0.station__historyYear_SM{i})
            temp = [temp;0]; % nan 数据
        else
            temp = [temp;1]; % 单个字符串
        end
    catch
        temp = [temp;1]; % 多个字符串组成的string类型
    end
end
ndbc_station_info_needed0 = ndbc_station_info_needed0(logical(temp),:); %int8

%?特定年份？年份范围？
disp('已将所需区域对应年份的浮标选取出来！');pause(1);


%% save，在运行完前面的内容后，单独运行保存这一部分
%不支持将 'ndbc_station_info_needed' 同时用作变量名称和脚本名称。
ndbc_station_info_needed = ndbc_station_info_needed0; 
%save ndbc_station_info_needed ndbc_station_info_needed
save(strcat(path_save,'ndbc_station_info_needed'),'ndbc_station_info_needed')

end

