                                                                                    
% author:
%    liu jin can, UPC
%
% revison history
%    2022-02-19 first verison.
%
% reference:
%    https://blog.csdn.net/qq_35166974/article/details/96007377:警告: 未保存变量 'work_table'。对于大于 2GB 的变量，请使用 MAT 文件版本 7.3 或更高版本。 

clc,clear all;
%%

fprintf('work_eastUSA.m \n')
fprintf('├──「FAQ」VScode中编辑matlab（代码高亮、语言检查、代码补全），运行matlab， \n')
fprintf('   「解决方法一」在VSCode中编写和运行Matlab脚本VScode中关于matlab的扩展， https://zhuanlan.zhihu.com/p/409708835 \n')
fprintf('           ├──「安装扩展Matlab」完全按照操作，成功，setting.json设置的是R2021b的版本 \n')
fprintf('              「FAQ」每次保存.m文件，VScode会跳出来一个MATLAB图像 \n')
fprintf('           ├──「安装扩展Matlab Interactive Terminal 」完全按照操作，成功， \n')
fprintf('              「FAQ」运行很久的程序，在运行过程中交互终端一直不显示输出，不会是在最后统一输出吗？ \n')
fprintf('   「解决方法二」使用vscode编辑并运行matlab脚本， https://zhuanlan.zhihu.com/p/395486395 \n')
fprintf('           ├──「安装扩展Matlab formatter」，\n')
fprintf('├──「FAQ，失败」Fortran读取mat文件， \n')
fprintf('   「解决方法？，难搞」帮助中心，外部语言接口，https://ww2.mathworks.cn/help/matlab/external-language-interfaces.html?s_tid=CRUX_lftnav，\n')
fprintf('               从 Fortran 调用 MATLAB, https://ww2.mathworks.cn/help/matlab/matlab-api-for-fortran.html ,\n ')
fprintf('               用于读取 MAT 文件数据的 MATLAB Fortran API, https://ww2.mathworks.cn/help/matlab/Fortran-applications-to-read-mat-file-data.html ,\n ')
fprintf('               一个例子，http://matlab.izmiran.ru/help/techdoc/matlab_external/ch01in12.html')
fprintf('   「解决方法？」matlab 文件打开方式,mex文件和mat文件打开方式，https://blog.csdn.net/weixin_42527178/article/details/116437390?utm_medium=distribute.pc_aggpage_search_result.none-task-blog-2~aggregatepage~first_rank_ecpm_v1~rank_v31_ecpm-11-116437390.pc_agg_new_rank&utm_term=fortran%E8%AF%BB%E5%8F%96mat%E6%95%B0%E6%8D%AE%E7%B1%BB%E5%9E%8B&spm=1000.2123.3001.4430')
fprintf('   「解决方法？」大型数据，用netcdf格式传递数据，https://tieba.baidu.com/p/2751695821,\n')
fprintf('   「解决方法？」C++读写.mat文件, https://blog.csdn.net/left_la/article/details/8206645  ,\n')
fprintf('              C程序读取.mat格式的Matlab数据文件,https://blog.csdn.net/CGeorge003/article/details/52415101  ,\n')
% http://www.uwenku.com/question/p-uwaunarh-xc.html
fprintf('├──「工作目录」/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/work_eastUSA/\n')
fprintf('├──「FAQ」H矩阵的生成，背景场数据，观测数据怎么作为输入给到ENOI？ \n')
% begin~~~~
path_save = '/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/work_eastUSA/'; %work工作目录路径，最后必须是'/'
cd(path_save)
fprintf('   「添加路径」source， \n')
addpath '/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/source'

