tic
%% obsVec
%*****************************************************************
%��ȡdat�ļ� 
dat2011 = load('.\dat_txt\2011�Ⲩ�״�.dat');
dat2012 = load('.\dat_txt\2012�Ⲩ�״�.dat');

%*****************************************************************
%ѡ���·�
obsVec = [];
suoyin1 = find( dat2011(:,2)>=2 ); %2�� - 12��
obsVec = [obsVec;dat2011(suoyin1,1:5)];

suoyin2 = find( dat2012(:,2)<=6 ); %1�� - 6��
obsVec = [obsVec;dat2012(suoyin2,1:5)];



%% modelVec
%*****************************************************************
%��ȡ������
lat = 20.25; %20.245;  
lon = 115; %114.941; 

%*****************************************************************
%��ȡ���·� 
matNameCell = {'NanHai_201102','NanHai_201103','NanHai_201104','NanHai_201105',...
    'NanHai_201106','NanHai_201107','NanHai_201108','NanHai_201109','NanHai_201110',...
    'NanHai_201111','NanHai_201112',...
    'NanHai_201201','NanHai_201202','NanHai_201203','NanHai_201204','NanHai_201205','NanHai_201206'};
m = length(matNameCell);

%*****************************************************************
%��ȡ�����������
modelVec = [];
for i=1:1:m
    matName = cell2mat(matNameCell(i));
    eval(['M=' matName ';']);
    suoyin = find( M(:,5)==lat & M(:,6)==lon);
    vec = M(suoyin,[1,2,3,4,7]);
    
    modelVec = [modelVec;vec];
end

%% obsVec �� modelVec ά��ͳһ
[~,suoyin,~] = intersect(modelVec(:,1:4),obsVec(:,1:4),'rows');%https://zhidao.baidu.com/question/1691538867059847508.html

modelVec = modelVec(suoyin,5);
obsVec = obsVec(:,5);

%% ��֤
[outputVec1,outputVec2] = YanZheng(obsVec,modelVec)
toc

%% ��������
function [outputVec1,outputVec2] = YanZheng(obsVec,modelVec)
%*****************************************************************
% min,max,std,mean
outputVec1 = zeros(2,4);

outputVec1(1,1) = min(obsVec);
outputVec1(2,1) = min(modelVec);

outputVec1(1,2) = max(obsVec);
outputVec1(2,2) = max(modelVec);

outputVec1(1,3) = std(obsVec);
outputVec1(2,3) = std(modelVec);

outputVec1(1,4) = mean(obsVec);
outputVec1(2,4) = mean(modelVec);

%*****************************************************************
% N,rmse,bias,BI,SI,r
outputVec2 = zeros(1,6);

outputVec2(1,1) = length(obsVec);

rmse = sqrt(mean((modelVec-obsVec).^2));
outputVec2(1,2) = rmse;

bias = mean(obsVec-modelVec);
outputVec2(1,3) = bias;

BI = (bias/mean(obsVec))*100;
outputVec2(1,4) = BI;

SI = std(obsVec-modelVec)/mean(obsVec)*100;
outputVec2(1,5) = SI;

r = min(min(corrcoef(obsVec,modelVec)));
outputVec2(1,6) = r;

%*****************************************************************
% ʱ��ͼ
figure(1)
plot(obsVec,'-*');hold on;plot(modelVec);

%*****************************************************************
% Q-Qͼ
figure(2)
qqplot(obsVec,modelVec);axis([0 5 0 5]);hold on;plot([0 5],[0 5])
% axis([0 5 0 5]);qqplot(obsVec);hold on;axis([0 5 0 5]);qqplot(modelVec)

end




