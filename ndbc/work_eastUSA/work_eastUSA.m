% author:
%    liu jin can, UPC
%
% revison history
%    2022-02-19 first verison.
%
% reference:
%    https://blog.csdn.net/qq_35166974/article/details/96007377:警告: 未保存变量 'work_table'。对于大于 2GB 的变量，请使用 MAT 文件版本 7.3 或更高版本。 

% begin~~~~
fprintf('work_eastUSA.m \n')
% path_save = '/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/work_eastUSA/'; %work工作目录路径，最后必须是'/'
path_save='/1t/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/work_eastUSA/'
cd(path_save)
fprintf('   「添加路径」source， \n')
path_source='/1t/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/source/'
% addpath '/home/jincanliu/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/source'
addpath(path_source)
path_mmap='/1t/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/m_map/'
addpath(path_mmap)
%%
create_new_work_table=0
if(create_new_work_table==1)
    fprintf('├──「创建work_table.mat，」\n')
    work_table = table;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(['       ├──Step1.从网站上爬取ndbc浮标站的信息，①会在table中生成station_ID、station_lat、station_lon、' ...
        'station_historyYear_SM信息，②想爬取其他关于浮标的信息，需修改源代码，' ...
        '③爬取的时间有些久，10点27开始...等不了了...，已爬取的站点信息可以保存在source文件下ndbc_station_info.mat以备用，' ...
        '④运行完成后会在program文件夹下创建ndbc_station_info.mat，\n' ])
    %[work_table] = ndbc_station_info('',path_save); %运行需要时间比较久；
    [work_table] = ndbc_station_info('default',path_save); %调用之前已保存的ndbc_station_info.mat数据；
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(['       ├──Step2.选取特定区域需要的站点，剔除年份为nan的站点，在program文件夹下创建ndbc_station_info_needed.mat，\n' ])
    lat_max = 46;  % 纬度为负数，表示南纬
    lat_min = 36;
    lon_max = -58; % 经度为负数，表示西经
    lon_min = -75;
    [work_table] = ndbc_station_info_needed(work_table,lat_max,lat_min,lon_max,lon_min,path_save);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(['       ├──Step3.特定区域站点的plot，在program/fig文件夹下创建<区域ndbc浮标图.fig>，table生成对应fig的打开命令，\n' ])
    [work_table] = ndbc_station_info_needed_plot(work_table,lat_max,lat_min,lon_max,lon_min,path_save);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf(['       ├──Step4.特定区域站点的水深，在table中生成，\n' ])
    [work_table] = ndbc_station_info_needed_etopo1(work_table,path_save);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cd(path_save)
    save work_table work_table
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ndbc_station_downloadFlag
    if(ndbc_station_downloadFlag==1)
        fprintf('       ├──Step5.「函数」下载特定区域的ndbc浮标数据，更改work_table中的station_historyData_SM属性，下载完数据此步骤可省略，\n')
        station_tf_download = [1:size(work_table,1)];                                                 %要下载的浮标在work_table的索引
        path_station_historyData_SM = strcat(path_save,'station_historyData_SM/');
        mkdir(path_station_historyData_SM);
        [work_table] = ndbc_station_download(work_table,station_tf_download,path_save);%运行需要时间比较久；第一次是必须运行的； %%
        clear station_tf_download path_station_historyData_SM;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
