function [ndbc_station_info] = ndbc_station_info(str,path_save)
% author:
%    liu jin can, UPC

% revison history
%    2022-02-12 first verison.
%    2022-02-19 second, function, path_save.

%%
disp('-----------------------ndbc_station_info')
cd(path_save)

%%
if contains(str,'default')
    load ndbc_station_info.mat
    save(strcat(path_save,'ndbc_station_info'),'ndbc_station_info')
else
    %% webread 正常运行
    url1 = 'https://www.ndbc.noaa.gov/to_station.shtml';
    %url2 = 'http://www.ndbc.noaa.gov/to_station.shtml'; %http 和 https 的区别：https://www.zhihu.com/question/436800837
    %url3 = 'https://blog.csdn.net/';
    %url4 = 'https://www.ndbc.noaa.gov';
    %url5 = 'http://baidu.com';
    
    UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:97.0) Gecko/20100101 Firefox/97.0';%如何查看火狐浏览器的useragent：https://blog.csdn.net/weixin_39892788/article/details/89875983
    %UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36';
    
    %options = weboptions();
    %options = weboptions('UserAgent',UserAgent);
    options = weboptions('UserAgent',UserAgent,'Timeout',120); %针对自己的浏览器填写
    % ,'CertificateFilename',''
    %设置模拟浏览器：https://blog.csdn.net/qq_40845110/article/details/115215561
    
    station_list_pagesource = webread(url1,options); %读取station_list的网页源代码
    %webread 和 urlread 的功能一样，[Contents Status] = urlread('https://www.ndbc.noaa.gov/to_station.shtml');
    
    %-------------------------------------------------------------------
    %  ps1：webread运行失败，直接去网页复制源代码所有内容，简单粘贴赋值给一个变量是不能的，另外，对于大量网页也是不可行的；
    %  ps2：webread运行失败可能的报错：未建立与 "https://www.ndbc.noaa.gov/to_station.shtml" 的安全连接，因为 "schannel: failed to receive handshake, SSL/TLS connection failed"。请检查您的系统证书是否过期、丢失或无效。
    %       webread运行失败可能的报错：无法建立与 "www.ndbc.noaa.gov" 的安全连接。原因是 ""。请检查您的证书文件(D:\Program Files (x86)\MATLAB\R2017b\sys\certificates\ca\rootcerts.pem)中的证书是否已过期、丢失或无效。
    %       webread运行失败可能的报错：无法建立与 "https://www.ndbc.noaa.gov/to_station.shtml" 的安全连接。原因是 "schannel: failed to receive handshake, SSL/TLS connection failed"。可能服务器不接受 HTTPS 连接。
    %  ps3：本人遇到的情况，matlab 2020a webread运行失败， matlab 2017b 运行成功，但是第二天早上运行2017b又失败了；
    %                       matlab 2020a，导入证书后成功，但是过一会儿又失败了；
    %                       matlab 2020a，导入证书，关闭clash代理后，成功；（希望别过一会儿又失败了）
    %       不知道为什么 ndbc 总是时不时的在抽风，有时候网页登不上去，不知道是不是自己网络的问题；
    %-------------------------------------------------------------------
    disp('ndbc webread 能正常运行。');
    table_station = table; %table类型；
    
    %% Text Analytics Toolbox 提取所有浮标ID（需要下载 Text Analytics Toolbox，下载时也需要关闭clash代理）
    hT = htmlTree(station_list_pagesource); %解析网页源代码
    %-------------------------------------------------------------------
    %  ps1：help htmlTree，2020版本有提示：'htmlTree' 需要 Text Analytics Toolbox。
    %                      2017没有提示；
    %-------------------------------------------------------------------
    
    % 在浏览器的网页中，观察源代码，发现所有浮标ID都在 <a></a> 标签里，
    % 且标签中的 href 都有h"station_page.php?station=" 部分；
    A_label = findElement(hT,'a'); %获取页面中所有a标签；
    A_label_href = getAttribute(A_label,'href'); %获取所有a标签的href内容；
    A_label_needed = A_label(contains(A_label_href,'station_page.php?station=')); %获取包含浮标ID的所有a标签
    %A_label_needed(171)
    %extractHTMLText(A_label_needed(171))
    station_ID = extractHTMLText(A_label_needed); %获取所有浮标的ID；
    
    
    disp('Text Analytics Toolbox 提取所有浮标ID成功。');
    save(strcat(path_save,'station_ID'),'station_ID')
    table_station.station_ID = station_ID; %将浮标的ID保存到table_station的第一列；
    
    %% Text Analytics Toolbox 提取每个浮标经度、纬度，tic toc 30分钟?
    station_lon = [];
    station_lat = [];
    warning_station = [];
    for i=1:1:size(table_station,1)
        % table_station 与 A_label_needed 站点ID一一顺序对应，不对应，输出错误；
        if(table_station{i,1}==extractHTMLText(A_label_needed(i)))
            % 获取网页的b标签内容
            href = getAttribute(A_label_needed(i),'href'); %得到指定浮标的href
            url = 'https://www.ndbc.noaa.gov/'+ href;
            pagesource = webread(url,options); %html
            
            hT = htmlTree(pagesource); %htmlTree
            B_label = findElement(hT,'b'); %b label
            B_text = extractHTMLText(B_label); % b label text
            
            % 从b标签内容筛选出lat和lon
            text0 = B_text( contains(B_text,'°') & ...
                contains(B_text,'(') & ...
                contains(B_text,')') & ...
                contains(B_text,'"')); % str,contains,?   % 例如显示为 "30.517 N 152.127 E (30°31'2" N 152°7'38" E)"
            if size(text0,1)~=1
                warning(table_station{i,1}+'经纬度提取失败，text0的维度不为1,为'+num2str(size(text0,1))+'。（大于1时很可能报错。）');
                warning_station = [warning_station;{table_station{i,1}}]
                lat = nan;
                lon = nan;
            else
                text0 = char(text0); %单引号 char, 双引号 string ：https://blog.csdn.net/weixin_43793141/article/details/105084788
                temp = strfind(text0,' '); %text 中空格的位置
                lat = text0(1:temp(1)+1); % char索引得到lat字符串
                lon = text0(temp(2)+1:temp(3)+1);
                disp('Text Analytics Toolbox 提取'+table_station{i,1}+'浮标经度、纬度成功。'+'i='+num2str(i));
            end
            % 加到station_lon，station_lat
            station_lat = [station_lat;{lat}]; % 以cell形式存储，加了{}
            station_lon = [station_lon;{lon}];
            
            
        else
            error('Text Analytics Toolbox 提取'+table_station{i,1}+'浮标经度、纬度时出错。');
        end
    end
    
    disp('Text Analytics Toolbox 提取每个浮标经度、纬度完成。');
    %save station_lat station_lat
    save(strcat(path_save,'station_lat'),'station_lat')
    save(strcat(path_save,'station_lon'),'station_lon')
    %save station_lon station_lon
    table_station.station_lat = station_lat;
    table_station.station_lon = station_lon;
    
    %% Text Analytics Toolbox 提取 Standard Meterological 历史数据年份信息
    station_historyYear = [];
    warning_station = [];
    url = 'https://www.ndbc.noaa.gov/historical_data.shtml';
    pagesource = webread(url,options);
    hT = htmlTree(pagesource); %htmlTree
    LI_label = findElement(hT,'li'); % li label, LI_label(13)
    LI_label_needed = LI_label(13); % 包含 Standard Meterological 的li label
    A_label = findElement(LI_label_needed,'a'); %a label
    A_label_href = getAttribute(A_label,'href'); %获取所有a标签的href内容；
    
    for i=1:1:size(table_station,1)
        temp = strcat('/download_data.php?filename=',lower(table_station{i,1}));%选择标准
        A_label_needed = A_label(contains(A_label_href,temp));
        if size(A_label_needed,1)>0
            historyYear = [extractHTMLText(A_label_needed)'];
            disp('Text Analytics Toolbox 提取'+table_station{i,1}+'的 Standard Meterological 历史数据年份信息成功。'+'i='+num2str(i));
        else
            warning(table_station{i,1}+'的 Standard Meterological 历史数据年份信息提取失败，historyYear的维度不大于0,为'+num2str(size(A_label_needed,1))+'。');
            warning_station = [warning_station;{table_station{i,1}}]
            historyYear = nan;
        end
        station_historyYear = [station_historyYear;{historyYear}];
    end
    
    disp('Text Analytics Toolbox 提取 Standard Meterological 历史数据年份信息完成。');
    %save station_historyYear station_historyYear
    save(strcat(path_save,'station_historyYear'),'station_historyYear')
    table_station.station__historyYear_SM = station_historyYear;
    
    %% ndbc_station_info
    ndbc_station_info = table_station;
    %save ndbc_station_info ndbc_station_info
    save(strcat(path_save,'ndbc_station_info'),'ndbc_station_info')
end

end




