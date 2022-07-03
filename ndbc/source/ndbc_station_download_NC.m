function [ndbc_station_download] = ndbc_station_download_NC(ndbc_station_download,station_tf_download,ncid,nclat,...
    nclon,nctime,nc_WVHT,path_save,ncNameInTable,...
    path_Nc_time_Hs)
% author:
%    liu jin can, UPC
%
% revison history
%    2022-02-15 first verison. 
%    2022-02-18 second, ndbc_station_download_NC_analyse
%    2022-02-19 third, function, path_save.
%
% reference
%    Matlab在一组数据中查找最接近某个数据的值：https://www.ilovematlab.cn/thread-102665-1-1.html
%    matlab 计算N天前（后）的日期：https://blog.csdn.net/weixin_41649786/article/details/84581351
%    matlab中一个日期怎么一次加一个月或者一年：https://zhidao.baidu.com/question/2271028597414842268.html
%    

%clc, clear all
%load ndbc_station_download.mat
%load ndbc_station_download_NC_analyse.mat; ndbc_station_download = ndbc_station_download_NC_analyse;
%disp('已加载ndbc_station_download.mat！'); pause(1);
%ndbc_station_download_NC0 = table; %后面重新命名为ndbc_station_download_NC即可。

%%
% disp('-----------------------ndbc_station_download_NC')
cd(path_save)

%% 了解 nc 文件；
%ncid = 'ww3.2011.nc';
%ncdisp(ncid);
%disp('了解 nc 文件！'); pause(1);

%% 查找每个浮标对应NC文件的最近网格点经纬度（索引）
fprintf('                   ├──「每个浮标对应%s中的最近网格点经纬度（索引）,在H观测矩阵的索引」\n',ncNameInTable)
fprintf('                        每个浮标最近网格点经纬度索引的解释，如nclat(7)，指的是nclat序列的第7位数，不需要明确nclat是从小到大排列，还是从大到小,\n')
fprintf('                        每个浮标在H观测矩阵的索引的解释,必须要求nclat和nclon是从小到大排列，才能满足同化中网格点（先是纬度、经度最小-->后经度从小到大-->后纬度变大一个分度值-->）排成一列的特点，代码中一进行验证，\n')
%nclat = ncread(ncid,'latitude'); %查看纬度显示正常
%nclon = ncread(ncid,'longitude'); %查看经度显示正常
if(nclon(end)<nclon(1) | nclat(end)<nclat(1))
    error('每个浮标在H观测矩阵的索引必须要求nclat和nclon是从小到大排列，才能满足同化中网格点（先是纬度、经度最小-->后经度从小到大-->后纬度变大一个分度值-->）排成一列的特点!!!')
end
for i=1:1:size(ndbc_station_download,1)
    % lat 最近网格点经纬度
    [~,temp1] = min(abs(nclat(:)-ndbc_station_download.lat(i,1))); 
    % ndbc_station_download.matchNC_lat{i,1} = nclat(temp1);
    eval(['ndbc_station_download.',ncNameInTable,'_matchNC_lat{i,1} = nclat(temp1);'])
    % ndbc_station_download.matchNC_lat{i,2} = temp1; %索引位置
    eval(['ndbc_station_download.',ncNameInTable,'_matchNC_lat{i,2} = temp1;'])

    % lon 最近网格点经纬度
    [~,temp2] = min(abs(nclon(:)-ndbc_station_download.lon(i,1))); % 
    % ndbc_station_download.matchNC_lon{i,1} = nclon(temp2);
    eval(['ndbc_station_download.',ncNameInTable,'_matchNC_lon{i,1} = nclon(temp2);'])
    % ndbc_station_download.matchNC_lon{i,2} = temp2; %索引位置
    eval(['ndbc_station_download.',ncNameInTable,'_matchNC_lon{i,2} = temp2; '])
    
    % 在H矩阵的索引
    eval(['ndbc_station_download.',ncNameInTable,'_IndexInHmatrix{i,1} = (temp1-1)*length(nclon)+temp2;'])
end

fprintf('                      「work_table」在work_table中的%s*属性中，记录了每个浮标对应%s中的最近网格点信息,\n',ncNameInTable,ncNameInTable)
% disp('已添加每个浮标对应NC文件的最近网格点经纬度、索引！'); 
pause(1);

%% NC文件julian day转换为UT日期，datetime数据类型
%ncdisp(ncid,'time');
%nctime = ncread(ncid,'time'); % julian day (UT),'days since 1990-01-01 00:00:00'

% help datetime
% help datestr
% help caldays
% help calendarDuration
% datetime('1990-01-01 00:00:00','InputFormat','yyyy-MM-dd HH:mm:ss')+1.5
% datetime('1990-01-01 00:00:00','InputFormat','yyyy-MM-dd HH:mm:ss')+nctime(2) %成功，与ncview()中的时间对上了。
% caldays(1.1)
% caldays(1)
% datetime('1990-01-01 00:00:00','InputFormat','yyyy-MM-dd HH:mm:ss')+caldays(1)

    
disp('                   ├──「时间转化]已将NC文件julian day转换为UT日期，用到datetime数据类型！'); pause(1);
UTtime = datetime('1990-01-01 00:00:00','InputFormat','yyyy-MM-dd HH:mm:ss')+nctime;


%% nc中的时间-WVHT数据
% 各维度递增方向的确定，明确浮标点的索引需不需要变换
%nc_WVHT = ncread(ncid,'hs'); % 69x41x245 double
                             % Dimensions: longitude (维度递增方向↑or↓),latitude (维度递增方向← or →),time (维度递增方向↓), 
temp = nc_WVHT(:,:,1);       % 观察数据样子，与ncview()对比，可以得到：longitude (维度递增方向↓),latitude (维度递增方向→)
                             %                                         longitude 索引不需要变换；
                             %                                         latitude索引不需要变换；
                                 
for i=station_tf_download%1:1:size(ndbc_station_download,1)
    nc_time_WVHT = table;
    nc_time_WVHT.YY_MM_DD_hh_mm_ss = UTtime;
    % temp = nc_WVHT(ndbc_station_download.matchNC_lon{i,2},ndbc_station_download.matchNC_lat{i,2},:);
    eval(['temp = nc_WVHT(ndbc_station_download.',ncNameInTable,'_matchNC_lon{i,2},ndbc_station_download.',ncNameInTable,'_matchNC_lat{i,2},:);'])
    nc_time_WVHT.WVHT = temp(:);
    
    


    %
    oooooo = strcat(path_Nc_time_Hs,num2str(i),'.mat');
    save(oooooo,"nc_time_WVHT");
    %
    % 总的table做个记录，
    % ndbc_station_download.nc_time_WVHT{i,1} = nc_time_WVHT;
    oooooo2 = strcat('load("',oooooo,'");');
    eval(['ndbc_station_download.',ncNameInTable,'_nc_time_WVHT{i,1} = oooooo2; '])

    % save
    work_table = ndbc_station_download;
    save work_table.mat work_table
end




