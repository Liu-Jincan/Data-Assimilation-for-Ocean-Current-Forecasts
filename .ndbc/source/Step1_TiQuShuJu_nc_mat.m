function [Matrix] = Step1_TiQuShuJu_nc_mat(filename,YearAnaMonth)
%step1_TiQuShuJu_nc_mat 提取南海的nc的ERA5数据，保存成矩阵（一个月一个矩阵）

%% 南海信息
area = 'NanHai';
LatMin = 9;
LatMax = 24;
LonMin = 105;
LonMax = 120;


%% ncread/select
% ：：all features
Lat = ncread(filename,'latitude'); %纬度
Lon = ncread(filename,'longitude'); %经度
mwd = ncread(filename,'mwd'); %平均波向
mwp = ncread(filename,'mwp'); %平均波周期
shts = ncread(filename,'shts'); %涌浪波高
shww = ncread(filename,'shww'); %风浪波高
sst = ncread(filename,'sst'); %海面温度
swh = ncread(filename,'swh'); %有效波高
time1 = ncread(filename,'time'); %时间
u10 = ncread(filename,'u10'); %U风
v10 = ncread(filename,'v10'); %V风

% ：：select
Lat_select = find(Lat>=LatMin & Lat<=LatMax);
Lon_select = find(Lon>=LonMin & Lon<=LonMax);

%% 存储矩阵

[~,~,hang3] = size(swh);
hang4 = length(Lat_select);
hang5 = length(Lon_select);
Matrix = zeros(hang4*hang5*hang3,16);

%% 存储
%*********************************************************************
% ：：经纬度循环/文件输入
node_num = 1; %结点标记
suoyin = 1; %矩阵索引
for i=1:1:length(Lat_select) %10
    for j=1:1:length(Lon_select) %20
        
        t1 = datenum(1900,01,01,00,00,00);
        wave = swh(Lon_select(j),Lat_select(i),:);
        m = length(wave);
        for ii=1:m
            ii;
            %*************************************************************
            %时间数据
            t2 = addtodate(t1,time1(ii),'hour');
            t3 = datestr(t2,'yyyy-mm-dd HH:MM:SS');
            t4 = datetime(t3);
            year1 = year(t4);
            month1 = month(t4);
            day1 = day(t4);
            hour1 = hour(t4);
            
            %**************************************************************
            %波高数据
            if (wave(ii) < 0)
                wave(ii) = nan;%NAN，此数据也应该保存
            end
            
            %**************************************************************
            %风速数据
            windspeed = sqrt((u10(Lon_select(j),Lat_select(i),ii))^2+(v10(Lon_select(j),Lat_select(i),ii))^2);
            
            %**************************************************************
            %存储
            %{
           % 1   2   3   4    5     6       7        8          9         10       11        12        13    14
           % 年  月  日  时  纬度  经度  有效波高  平均波向  平均波周期  涌浪波高  风浪波高   海面温度    U风   V风
           %  15     16
           % 风速   结点数
            %}
            Matrix(suoyin,:) = [year1,month1,day1,hour1,Lat(Lat_select(i)),Lon(Lon_select(j)),...%6
                swh(Lon_select(j),Lat_select(i),ii),...
                mwd(Lon_select(j),Lat_select(i),ii),...
                mwp(Lon_select(j),Lat_select(i),ii),...
                shts(Lon_select(j),Lat_select(i),ii),...
                shww(Lon_select(j),Lat_select(i),ii),...
                sst(Lon_select(j),Lat_select(i),ii),...
                u10(Lon_select(j),Lat_select(i),ii),...
                v10(Lon_select(j),Lat_select(i),ii),...
                windspeed,node_num];
            
            suoyin = suoyin+1;
        end
        %%
        node_num = node_num+1 %结点数加1
        
    end
end


end

function main()
% 14641个结点
% 提取一个文件时间： 历时 5219.425912 秒。   1.4498h。

tic
%% 批处理通配符（年：1958-2019，12个月，744）

wildcards1 = 2001:1:2010%:1:2012;
wildcards2 = {'01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12'};

wildcards1 = 1991:1:2000%:1:2012;
wildcards2 = {'01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12'};

wildcards1 = 1981:1:1990%:1:2012;
wildcards2 = {'01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12'};

for i=1:1:length(wildcards1)
    for j=1:1:length(wildcards2)
        %% YearAnaMonth
        YearAnaMonth = strcat(num2str(wildcards1(i)),wildcards2(j));
        YearAnaMonth = cell2mat(YearAnaMonth);
        %
        %% filename
        filename = strcat('G:\TrendTendency\ERA5_China\ERA5_',YearAnaMonth,'.nc');
        %% Step1_TiQuShuJu_nc_mat
        M = Step1_TiQuShuJu_nc_mat(filename,YearAnaMonth);
        %% eval
        str = strcat('NanHai_',YearAnaMonth);
        eval([str '=M;']);
        %% save
        save(str,str);
        %% clear
        eval(['clear ' str]);
    end
end

toc


end


