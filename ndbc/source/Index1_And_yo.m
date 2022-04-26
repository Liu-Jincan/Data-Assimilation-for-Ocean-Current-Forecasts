function    [work_table] = Index1_And_yo(path_Index1,path_yo,...
    path_Ndbc_nc_match,path_save,work_table,ncNameInTable); %很早被定义过的...
% author:
%    liu jin can, UPC
%
% revison history
%    2022-04-26 first verison.
%
% reference:

%
fprintf('                   ├──step1. 该函数的执行目录为$(path_save),\n')
cd(path_save)

%
fprintf('                   ├──step2. 获取$(path_Ndbc_nc_match) 下所有.mat文件名称,\n')
fileFolder = fullfile(path_Ndbc_nc_match);
dirOutput = dir(fullfile(fileFolder,'*.mat'));
fileNames = {dirOutput.name}'; % 20x1 cell, relative path, 
wildcards = strcat(path_Ndbc_nc_match,fileNames); % 20x1 cell, wildcards, absolute path,
clear fileFolder dirOutput;

%
fprintf('                   ├──step3. 对于每个.mat文件,生成每个所需同化时刻的Index1和yo文件txt,\n')
for i=1:length(wildcards)
    fprintf('                           %d,\n',i);
    %
    if(i==1)
        fprintf('                       ├──step3.1. 获取.mat文件中的变量名,命名为ndbc_nc_match，用buoyIndex存储.mat在work_table对应的索引,\n')
    end
    struc = load(cell2mat(wildcards(i)));  % structure
    name = fieldnames(struc); % 获取结构体后那个未知的变量名
    ndbc_nc_match = getfield(struc, name{1}); %第一列为"time"，第二列为ndbc数据"ndbc"，
    clear struc name;
    str = cell2mat(fileNames(i));
    A = isstrprop(str,'digit');
    B = str(A);
    buoyIndex = str2num(B);
    clear str A B;
    %
    if(i==1)
        fprintf('                       ├──step3.2. 对于每个所需同化时刻，\n')
    end
    for j=1:1:size(ndbc_nc_match,1)
        %
        if(i==1 && j==1)
            fprintf('                           ├──step3.2.1. 确定在$(path_Index1)和$(path_yo)文件夹下生成对应时刻的txt，\n')
        end
        time = ndbc_nc_match.time(j);
        time_str = datestr(time,'yyyymmddTHHMMSS');
        Index1_filename = strcat(path_Index1,time_str,'.txt');
        yo_filename = strcat(path_yo,time_str,'.txt');
        if ~exist(Index1_filename)
            f = fopen(Index1_filename,'w');
            fclose(f);
            f = fopen(yo_filename,'w');
            fclose(f);
            clear f;
        end
        clear time time_str;
        %
        if(i==1 && j==1) 
            fprintf('                           ├──step3.2.2. 在$(path_Index1)和$(path_yo)文件夹下对应时刻的txt文件夹添加数据，\n')
        end
        str = strcat('Index1 = work_table.',ncNameInTable,'_IndexInHmatrix(',num2str(buoyIndex),'); ');
        eval(str)
        Index1 = cell2mat(Index1);
        f = fopen(Index1_filename,'a');
        fprintf(f,'%d\n',Index1);
        fclose(f);
        clear str f;
        yo = ndbc_nc_match.ndbc(j);
        f = fopen(yo_filename,'a');
        fprintf(f,'%f\n',yo);
        fclose(f);
        clear f;
        
    end
end
