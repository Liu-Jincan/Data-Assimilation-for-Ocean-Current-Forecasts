function match_Index1_yo(inputArg1,inputArg2,path_save,path_Ndbc_nc_match)
%MATCH_INDEX1_YO Summary of this function goes here
%   Detailed explanation goes here

% inputArg1 = HindexINtable = 'ww3_2018_nc_IndexInHmatrix';
% inputArg2 = buoynumNeededForDA = [9 12 18];

cd(path_save);
load work_table.mat


fileFolder = fullfile(path_Ndbc_nc_match);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
fileNames = {dirOutput.name}'; % 20x1 cell, relative path, 
wildcards = strcat(path_Ndbc_nc_match,fileNames); % 20x1 cell, wildcards, absolute path,

for i=1:1:length(wildcards)
    % select buoynumNeededForDA
    str = fileNames{i};
    str = str(1:end-4);
    if (length(find(str2num(str)==inputArg2))==1)
        %
        load(wildcards{i});  % ndbc_nc_match_WVHT imported
        for j=1:1:length(ndbc_nc_match_WVHT.time) % time dimension, cycle, 
            time = ndbc_nc_match_WVHT.time(j);
            time_str = datestr(time,'yyyymmddTHHMMSS');
            %
            Index1_filename = strcat(path_save,'Index1/',time_str,'.txt');
            yo_filename = strcat(path_save,'yo/',time_str,'.txt');
            if ~exist(Index1_filename)
                f = fopen(Index1_filename,'w');
                fclose(f);
                f = fopen(yo_filename,'w');
                fclose(f);
                clear f;
            end
            clear time time_str;
            % import Index1 data into the txt, from work_table
            str = fileNames{i};
            str = str(1:end-4);
            
            temp = str2num(str);
            Index1 = work_table.ww3_2018_nc_IndexInHmatrix(temp); %%
            
            Index1 = cell2mat(Index1);
            f = fopen(Index1_filename,'a');
            fprintf(f,'%d\n',Index1);
            fclose(f);
            clear str f;
            % import yo data into the txt, from ..
            yo = ndbc_nc_match_WVHT.ndbc(j);
            f = fopen(yo_filename,'a');
            fprintf(f,'%f\n',yo);
            fclose(f);
            clear f;
        end
    end
end