if exist('work_table.mat')
    fprintf('├──「加载work_table.mat」\n')
    load work_table.mat
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('       ├──Step1.「函数」下载ndbc浮标数据，更改work_table中的station_historyData_SM属性，下载完数据此步骤可省略，\n')
    station_tf_download = [1];                                                 %要下载的浮标在work_table的索引
    path_station_historyData_SM = strcat(path_save,'station_historyData_SM/');
    mkdir(path_station_historyData_SM);
    % [work_table] = ndbc_station_download(work_table,station_tf_download,path_save);%运行需要时间比较久；第一次是必须运行的；
    clear station_tf_download path_station_historyData_SM;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('       ├──Step2. 循环nc文件，为同化做准备，且能对背景场数据和nc进行简单对比分析，\n')
    fprintf('           ├──Step2.1. 循环nc，\n')
    % path_nc = strcat(path_save,'nc/');
    path_nc = strcat(path_save,'nc_ENOI/');
    fileFolder = fullfile(path_nc);
    dirOutput = dir(fullfile(fileFolder,'*.nc'));
    fileNames = {dirOutput.name}'; % 20x1 cell, relative path, 
    wildcards = strcat(path_nc,fileNames); % 20x1 cell, wildcards, absolute path,
    clear fileFolder dirOutput path_nc; 
    for i=1%:length(fileNames)
        tic
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('           ├──Step2.2 「重要参数」，\n')
        % 
        station_tf_download = [1:size(work_table,1)];           %work_table中的，选取需要添加数据的浮标索引，
        ncNameInTable = strcat(fileNames{i}(1:end-3),'_nc');    %work_table中的，显示的关于此nc文件的属性名称前缀，不能有. 
                                                                %'ww3_2011_nc';
        %
        ncid = wildcards{i};                                    %'ww3_2011.nc'; %绝对路径，
        nclat = ncread(ncid,'latitude');                        %填写纬度名称
        nclon = ncread(ncid,'longitude');                       %填写经度名称
        nctime = ncread(ncid,'time');                           %填写时间名称
        nc_WVHT = ncread(ncid,'hs');                            %填写有效波高名称
        % clear ncid;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('           ├──Step2.3「函数」每个浮标与网格点匹配，\n')
        fprintf('                            每个浮标在H观测矩阵的索引，\n')
        fprintf('                            每个浮标在nc文件的时间-HS数据，保存至.mat文件，\n')
        path_Nc_time_Hs = strcat(path_save,ncNameInTable,'_Nc_time_Hs/');
        mkdir(path_Nc_time_Hs);
        
        [work_table] = ndbc_station_download_NC(work_table,station_tf_download,ncid,nclat,nclon,nctime,nc_WVHT,...
            path_save,ncNameInTable,...
            path_Nc_time_Hs);
        % clear path_Nc_time_Hs;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % station_tf_download = [1:112];
        fprintf('           ├──Step2.4「函数」更改work_table中的$(ncNameInT)_ndbc_nc_match_WVHT,\n')
        path_Ndbc_nc_match_Hs_Fig = strcat(path_save,ncNameInTable,'_Ndbc_nc_match_Hs_Fig/');
        path_Ndbc_nc_match_Hs = strcat(path_save,ncNameInTable,'_Ndbc_nc_match_Hs/');
        mkdir(path_Ndbc_nc_match_Hs_Fig);
        mkdir(path_Ndbc_nc_match_Hs);
        [work_table] = ndbc_station_download_NC_analyse_HS(path_Ndbc_nc_match_Hs_Fig,path_Ndbc_nc_match_Hs,...
            path_Nc_time_Hs,work_table,station_tf_download,path_save,ncNameInTable);  %很早被定义过的...
        clear path_Ndbc_nc_match_Hs_Fig;
        path_Ndbc_nc_match = path_Ndbc_nc_match_Hs;
        clear path_Ndbc_nc_match_Hs;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('           ├──Step2.5「函数」根据$(path_Ndbc_nc_match) 下的所有文件生成每个所需同化时刻的Index1和yo文件txt,\n')
        path_Index1 = strcat(path_save,ncNameInTable,'_Index1/');
        path_yo = strcat(path_save,ncNameInTable,'_yo/');
        mkdir(path_Index1); % rmdir(path_Index1,'s')
        mkdir(path_yo); % rmdir(path_yo,'s')
        [work_table] = Index1_And_yo(path_Index1,path_yo,...
            path_Ndbc_nc_match,path_save,work_table,ncNameInTable); %很早被定义过的...
        clear path_Index1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % toc
        fprintf('           ├──Step2.6「函数」根据$(path_yo) 下的所有文件的名称，得到所有需要同化的时刻，求出所有时刻在nc的索引，保存在Index.txt,\n')
        path_Index = strcat(path_save,ncNameInTable,'_Index/');
        mkdir(path_Index);
        [work_table] = Index(path_Index,...
            work_table,nctime,path_yo); %很早被定义过的...
        clear path_Index;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
else
    fprintf('├──「创建work_table.mat」\n')
    work_table = table;
    %%
    %[work_table] = ndbc_station_info('',path_save); %运行需要时间比较久；
    [work_table] = ndbc_station_info('default',path_save); %调用之前已保存的ndbc_station_info.mat数据；
    %%
    lat_max = 46;  % 纬度为负数，表示南纬
    lat_min = 36;
    lon_max = -58; % 经度为负数，表示西经
    lon_min = -75;
    [work_table] = ndbc_station_info_needed(work_table,lat_max,lat_min,lon_max,lon_min,path_save);
    %%
    [work_table] = ndbc_station_info_needed_plot(work_table,lat_max,lat_min,lon_max,lon_min,path_save);
    %%
    [work_table] = ndbc_station_info_needed_etopo1(work_table,path_save);
    %%
    station_tf_download = [1]%2 5 7 9 29]; %要下载的浮标在work_table的索引
    [work_table] = ndbc_station_download(work_table,station_tf_download,path_save);%运行需要时间比较久；第一次是必须运行的；
    %%
    ncid = 'ww3.2011.nc';
    nclat = ncread(ncid,'latitude'); %查看纬度显示正常
    nclon = ncread(ncid,'longitude');
    nctime = ncread(ncid,'time');
    nc_WVHT = ncread(ncid,'hs');
    [work_table] = ndbc_station_download_NC(work_table,station_tf_download,ncid,nclat,nclon,nctime,nc_WVHT,path_save);
    %%
    [work_table] = ndbc_station_download_NC_analyse(work_table,station_tf_download,path_save);
    %%
    save work_table work_table
end