%%
match_Index1_yo=1
if(match_Index1_yo==1)  
    fprintf('├──「加载work_table.mat」\n')
    load work_table.mat
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('       ├──Step*. 循环nc文件，为同化做准备，且能对背景场数据和nc进行简单对比分析，\n')
    fprintf('           ├──Step1. 循环nc，\n')
    path_nc = strcat(path_save,'nc/');
    fileFolder = fullfile(path_nc);
    dirOutput = dir(fullfile(fileFolder,'*.nc'));
    fileNames = {dirOutput.name}'; % 20x1 cell, relative path, 
    wildcards = strcat(path_nc,fileNames); % 20x1 cell, wildcards, absolute path,
    clear fileFolder dirOutput path_nc; 
    for i=1:length(fileNames)
        tic
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('           ├──Step2 「重要参数」，\n')
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
        fprintf('           ├──Step3「函数」每个浮标与网格点匹配，\n')
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
        fprintf('           ├──Step4「函数」在work_table中的添加_ndbc_nc_match_WVHT,\n')
        path_Ndbc_nc_match_Hs_Fig = strcat(path_save,ncNameInTable,'_Ndbc_nc_match_Hs_Fig/');
        path_Ndbc_nc_match_Hs = strcat(path_save,ncNameInTable,'_Ndbc_nc_match_Hs/');
        mkdir(path_Ndbc_nc_match_Hs_Fig);
        mkdir(path_Ndbc_nc_match_Hs);
        [work_table] = analyse_HS(path_Ndbc_nc_match_Hs_Fig,path_Ndbc_nc_match_Hs,...
            path_Nc_time_Hs,work_table,station_tf_download,path_save,ncNameInTable);  %很早被定义过的...
        clear path_Ndbc_nc_match_Hs_Fig;
        path_Ndbc_nc_match = path_Ndbc_nc_match_Hs;
        clear path_Ndbc_nc_match_Hs;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %fprintf('           ├──Step5「函数」根据 下的所有文件生成每个所需同化时刻的Index1和yo文件txt,\n')
        %path_Index1 = strcat(path_save,ncNameInTable,'_Index1/');
        %path_yo = strcat(path_save,ncNameInTable,'_yo/');
        %mkdir(path_Index1); % rmdir(path_Index1,'s')
        %mkdir(path_yo); % rmdir(path_yo,'s')
        %[work_table] = Index1_And_yo(path_Index1,path_yo,...
        %    path_Ndbc_nc_match,path_save,work_table,ncNameInTable); %很早被定义过的...
        %clear path_Index1;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % toc
        %fprintf('           ├──Step6「函数」根据 下的所有文件的名称，得到所有需要同化的时刻，求出所有时刻在nc的索引，保存在Index.txt,\n')
        %path_Index = strcat(path_save,ncNameInTable,'_Index/');
        %mkdir(path_Index);
        %[work_table] = Index(path_Index,...
        %    work_table,nctime,path_yo); %很早被定义过的...
        %clear path_Index;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
