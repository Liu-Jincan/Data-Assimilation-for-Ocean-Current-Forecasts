function [work_table] = Index(path_Index,...
    work_table,nctime,path_yo); %很早被定义过的...
% author:
%    liu jin can, UPC
%
% revison history
%    2022-04-26 first verison.
%
% reference:


%
% fprintf('                   ├──step1. 该函数的执行目录为$(path_save),\n')
% cd(path_save)

%
fprintf('                   ├──step1. 获取$(path_yo) 下所有.txt文件名称,\n')
fileFolder = fullfile(path_yo);
dirOutput = dir(fullfile(fileFolder,'*.txt'));
fileNames = {dirOutput.name}'; % 20x1 cell, relative path, 
wildcards = strcat(path_yo,fileNames); % 20x1 cell, wildcards, absolute path,
clear fileFolder dirOutput;

%
fprintf('                   ├──step2. 文件名称cell2mat类型,得到char数组$(char_fileNames)，\n')
%「」「，matlab中double、char和cell的互转，https://www.freesion.com/article/3832653024/
char_fileNames = cell2mat(fileNames);
char_fileNames = char_fileNames(:,1:end-4); %去除.txt后缀
cell_fileNames = cellstr(char_fileNames); 
clear char_fileNames;

% 
fprintf('                   ├──step3. datetime得到char数组$(char_time),\n')
UTtime = datetime('1990-01-01 00:00:00','InputFormat','yyyy-MM-dd HH:mm:ss')+nctime;
char_time = datestr(UTtime,'yyyymmddTHHMMSS');
cell_time = cellstr(char_time); 
clear UTtime char_time;

%
fprintf('                   ├──step4. $(cell_fileNames)每个元素在$(cell_time)的排序,\n')
%  」「」matlab 找到一个数组中元素在另个数组中的位置，有现成函数么 ，https://zhidao.baidu.com/question/536414460.html, char 类型用不了，
%           [~, Index] = ismember(char_fileNames,char_time)
%  」「」字符串数组查找matlab,Matlab之字符串数组查找, https://blog.csdn.net/weixin_29252859/article/details/116508526
%             cstr = {'How much wood would a woodchuck'; 'if a woodchuck could chuck wood?';}
%             cstr = {'How much wood would a woodchuck'; 'if a woodchuck could chuck wood?';'1';'1'};
%             str2 = 'if a woodchuck could chuck wood?';
%             str2 = {'if a woodchuck could chuck wood?'};
%             finger = ~cellfun(@isempty, strfind(cstr,str2));
%             finger = ~cellfun(@isempty, strfind(cstr,cstr));
%「」「」在Matlab中查找字符串数组中的字符串索引 ,https://www.thinbug.com/q/35637598
%             a = {'abcd'; 'efgh'; 'ijkl'; '21'; 'ijkl'};
%             b = {'efgh'; 'abcd'; 'ijkl'; '2121121'; 'ijkl'};
%             pos=[];
%             for i=1:size(a,1)
%                 AreStringFound=cellfun(@(x) strcmp(x,a(i,:)),b);
%                 pos=[pos find(AreStringFound)];
%             end
Index=[];
for i=1:size(cell_fileNames,1)
    AreStringFound=cellfun(@(x) strcmp(x,cell_fileNames(i,:)),cell_time); % cellfun, https://www.thinbug.com/q/35637598
    Index=[Index;find(AreStringFound)];
end
Index = int8(Index);
clear AreStringFound;


fprintf('                   ├──step5. 保存到txt,\n')
% 
Index_filename = strcat(path_Index,'Index.txt');
% save Index_filename -ascii Index 
% save(Index_filename,'-ascii','Index')
f = fopen(Index_filename,'w');
fprintf(f,'%d\n',length(Index));
fprintf(f,'\n');
for i=1:length(Index)
    fprintf(f,'%d\n',Index(i));
end
fclose(f); 
%
%