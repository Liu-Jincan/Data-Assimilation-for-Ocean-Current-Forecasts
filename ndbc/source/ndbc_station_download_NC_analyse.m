function [ndbc_station_download_NC] = ndbc_station_download_NC_analyse(ndbc_station_download_NC,station_tf_download,path_save,ncNameInTable)
    % author:
    %    liu jin can, UPC
    %
    % revison history
    %    2022-02-18 first verison.
    %    2022-02-18 second, ndbc_station_download_NC_analyse
    %    2022-02-19 third, function, path_save.
    %    2022-02-19        图床思想
    
    %clc, clear all
    %load ndbc_station_download_NC.mat
    %load ndbc_station_download_NC_analyse; ndbc_station_download_NC = ndbc_station_download_NC_analyse;
    %disp('已加载ndbc_station_download_NC.mat！'); pause(1);
    
    %%
    % disp('-----------------------ndbc_station_download_NC_analyse')
    cd(path_save)
    
    
    %% 时间-WVHT数据，一个小时一个数据
    %-----------------------------
    %参数
    path_fig = '.\fig\'; %%https://ww2.mathworks.cn/help/matlab/ref/savefig.html?s_tid=gn_loc_drop
    %-----------------------------
    
    for i=station_tf_download%1:1:size(ndbc_station_download_NC,1)
        disp(strcat('                  ├──「',ndbc_station_download_NC.station_ID{i},'时间-WVHT数据分析，一个小时一个数据：」'));
        %% 去除ndbc数据table无效数据所在行
        temp = strcat(path_save,'station_historyData_SM/',num2str(i),'.mat');
        load(temp); % temp 中仅有 buoy_table_All 变量；
        %ndbc_table = ndbc_station_download_NC.station_historyData_SM{i,1}; %table
        ndbc_table = buoy_table_All;
        ndbc_WVHT1 = cell2mat(ndbc_table.WVHT(:)); %double
        ndbc_time1 = ndbc_table.YY_MM_DD_hh_mm; % datetime
        tf1 = find( ndbc_WVHT1>=0 & ndbc_WVHT1<99 );
        
        ndbc_time2 = ndbc_time1(tf1);
        ndbc_WVHT2 = ndbc_WVHT1(tf1);
        disp(strcat('                       已去除ndbc数据table无效数据所在行；'));
        %% ndbc数据，一个小时一个数据
        % 超过30分钟，进一个小时
        tf2 = find( ndbc_time2.Minute>30 & ndbc_time2.Minute<60 ); % case1, 秒数都是0，因为ndbc不包含秒数信息；
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
        disp(strcat('                       已实现ndbc数据，一个小时一个数据，（通过了unique(ndbc_time3)的检验）；'));
        %% nc 数据，一个小时一个数据；
        disp(strcat('                       已确定nc数据，一个小时一个数据；'));
        %% ndbc 和 nc 小时数据匹配；
        % 组合ndbc和nc的数据
        eval(['temp = ndbc_station_download_NC.',ncNameInTable,'_nc_time_WVHT{i,1};'])
        ndbc_nc_time = [ndbc_time3;temp{:,1}]; %ndbc 和 nc的datetime数据组合
        ndbc_nc_WVHT = [ndbc_WVHT3;temp{:,2}]; %ndbc 和 nc的WVHT数据组合
        % 匹配
        ndbc_nc_match_WVHT = table;
        count = tabulate(ndbc_nc_time); %匹配的时间元素，会出现2次，而且不可能超过两次；
        tf7 = find(cell2mat(count(:,2))>1); % 元素次数超过1次
        temp1 = []; %存储时间
        temp2 = []; %存储ndbc数据
        temp3 = []; %存储nc数据
        for j=1:1:size(tf7,1)
            temp = datetime(count{tf7(j),1});
            tf8 = find(ndbc_nc_time==temp);
            temp1 = [temp1;temp];
            temp2 = [temp2;ndbc_nc_WVHT(tf8(1))];
            temp3 = [temp3;ndbc_nc_WVHT(tf8(2))];
        end
        ndbc_nc_match_WVHT.time = temp1;
        ndbc_nc_match_WVHT.ndbc = temp2;
        ndbc_nc_match_WVHT.nc = temp3;
        disp(strcat('                       已对 ndbc 和 nc 小时数据匹配；'));
        %% 匹配数据分析
        if size(tf7,1)<3
            disp(strcat('                       发现',ndbc_station_download_NC.station_ID{i},'匹配的数据不足3个'));pause(1);
            oooooo = strcat('发现',ndbc_station_download_NC.station_ID{i},'匹配的数据不足3个');
            eval(['ndbc_station_download_NC.',ncNameInTable,'_ndbc_nc_match_WVHT{i,1} = oooooo;'])
        else
            % 时序图
            f = figure(1);
            plot(ndbc_nc_match_WVHT.time,ndbc_nc_match_WVHT.ndbc);
            hold on; plot(ndbc_nc_match_WVHT.time,ndbc_nc_match_WVHT.nc);
            %close(f1)
            savefig(f,strcat(path_fig,ndbc_station_download_NC.station_ID{i},'一小时时间-WVHT数据-时序图','.fig')); %https://ww2.mathworks.cn/help/matlab/ref/savefig.html?s_tid=gn_loc_drop
            ndbc_nc_match_WVHT.TimeSeriesChart{1,1} = strcat('openfig("',path_fig,ndbc_station_download_NC.station_ID{i},'一小时时间-WVHT数据-时序图','.fig")');
            close(f)
            %openfig('1.fig');
            disp(strcat('                       已简单画出时序图，并保存;'));
            
            % rmse, bias, R, SI, PE
            error = ndbc_nc_match_WVHT.ndbc-ndbc_nc_match_WVHT.nc;
            rmse = sqrt(mean(error.*error));
            bias = mean(-1*error);
            r = min(min(corrcoef(ndbc_nc_match_WVHT.ndbc, ndbc_nc_match_WVHT.nc)));
            PE = sqrt(mean((error./ndbc_nc_match_WVHT.ndbc).^2))*100;
            SI = rmse/mean(ndbc_nc_match_WVHT.ndbc);
            
            ndbc_nc_match_WVHT.rmse{1,1} = rmse;
            ndbc_nc_match_WVHT.bias{1,1} = bias;
            ndbc_nc_match_WVHT.r{1,1} = r;
            ndbc_nc_match_WVHT.PE{1,1} = PE;
            ndbc_nc_match_WVHT.SI{1,1} = SI;
            disp(strcat('                       已计算RMSE, BIAS, R, SI, PE，并保存;'));
            
            
            
            % 散点图
            [f,de] = DensScat(ndbc_nc_match_WVHT.ndbc,ndbc_nc_match_WVHT.nc);
            colormap('Jet')
            hc = colorbar;
            savefig(f,strcat(path_fig,ndbc_station_download_NC.station_ID{i},'一小时时间-WVHT数据-散点图','.fig'));
            ndbc_nc_match_WVHT.ScatterChart{1,1} = strcat('openfig("',path_fig,ndbc_station_download_NC.station_ID{i},'一小时时间-WVHT数据-散点图','.fig")');
            close(f)
            disp(strcat('                       已简单画出散点图，并保存;'));
            
            % 保存到总的table
            eval(['ndbc_station_download_NC.',ncNameInTable,'_ndbc_nc_match_WVHT{i,1} = ndbc_nc_match_WVHT;'])

            % save
            work_table = ndbc_station_download_NC;
            save work_table.mat work_table
        end


        
    end
    
    %%
    %ndbc_station_download_NC_analyse = ndbc_station_download_NC;
    %save ndbc_station_download_NC_analyse ndbc_station_download_NC_analyse
    
    end