end 
%%
Index1_yo=0
if(Index1_yo==1)
    cd(path_save)
    system('rm -rf Index1')
    system('rm -rf yo')
    mkdir('Index1')
    mkdir('yo')
    fprintf('├──「加载work_table.mat」\n')
    load work_table.mat
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('           ├──Step1「函数」每个浮标与网格点匹配，\n')
    fprintf('                         每个浮标在H观测矩阵的索引，\n')
    path_nc = strcat(path_save,'nc/');
    fileFolder = fullfile(path_nc);
    dirOutput = dir(fullfile(fileFolder,'*.nc'));
    fileNames = {dirOutput.name}'; % 20x1 cell, relative path, 
    wildcards = strcat(path_nc,fileNames); % 20x1 cell, wildcards, absolute path,
    clear fileFolder dirOutput path_nc fileNames; 
    ncid = wildcards{1};                                    %'ww3_2011.nc'; %绝对路径，
    nclat = ncread(ncid,'latitude');                        %填写纬度名称
    nclon = ncread(ncid,'longitude');                       %填写经度名称
    for i=1:1:size(work_table,1)
        % lat 最近网格点经纬度
        [~,temp1] = min(abs(nclat(:)-work_table.lat(i,1))); 
        work_table.matchNC_lat{i,1} = nclat(temp1);
        work_table.matchNC_lat{i,2} = temp1; %索引位置

        % lon 最近网格点经纬度
        [~,temp2] = min(abs(nclon(:)-work_table.lon(i,1))); % 
        work_table.matchNC_lon{i,1} = nclon(temp2);
        work_table.matchNC_lon{i,2} = temp2; %索引位置
        
        % 在H矩阵的索引
        work_table.IndexInHmatrix{i,1} = (temp1-1)*length(nclon)+temp2;
    end
    clear ncid nclat nclon wildcards;
    %%
    cd(path_save)
    save work_table work_table
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('           ├──Step2 循环每个浮标的.mat，实现每个浮标一个小时一个Hs，是有效的Hs，就生成每个所需同化时刻的Index1和yo文件txt，\n')
    cd(path_save)
    
    for i=1:1:size(work_table,1)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 实现每个浮标一个小时一个Hs
        %% 去除ndbc数据table无效数据所在行
        temp = strcat(path_save,'station_historyData_SM/',num2str(i),'.mat');
        load(temp); % temp 中仅有 buoy_table_All 变量；
        ndbc_table = buoy_table_All;
        ndbc_WVHT1 = cell2mat(ndbc_table.WVHT(:)); %double
        ndbc_time1 = ndbc_table.YY_MM_DD_hh_mm; % datetime
        tf1 = find( ndbc_WVHT1>=0 & ndbc_WVHT1<99 );
        
        ndbc_time2 = ndbc_time1(tf1);
        ndbc_WVHT2 = ndbc_WVHT1(tf1);
        disp(strcat('                       已去除ndbc数据table无效数据所在行；'));
        %% ndbc数据，一个小时一个数据
        % 超过30分钟，进一个小时
        tf2 = find( ndbc_time2.Minute>=30 & ndbc_time2.Minute<60 ); % case1, 秒数都是0，因为ndbc不包含秒数信息；
        temp = ndbc_time2(tf2); temp.Minute = 0; temp.Hour = temp.Hour+1;
        ndbc_time2(tf2) = temp;
        % 少于30分钟，小时不变
        tf3 = find( ndbc_time2.Minute>0 & ndbc_time2.Minute<30 ); % case2；
        temp = ndbc_time2(tf3); temp.Minute = 0;
        ndbc_time2(tf3) = temp;
        % 年、月、日、时相等的datetime处理：
        count = tabulate(ndbc_time2); % 统计数列中每个元素出现的次数
        tf4 = find(cell2mat(count(:,2))>1); % 元素次数超过1次
        for j=1:1:size(tf4,1) %元素次数超过1次的元素进行平均化处理
            temp = datetime(count{tf4(j),1});
            tf5 = find(ndbc_time2==temp);
            ndbc_WVHT2(tf5(1)) = mean(ndbc_WVHT2(tf5)); %平均化处理
            ndbc_WVHT2(tf5(2:end)) = 99; %无效数据
            % ndbc_WVHT2(tf5)
        end
        tf6 = find( ndbc_WVHT2>=0 & ndbc_WVHT2<99 );
        ndbc_time3 = ndbc_time2(tf6); % unique(ndbc_time3); %通过维数不变，发现每一个元素都是唯一的;
        ndbc_WVHT3 = ndbc_WVHT2(tf6);
        disp(strcat('                     已实现ndbc数据，一个小时一个数据，（通过了unique(ndbc_time3)的检验）；'));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 是有效的Hs，就生成每个所需同化时刻的Index1和yo文件txt
        for j=1:1:size(ndbc_time3,1)
            %
            time = ndbc_time3(j);
            time_str = datestr(time,'yyyymmddTHHMMSS');
            if(str2num(time_str(1:4))>2010 && str2num(time_str(1:4))<2012)
                Index1_filename = strcat(path_save,'Index1/',time_str,'.txt');
                yo_filename = strcat(path_save,'yo/',time_str,'.txt');
                if ~exist(Index1_filename)
                    f = fopen(Index1_filename,'w');
                    fclose(f);
                    f = fopen(yo_filename,'w');
                    fclose(f);
                    clear f;
                end
                clear time time_str;
                %
                Index1 = work_table.IndexInHmatrix(i); Index1 = cell2mat(Index1);
                f = fopen(Index1_filename,'a');
                fprintf(f,'%d\n',Index1);
                fclose(f);
                clear str f;
                yo = ndbc_WVHT3(j);
                f = fopen(yo_filename,'a');
                fprintf(f,'%f\n',yo);
                fclose(f);
                clear f;
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
end
%%
