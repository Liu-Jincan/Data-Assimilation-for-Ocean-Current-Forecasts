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
    %% webread ��������
    url1 = 'https://www.ndbc.noaa.gov/to_station.shtml';
    %url2 = 'http://www.ndbc.noaa.gov/to_station.shtml'; %http �� https ������https://www.zhihu.com/question/436800837
    %url3 = 'https://blog.csdn.net/';
    %url4 = 'https://www.ndbc.noaa.gov';
    %url5 = 'http://baidu.com';
    
    UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:97.0) Gecko/20100101 Firefox/97.0';%��β鿴����������useragent��https://blog.csdn.net/weixin_39892788/article/details/89875983
    %UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36';
    
    %options = weboptions();
    %options = weboptions('UserAgent',UserAgent);
    options = weboptions('UserAgent',UserAgent,'Timeout',120); %����Լ����������д
    % ,'CertificateFilename',''
    %����ģ���������https://blog.csdn.net/qq_40845110/article/details/115215561
    
    station_list_pagesource = webread(url1,options); %��ȡstation_list����ҳԴ����
    %webread �� urlread �Ĺ���һ����[Contents Status] = urlread('https://www.ndbc.noaa.gov/to_station.shtml');
    
    %-------------------------------------------------------------------
    %  ps1��webread����ʧ�ܣ�ֱ��ȥ��ҳ����Դ�����������ݣ���ճ����ֵ��һ�������ǲ��ܵģ����⣬���ڴ�����ҳҲ�ǲ����еģ�
    %  ps2��webread����ʧ�ܿ��ܵı���δ������ "https://www.ndbc.noaa.gov/to_station.shtml" �İ�ȫ���ӣ���Ϊ "schannel: failed to receive handshake, SSL/TLS connection failed"����������ϵͳ֤���Ƿ���ڡ���ʧ����Ч��
    %       webread����ʧ�ܿ��ܵı����޷������� "www.ndbc.noaa.gov" �İ�ȫ���ӡ�ԭ���� ""����������֤���ļ�(D:\Program Files (x86)\MATLAB\R2017b\sys\certificates\ca\rootcerts.pem)�е�֤���Ƿ��ѹ��ڡ���ʧ����Ч��
    %       webread����ʧ�ܿ��ܵı����޷������� "https://www.ndbc.noaa.gov/to_station.shtml" �İ�ȫ���ӡ�ԭ���� "schannel: failed to receive handshake, SSL/TLS connection failed"�����ܷ����������� HTTPS ���ӡ�
    %  ps3�����������������matlab 2020a webread����ʧ�ܣ� matlab 2017b ���гɹ������ǵڶ�����������2017b��ʧ���ˣ�
    %                       matlab 2020a������֤���ɹ������ǹ�һ�����ʧ���ˣ�
    %                       matlab 2020a������֤�飬�ر�clash����󣬳ɹ�����ϣ�����һ�����ʧ���ˣ�
    %       ��֪��Ϊʲô ndbc ����ʱ��ʱ���ڳ�磬��ʱ����ҳ�ǲ���ȥ����֪���ǲ����Լ���������⣻
    %-------------------------------------------------------------------
    disp('ndbc webread ���������С�');
    table_station = table; %table���ͣ�
    
    %% Text Analytics Toolbox ��ȡ���и���ID����Ҫ���� Text Analytics Toolbox������ʱҲ��Ҫ�ر�clash����
    hT = htmlTree(station_list_pagesource); %������ҳԴ����
    %-------------------------------------------------------------------
    %  ps1��help htmlTree��2020�汾����ʾ��'htmlTree' ��Ҫ Text Analytics Toolbox��
    %                      2017û����ʾ��
    %-------------------------------------------------------------------
    
    % �����������ҳ�У��۲�Դ���룬�������и���ID���� <a></a> ��ǩ�
    % �ұ�ǩ�е� href ����h"station_page.php?station=" ���֣�
    A_label = findElement(hT,'a'); %��ȡҳ��������a��ǩ��
    A_label_href = getAttribute(A_label,'href'); %��ȡ����a��ǩ��href���ݣ�
    A_label_needed = A_label(contains(A_label_href,'station_page.php?station=')); %��ȡ��������ID������a��ǩ
    %A_label_needed(171)
    %extractHTMLText(A_label_needed(171))
    station_ID = extractHTMLText(A_label_needed); %��ȡ���и����ID��
    
    
    disp('Text Analytics Toolbox ��ȡ���и���ID�ɹ���');
    save(strcat(path_save,'station_ID'),'station_ID')
    table_station.station_ID = station_ID; %�������ID���浽table_station�ĵ�һ�У�
    
    %% Text Analytics Toolbox ��ȡÿ�����꾭�ȡ�γ�ȣ�tic toc 30����?
    station_lon = [];
    station_lat = [];
    warning_station = [];
    for i=1:1:size(table_station,1)
        % table_station �� A_label_needed վ��IDһһ˳���Ӧ������Ӧ���������
        if(table_station{i,1}==extractHTMLText(A_label_needed(i)))
            % ��ȡ��ҳ��b��ǩ����
            href = getAttribute(A_label_needed(i),'href'); %�õ�ָ�������href
            url = 'https://www.ndbc.noaa.gov/'+ href;
            pagesource = webread(url,options); %html
            
            hT = htmlTree(pagesource); %htmlTree
            B_label = findElement(hT,'b'); %b label
            B_text = extractHTMLText(B_label); % b label text
            
            % ��b��ǩ����ɸѡ��lat��lon
            text0 = B_text( contains(B_text,'��') & ...
                contains(B_text,'(') & ...
                contains(B_text,')') & ...
                contains(B_text,'"')); % str,contains,?   % ������ʾΪ "30.517 N 152.127 E (30��31'2" N 152��7'38" E)"
            if size(text0,1)~=1
                warning(table_station{i,1}+'��γ����ȡʧ�ܣ�text0��ά�Ȳ�Ϊ1,Ϊ'+num2str(size(text0,1))+'��������1ʱ�ܿ��ܱ�����');
                warning_station = [warning_station;{table_station{i,1}}]
                lat = nan;
                lon = nan;
            else
                text0 = char(text0); %������ char, ˫���� string ��https://blog.csdn.net/weixin_43793141/article/details/105084788
                temp = strfind(text0,' '); %text �пո��λ��
                lat = text0(1:temp(1)+1); % char�����õ�lat�ַ���
                lon = text0(temp(2)+1:temp(3)+1);
                disp('Text Analytics Toolbox ��ȡ'+table_station{i,1}+'���꾭�ȡ�γ�ȳɹ���'+'i='+num2str(i));
            end
            % �ӵ�station_lon��station_lat
            station_lat = [station_lat;{lat}]; % ��cell��ʽ�洢������{}
            station_lon = [station_lon;{lon}];
            
            
        else
            error('Text Analytics Toolbox ��ȡ'+table_station{i,1}+'���꾭�ȡ�γ��ʱ����');
        end
    end
    
    disp('Text Analytics Toolbox ��ȡÿ�����꾭�ȡ�γ����ɡ�');
    %save station_lat station_lat
    save(strcat(path_save,'station_lat'),'station_lat')
    save(strcat(path_save,'station_lon'),'station_lon')
    %save station_lon station_lon
    table_station.station_lat = station_lat;
    table_station.station_lon = station_lon;
    
    %% Text Analytics Toolbox ��ȡ Standard Meterological ��ʷ���������Ϣ
    station_historyYear = [];
    warning_station = [];
    url = 'https://www.ndbc.noaa.gov/historical_data.shtml';
    pagesource = webread(url,options);
    hT = htmlTree(pagesource); %htmlTree
    LI_label = findElement(hT,'li'); % li label, LI_label(13)
    LI_label_needed = LI_label(13); % ���� Standard Meterological ��li label
    A_label = findElement(LI_label_needed,'a'); %a label
    A_label_href = getAttribute(A_label,'href'); %��ȡ����a��ǩ��href���ݣ�
    
    for i=1:1:size(table_station,1)
        temp = strcat('/download_data.php?filename=',lower(table_station{i,1}));%ѡ���׼
        A_label_needed = A_label(contains(A_label_href,temp));
        if size(A_label_needed,1)>0
            historyYear = [extractHTMLText(A_label_needed)'];
            disp('Text Analytics Toolbox ��ȡ'+table_station{i,1}+'�� Standard Meterological ��ʷ���������Ϣ�ɹ���'+'i='+num2str(i));
        else
            warning(table_station{i,1}+'�� Standard Meterological ��ʷ���������Ϣ��ȡʧ�ܣ�historyYear��ά�Ȳ�����0,Ϊ'+num2str(size(A_label_needed,1))+'��');
            warning_station = [warning_station;{table_station{i,1}}]
            historyYear = nan;
        end
        station_historyYear = [station_historyYear;{historyYear}];
    end
    
    disp('Text Analytics Toolbox ��ȡ Standard Meterological ��ʷ���������Ϣ��ɡ�');
    %save station_historyYear station_historyYear
    save(strcat(path_save,'station_historyYear'),'station_historyYear')
    table_station.station__historyYear_SM = station_historyYear;
    
    %% ndbc_station_info
    ndbc_station_info = table_station;
    %save ndbc_station_info ndbc_station_info
    save(strcat(path_save,'ndbc_station_info'),'ndbc_station_info')
end

end




