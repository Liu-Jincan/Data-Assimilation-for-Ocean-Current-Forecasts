function ndbc_station_mat_num2buoynum(inputArg1,path_save)
%NDBC_STATION_MAT Summary of this function goes here
%   Detailed explanation goes here


% inputArg1='num2buoynum';
% path_save = '/1t/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/work_eastUSA2/';
cd(path_save)

s2={32};

% str=strcat('mkdir -p',s2,path_save,inputArg1,'_num2buoynum');
% str=str2mat(str)
% system(str);
% 
% str=strcat('cp',s2,path_save,inputArg1,'/*.mat',s2,path_save,inputArg1,'_num2buoynum/');
% str=str2mat(str)
% system(str);


load work_table.mat
str=strcat(path_save,inputArg1);
cd(str)


str=strcat(path_save,inputArg1);
fileFolder=fullfile(str);
dirOutput=dir(fullfile(fileFolder,'*.mat'));
fileNames={dirOutput.name};

for i=1:1:length(fileNames)
    str=fileNames{i};
    num=isstrprop(str,'digit'); 
    num=str(num);
    num=str2num(num);
    str2=work_table.station_ID(num);
    str2=strcat(str2,'.mat');

    str3=strcat('mv ',s2,str,s2,str2);
    system(str3);
end


