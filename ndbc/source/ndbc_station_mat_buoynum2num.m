function ndbc_station_mat_buoynum2num(inputArg1,path_save)
%NDBC_STATION_MAT Summary of this function goes here
%   Detailed explanation goes here


% inputArg1='buoynum2num';
% path_save = '/1t/Data-Assimilation-for-Ocean-Current-Forecasts/ndbc/work_eastUSA2/';
cd(path_save)

s2={32};
% 
% str=strcat('mkdir -p',s2,path_save,inputArg2);
% str=str2mat(str)
% system(str);
% 
% str=strcat('cp',s2,path_save,inputArg1,'/*.mat',s2,path_save,inputArg1,'_num2buoynum/');
% str=str2mat(str)
% system(str);


load work_table.mat
str=strcat(path_save,inputArg1);
cd(str)


fileFolder=fullfile(str);
dirOutput=dir(fullfile(fileFolder,'*.mat'));
fileNames={dirOutput.name};

station_ID = work_table.station_ID;

for i=1:1:length(fileNames)
    str=fileNames{i};
    if(length( find(strcmp(str(1:end-4),station_ID)) ) == 1)
        str2=strcat(mat2str(find(strcmp(str(1:end-4),station_ID))),'.mat');

        str3=strcat('mv ',s2,str,s2,str2);
        str3=cell2mat(str3);

        system(str3);
    else
        str3=strcat('rm -rf',s2,str)
        str3=cell2mat(str3);
        system(str3)
    end
    
end


