function analyse_HS_spinup(inputArg1,inputArg2,inputArg3,inputArg4,path_save,path_fig)
%ANALYSE_HS_SPINUP Summary of this function goes here
%   Detailed explanation goes here

% inputArg1 = ndbc_spinup_datetime =datetime('2018-09-03 00:00:00','InputFormat','yyyy-MM-dd HH:mm:ss');
% inputArg2 = HS_matchnameINtable='ww3_2018_nc_ndbc_nc_match_WVHT';
% inputArg3 = ndbc_spinup_endtime=datetime('2020-08-15 00:00:00','InputFormat','yyyy-MM-dd HH:mm:ss');
% inputArg4 = ndbc_spinup_selectedbuoy=[11;12;13;20;21;23;25;29;30;119];

cd(path_save)
load work_table.mat

New_table = table;

%tf1 = string(work_table.ww3_2018_nc_ndbc_nc_match_WVHT); %%
str = strcat('tf1 = string(work_table.',inputArg2,');');
eval(str);

tf1 = strfind(tf1,'load');
tf2 = [];
for i=1:length(tf1)
    if length(tf1{i})>0
        tf2 = [tf2;1];
    else
        tf2=[tf2;0];
    end
end
tf2 = logical(tf2);


temp=(1:size(work_table,1))';
New_table.buoynum = temp(tf2);
New_table.station_ID = work_table.station_ID(tf2);

%New_table.match_WVHT = work_table.ww3_2018_nc_ndbc_nc_match_WVHT(tf2); %%
str = strcat('New_table.match_WVHT = work_table.',inputArg2,'(tf2);');
eval(str);

all_match_WVHT = [];  %% | ndbc | nc |
for i=1:length(New_table.station_ID)
    if ismember(New_table.buoynum(i),inputArg4)
        str = New_table.match_WVHT{i};
        eval(str); %%ndbc_nc_match_WVHT imported, | time | ndbc | nc |,
        tf3 = (ndbc_nc_match_WVHT.time > inputArg1) & (ndbc_nc_match_WVHT.time < inputArg3);
        ndbc_nc_match_WVHT = ndbc_nc_match_WVHT(tf3,:);

        if size(ndbc_nc_match_WVHT,1)>3
            %%
            % 时序图
            f = figure(1);
            plot(ndbc_nc_match_WVHT.time,ndbc_nc_match_WVHT.ndbc);
            hold on; plot(ndbc_nc_match_WVHT.time,ndbc_nc_match_WVHT.nc);
            %close(f1)
            savefig(f,strcat(path_fig,num2str(New_table.buoynum(i)),'-WVHT-timeseries-spinup','.fig')); %https://ww2.mathworks.cn/help/matlab/ref/savefig.html?s_tid=gn_loc_drop
            New_table.TimeSeriesChart{i,1} = strcat('openfig("',path_fig,num2str(New_table.buoynum(i)),'-WVHT-timeseries-spinup','.fig")');
            close(f)
            %openfig('1.fig');
            disp(strcat('                       已简单画出时序图，并保存;'));

            % rmse, bias, R, SI, PE
            error = ndbc_nc_match_WVHT.ndbc-ndbc_nc_match_WVHT.nc;
            rmse = sqrt(mean(error.*error));
            bias = mean(-1*error);
            r = min(min(corrcoef(ndbc_nc_match_WVHT.ndbc, ndbc_nc_match_WVHT.nc)));
            PE = sqrt(mean((error./ndbc_nc_match_WVHT.ndbc).^2))*100;
            SI = rmse/mean(ndbc_nc_match_WVHT.ndbc);

            New_table.rmse{i,1} = rmse;
            New_table.bias{i,1} = bias;
            New_table.r{i,1} = r;
            New_table.PE{i,1} = PE;
            New_table.SI{i,1} = SI;
            disp(strcat('                       已计算RMSE, BIAS, R, SI, PE，并保存;'));

            % scatter
            [f,de] = DensScat(ndbc_nc_match_WVHT.ndbc,ndbc_nc_match_WVHT.nc);
            colormap('Jet')
            hc = colorbar;
            savefig(f,strcat(path_fig,num2str(New_table.buoynum(i)),'-WVHT-scatter-spinup','.fig'));
            New_table.ScatterChart{i,1} = strcat('openfig("',path_fig,num2str(New_table.buoynum(i)),'-WVHT-scatter-spinup','.fig")');
            close(f)
            disp(strcat('                       已简单画出散点图，并保存;'));

            %%
            % all_match_WVHT
            all_match_WVHT = [all_match_WVHT;ndbc_nc_match_WVHT.ndbc ndbc_nc_match_WVHT.nc];
        end
        %%
    end

end

if(size(all_match_WVHT,1)>3)
    %
    i = i+1;
    New_table.station_ID(i) = 'ALL';

    % 时序图
    f = figure(1);
    plot(all_match_WVHT(:,1)); %ndbc
    hold on; plot(all_match_WVHT(:,2)); %nc
    %close(f1)
    savefig(f,strcat(path_fig,'ALL-WVHT-timeseries-spinup','.fig')); %https://ww2.mathworks.cn/help/matlab/ref/savefig.html?s_tid=gn_loc_drop
    New_table.TimeSeriesChart{i,1} = strcat('openfig("',path_fig,'ALL-WVHT-timeseries-spinup','.fig")');
    close(f)
    %openfig('1.fig');
    disp(strcat('                       已简单画出时序图，并保存;'));
    
    % rmse, bias, R, SI, PE
    error = all_match_WVHT(:,1)-all_match_WVHT(:,2);
    rmse = sqrt(mean(error.*error));
    bias = mean(-1*error);
    r = min(min(corrcoef(all_match_WVHT(:,1), all_match_WVHT(:,2) )));
    PE = sqrt(mean((error./all_match_WVHT(:,1)).^2))*100;
    SI = rmse/mean(all_match_WVHT(:,1));
    
    New_table.rmse{i,1} = rmse;
    New_table.bias{i,1} = bias;
    New_table.r{i,1} = r;
    New_table.PE{i,1} = PE;
    New_table.SI{i,1} = SI;
    disp(strcat('                       已计算RMSE, BIAS, R, SI, PE，并保存;'));

    % scatter
    [f,de] = DensScat(all_match_WVHT(:,1),all_match_WVHT(:,2));
    colormap('Jet')
    hc = colorbar;
    savefig(f,strcat(path_fig,'ALL-WVHT-scatter-spinup','.fig'));
    New_table.ScatterChart{i,1} = strcat('openfig("',path_fig,'ALL-WVHT-scatter-spinup','.fig")');
    close(f)
    disp(strcat('                       已简单画出散点图，并保存;'));
end

% a=1;
% work_table.ww3_2018_nc_ndbc_nc_match_WVHT_spinup{1,1} = New_table;
str = strcat('work_table.',inputArg2,'_spinup{1,1}=New_table;');
eval(str);
save work_table.mat work_table
disp(strcat('                       已在work_table保存相关信息'));
