function [ndbc_station_info_needed] = ndbc_station_download(ndbc_station_info_needed,station_tf_download,path_save)
    % author:
    %    liu jin can, UPC
    %
    % revison history
    %    2022-02-14 first verison. bug：num2str()
    %    2022-02-15 second version. 使用 datetime 数据类型 
    %    2022-02-18 third, ndbc_station_download_NC_analyse
    %    2022-02-19 fourth, function, path_save.
    %    2022-02-19         图床思想, work_table.station_historyData_SM
    
    %clc, clear all
    %load ndbc_station_info_needed.mat
    %load ndbc_station_download_NC_analyse.mat; ndbc_station_info_needed = ndbc_station_download_NC_analyse;
    %disp('已加载ndbc_station_info_needed.mat！'); pause(1);
    
    %%
    cd(path_save)
    %
    UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:97.0) Gecko/20100101 Firefox/97.0';%如何查看火狐浏览器的useragent：https://blog.csdn.net/weixin_39892788/article/details/89875983
    options = weboptions('UserAgent',UserAgent,'Timeout',120); %针对自己的浏览器填写
    
    %% 提取浮标的 Standard Meterological 历史数据
    fprintf('                   ├──「Standard Meterological 历史数据」\n')
    fprintf('                           ├──「存储文件夹」station_historyData_SM/ \n')
    fprintf('                                   每个浮标生成一个mat文件，mat里只有一个变量buoy_table_All,\n')

    % mkdir station_historyData_SM
    for i=station_tf_download%1:1:size(ndbc_station_info_needed,1) %浮标循环
        fprintf('                           ├──「浮标索引」%d \n',i)
        temp_name = strcat('station_historyData_SM/',num2str(i),'.mat');
        % 确定存储浮标历史数据的数据结构：table
        buoy_table_All = table;
     
        % 记录导入失败的浮标
        buoy_fail = [];
        
        % 获取table中各项所需数据 18：YY  MM DD hh mm WDIR WSPD GST  WVHT   DPD   APD MWD   PRES  ATMP  WTMP  DEWP  VIS  TIDE
        fprintf('                              「浮标年份」查看work_table的station__historyYear_SM得到该浮标拥有的历史年份记录， \n')
        for j=1:1:size(ndbc_station_info_needed.station__historyYear_SM{i,1},2)%历史数据年份循环,[1 19]
            % 保存本年数据的table；
            buoy_table = table;
            
            % 获取浮标某年的网页数据；
            %   % size(ndbc_station_info_needed.station__historyYear_SM{12,1},2)
            %   % size(ndbc_station_info_needed.station__historyYear_SM{17,1},2)
            temp = ndbc_station_info_needed.station__historyYear_SM{i,1};
            nian = temp{1,j};
            url = 'https://www.ndbc.noaa.gov/view_text_file.php?filename='+...
                lower(ndbc_station_info_needed{i,1})+'h'+...
                nian+'.txt.gz&dir=data/historical/stdmet/';
            %url = 'https://www.ndbc.noaa.gov/view_text_file.php?filename=41002h1976.txt.gz&dir=data/historical/stdmet/';
            % 
            flag = 0; % 为了确保一定读取到网页内容～～
            while flag==0
                try
                    pagesource = webread(url,options); %pagesource(1:100)
                    flag = 1;
                catch
                    flag = 0;
                end
            end


            %temp=find(isstrprop(pagesource(1:200),'digit')==1);pagesource(1:temp(1));
            
            % 获取 pagesource 第一次出现数字的索引，从而通过str2num()得到数据矩阵
            temp = find(isstrprop(pagesource(1:200),'digit')==1); %数据中出现数字的索引；
            [data,tf]= str2num(pagesource(temp(1):end)); %网页上得到的一年的数据，后面会对其列数进行验证。
            %[data,tf]= str2num(pagesource(temp(1):166));  %1
            %[data,tf]= str2num(pagesource(temp(1):167));  %0
            %[data,tf]= str2num(pagesource(temp(1):246)); %1
            %  上面tf的变化，说明当第一行数据的列数确定后，猜测通过/enter换行？，后面的数据列数如果存在缺失，返回[]；
            %  上面的规则基本保证使用str2num()是没大问题的！
            
            
            % 判别网页数据格式是在哪一时间段，从而知道每一列代表什么；
            % ndbc 数据不同年份的数据格式：
            %          1970-1998，索引~79，16列，YY MM DD hh WD   WSPD GST  WVHT  DPD   APD  MWD  BAR    ATMP  WTMP  DEWP  VIS
            %          1999，索引~81，16列，YYYY MM DD hh WD   WSPD GST  WVHT  DPD   APD  MWD  BAR    ATMP  WTMP  DEWP  VIS
            %          2000-2004，索引~87，17列，YYYY MM DD hh WD   WSPD GST  WVHT  DPD   APD  MWD  BAR    ATMP  WTMP  DEWP  VIS  TIDE
            %          2005-2006，索引~90，18列，YYYY MM DD hh mm  WD  WSPD GST  WVHT  DPD   APD  MWD  BAR    ATMP  WTMP  DEWP  VIS  TIDE
            %          2007-2020，索引179>150，18列，#YY  MM DD hh mm WDIR WSPD GST  WVHT   DPD   APD MWD   PRES  ATMP  WTMP  DEWP  VIS  TIDE
            %                              #yr  mo dy hr mn degT m/s  m/s     m   sec   sec degT   hPa  degC  degC  degC   mi    ft
            
            
            if(size(data,2)==16 & pagesource(3)== ' ') %1970-1998
                % YY+1900 MM DD hh （mm=0） WD   WSPD GST  WVHT  DPD   APD MWD  BAR    ATMP  WTMP  DEWP  VIS (TIDE)
                % data 的改造
                data_time = datetime([data(:,1)+1900 data(:,2:4) zeros(size(data,1),2)]);
                data_other = [data(:,5:16) 99*ones(size(data,1),1)];
                % 导入 data 进入 table
                buoy_table.YY_MM_DD_hh_mm = data_time;
                buoy_table{1:size(data,1),2:14} = num2cell(data_other);
                %
                buoy_table_All = [buoy_table_All;buoy_table];
                disp('                                 准备导入'+lower(ndbc_station_info_needed{i,1})+'h'+nian+'数据到'+temp_name);
            elseif(size(data,2)==16 & pagesource(3)== 'Y') %1999
                % data 的改造
                data_time = datetime([data(:,1:4) zeros(size(data,1),2)]);
                data_other = [data(:,5:16) 99*ones(size(data,1),1)];
                % 导入 data 进入 table
                buoy_table.YY_MM_DD_hh_mm = data_time;
                buoy_table{1:size(data,1),2:14} = num2cell(data_other);
                %
                buoy_table_All = [buoy_table_All;buoy_table];
                disp('                                 准备导入'+lower(ndbc_station_info_needed{i,1})+'h'+nian+'数据到'+temp_name);
            elseif(size(data,2)==17) %2000-2004
                % data 的改造
                data_time = datetime([data(:,1:4) zeros(size(data,1),2)]);
                data_other = [data(:,5:17)];
                % 导入 data 进入 table
                buoy_table.YY_MM_DD_hh_mm = data_time;
                buoy_table{1:size(data,1),2:14} = num2cell(data_other);
                %
                buoy_table_All = [buoy_table_All;buoy_table];
                disp('                                 准备导入'+lower(ndbc_station_info_needed{i,1})+'h'+nian+'数据到'+temp_name);
            elseif(size(data,2)==18) %2005-2020
                % data 的改造
                data_time = datetime([data(:,1:5) zeros(size(data,1),1)]);
                data_other = [data(:,6:18)];
                % 导入 data 进入 table
                buoy_table.YY_MM_DD_hh_mm = data_time;
                buoy_table{1:size(data,1),2:14} = num2cell(data_other);
                %
                buoy_table_All = [buoy_table_All;buoy_table];
                disp('                                 准备导入'+lower(ndbc_station_info_needed{i,1})+'h'+nian+'数据到'+temp_name);
            else
                warning('                               '+lower(ndbc_station_info_needed{i,1})+'h'+nian+'不符合一般的数据格式特点？i='+num2str(i)+',j='+num2str(j)+',tf='+num2str(tf)+',导入至'+temp_name+'的table失败。');
                warning('                               若tf=0，那么str2num()出现问题，导致data=[]，根本原因可能是TIDE数据有缺失空白。')
                buoy_fail = [buoy_fail;{lower(ndbc_station_info_needed{i,1})+'h'+nian+'不符合一般的数据格式特点？i='+num2str(i)+',j='+num2str(j)+',tf='+num2str(tf)+',导入至'+temp_name+'的table失败。'}];
                %44008h2000不符合一般的数据格式特点？i=5,j=19  %%TIDE 有空白
                %44008h2017不符合一般的数据格式特点？i=5,j=35
                %error(lower(ndbc_station_info_needed{i,1})+'h'+nian+'可能在调用str2num()时出错，因为矩阵列数不为16，不符合1970-1998的数据格式特点？。');
            end
    
        end
        
        % 存储浮标历史数据的table保存到： ndbc_station_info_needed.station_historyData_SM{i,1}
        buoy_table_All.Properties.VariableNames = {'YY_MM_DD_hh_mm' 'WDIR' 'WSPD' 'GST'  'WVHT'   'DPD'   'APD' 'MWD'   'PRES'  'ATMP'  'WTMP'  'DEWP'  'VIS'  'TIDE'};
        buoy_table_All.Properties.VariableUnits = {'YY_MM_DD_hh_mm' 'degT' 'm/s' 'm/s' 'm' 'sec' 'sec' 'degT' 'hPa' 'degC' 'degC' 'degC' 'mi' 'ft'};
        buoy_table_All.Properties.VariableDescriptions = {'年月日小时分钟,秒数都默认为0，ndbc没包含此信息' 'degT' 'm/s' 'm/s' '有效波高' 'sec' 'sec' 'degT' 'hPa' 'degC' 'degC' 'degC' 'mi' 'ft'};
        %
        temp = strcat(path_save,'station_historyData_SM/',num2str(i),'.mat');
        save(temp,'buoy_table_All','-v7') %v7，压缩程度最大，但是限制2GB
        disp('                                 已成功导入'+lower(ndbc_station_info_needed{i,1})+'h'+nian+'数据到'+temp_name);
        %
        ndbc_station_info_needed.station_historyData_SM{i,1} = strcat(num2str(size(buoy_table_All,1)),'x',num2str(size(buoy_table_All,2)),',station_historyData_SM/',num2str(i),'.mat');
        ndbc_station_info_needed.station_historyData_SM{i,2} = buoy_fail;
        work_table = ndbc_station_info_needed;
        save work_table.mat work_table
        disp('                              「work_table」在work_table中的station_historyData_SM属性中，'+lower(ndbc_station_info_needed{i,1})+'浮标会显示'+temp_name+'文件位置和缺少的年份信息。');
    
    end
    
    %% save
    disp('                   ├──「done」已提取浮标的 Standard Meterological 历史数据，生成station_historyData_SM/*相关文件!')
    % ndbc_station_download = ndbc_station_info_needed;
    %cd(path_save)
    %save ndbc_station_download ndbc_station_download %可能占用内存特别大；
    
    %%
    %ndbc_station_download_NC_analyse = ndbc_station_info_needed;
    %save ndbc_station_download_NC_analyse ndbc_station_download_NC_analyse
    end
    