function [lon_,lat_]=Step2_YanZhengFuBiaoDuiYingDeJingWeilDu(lat,lon,Matrix)
%Step2_YanZhengFuBiaoDuiYingDeJingWeilDu ��֤�����Ӧ�ľ�γ�� 

tic
%************************************************************************
%Ŀ�꾭γ��
% lat = 20.245;
% lon = 114.941;
%************************************************************************
%Matrix
% Matrix = NanHai_201101;

%************************************************************************
% ���������洢
[hang,~] = size(Matrix);
distance = zeros(hang,1);

%������
for i=1:1:hang
    lon2 = Matrix(i,6);
    lat2 = Matrix(i,5);
    d = lonlat2dis(lon,lat,lon2,lat2);
    distance(i) = d;
end

%��Сֵ��Ӧ������
suoyin = find(min(distance)==distance);

%************************************************************************
%�������ľ�γ��
lon_ = Matrix(suoyin(1),6);
lat_ = Matrix(suoyin(1),5);

%
toc
end 


function d=lonlat2dis(lon1,lat1,lon2,lat2)
%lonlat2dis ��γ��ת���ɾ���m�ĳ���

delta_lon=(lon2-lon1);
R = 6378137;%����뾶
lat1 = lat1 * pi/180.0;
lat2 = lat2 * pi/180.0;
a =lat1 -lat2;
b = (lon1 - lon2) * pi / 180.0;
sa2= sin(a / 2.0);
sb2 = sin(b / 2.0);
d = 2 * R * asin(sqrt(sa2 * sa2 + cos(lat1) * cos(lat2) * sb2 * sb2));
end

function main1()
%************************************************************************
%Ŀ�꾭γ��
lat = 20.245;  %20.25
lon = 114.941; %115

%************************************************************************
%Matrix
Matrix = NanHai_201101;

%%
[lon_,lat_] = Step2_YanZhengFuBiaoDuiYingDeJingWeilDu(lat,lon,Matrix);

end

