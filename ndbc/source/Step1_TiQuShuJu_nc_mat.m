function [Matrix] = Step1_TiQuShuJu_nc_mat(filename,YearAnaMonth)
%step1_TiQuShuJu_nc_mat ��ȡ�Ϻ���nc��ERA5���ݣ�����ɾ���һ����һ������

%% �Ϻ���Ϣ
area = 'NanHai';
LatMin = 9;
LatMax = 24;
LonMin = 105;
LonMax = 120;


%% ncread/select
% ����all features
Lat = ncread(filename,'latitude'); %γ��
Lon = ncread(filename,'longitude'); %����
mwd = ncread(filename,'mwd'); %ƽ������
mwp = ncread(filename,'mwp'); %ƽ��������
shts = ncread(filename,'shts'); %ӿ�˲���
shww = ncread(filename,'shww'); %���˲���
sst = ncread(filename,'sst'); %�����¶�
swh = ncread(filename,'swh'); %��Ч����
time1 = ncread(filename,'time'); %ʱ��
u10 = ncread(filename,'u10'); %U��
v10 = ncread(filename,'v10'); %V��

% ����select
Lat_select = find(Lat>=LatMin & Lat<=LatMax);
Lon_select = find(Lon>=LonMin & Lon<=LonMax);

%% �洢����

[~,~,hang3] = size(swh);
hang4 = length(Lat_select);
hang5 = length(Lon_select);
Matrix = zeros(hang4*hang5*hang3,16);

%% �洢
%*********************************************************************
% ������γ��ѭ��/�ļ�����
node_num = 1; %�����
suoyin = 1; %��������
for i=1:1:length(Lat_select) %10
    for j=1:1:length(Lon_select) %20
        
        t1 = datenum(1900,01,01,00,00,00);
        wave = swh(Lon_select(j),Lat_select(i),:);
        m = length(wave);
        for ii=1:m
            ii;
            %*************************************************************
            %ʱ������
            t2 = addtodate(t1,time1(ii),'hour');
            t3 = datestr(t2,'yyyy-mm-dd HH:MM:SS');
            t4 = datetime(t3);
            year1 = year(t4);
            month1 = month(t4);
            day1 = day(t4);
            hour1 = hour(t4);
            
            %**************************************************************
            %��������
            if (wave(ii) < 0)
                wave(ii) = nan;%NAN��������ҲӦ�ñ���
            end
            
            %**************************************************************
            %��������
            windspeed = sqrt((u10(Lon_select(j),Lat_select(i),ii))^2+(v10(Lon_select(j),Lat_select(i),ii))^2);
            
            %**************************************************************
            %�洢
            %{
           % 1   2   3   4    5     6       7        8          9         10       11        12        13    14
           % ��  ��  ��  ʱ  γ��  ����  ��Ч����  ƽ������  ƽ��������  ӿ�˲���  ���˲���   �����¶�    U��   V��
           %  15     16
           % ����   �����
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
        node_num = node_num+1 %�������1
        
    end
end


end

function main()
% 14641�����
% ��ȡһ���ļ�ʱ�䣺 ��ʱ 5219.425912 �롣   1.4498h��

tic
%% ������ͨ������꣺1958-2019��12���£�744��

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


