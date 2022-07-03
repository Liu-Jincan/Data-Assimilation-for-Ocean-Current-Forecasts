clc, clear all
%***********************************************************************
%% 00. 参数
work_table_name='All_1950_1957.mat'
load(work_table_name)
lon_selected = [108 116 119 114 116 110];
lat_selected = [20 21 20 17 11 14];
LatDeg = 0.125
LatMax = 24;
LonDeg = 0.125
LonMin = 105;
year_strat = 1950;
year_end = 1957;
nianSTR = '1950_1957';
nianshu = 8;
%%01
havingdata = 1; %1表示拥有了数据
%%02
% GEV_IDM = 0;
% GEV_AM = 0;
% GEV_MM = 0;
GPD_POT = 0; %1表示执行此方法
% GPD_MIS = 0;







%%03
GPD_POT_canshugujikeshihua = 0;
rmse_bar = 1;
shape_VAR = 1;
scale_VAR = 1;
sum_VAR = 1;
%%04
qqplotss = 0;
%%05
returnlevelss = 0; %只能单独运行
%%06
SensitivityOfThreshold = 0;
%%07
SensitivityOfMTS = 0;
%%08
shapeVar = 0;

%% 01. 获得所需年份的数据，并保存成mat文件
if(havingdata==0)
    month_number = (year_end-year_strat+1)*12;
    % lon_selected = [108 116 119 114 116 110];
    % lat_selected = [20 21 20 17 11 14];
    kkkkk=1;
    while(kkkkk>0 & kkkkk<7)
        tic
        wildcards1 = year_strat:1:year_end
        wildcards2 = {'01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12'};

        P1 = nan(750,month_number);
        ij = 1;
        for i=1:1:length(wildcards1)
            i
            for j=1:1:length(wildcards2)
                %% YearAnaMonth
                YearAnaMonth = strcat(num2str(wildcards1(i)),wildcards2(j));
                YearAnaMonth = cell2mat(YearAnaMonth);
                %
                %% filename
                filename = strcat('../nc/ERA5_',YearAnaMonth,'.nc');
                %% JD
                M = ncread(filename,'swh');
                M = permute(M,[2 1 3]); %转置，结点与Panoply的array 1对应，nan+未转置图像判断是否正确（成功），（lat-索引大lat小，lon-索引大lon大，data）
                % lon: 110.125  105-120 0.125
                % lat: 17.125  9-24 0.125
                lon = (lon_selected(kkkkk)-LonMin)/LonDeg+1;%108 116 119 114 116 110
                lat = (LatMax-lat_selected(kkkkk))/LatDeg+1; %20 21 20 17 11 14
                M = M(lat,lon,:);


                P1(1:length(M),ij) = M;
                ij = ij+1;

                %% eval
                %str = strcat('NanHai_Hs_',YearAnaMonth);
                %eval([str '=M;']);
                %% save
                %save(str,str);
                %% clear
                %eval(['clear ' str]);
            end

        end

        toc %历时 264.228867 秒。
        % save('Step3_Hs_P5_','P1');
        str1233 = strcat('Step3_Hs_P',mat2str(kkkkk),'_',nianSTR);
        save(str1233,'P1');
        kkkkk = kkkkk+1;

    end
end

%% 02. GPD-POT模型和采样方法
for Psuoyin=1:1:length(lon_selected)
    Psuoyin
    filename = strcat('Step3_Hs_P',mat2str(Psuoyin),'_',nianSTR);
    load(filename);

    %
    IDM = P1(:);
    IDM = IDM(~isnan(IDM));

    % GEV_IDM
    %if(GEV_IDM==1)
    %    ;
    %end

    % GPD-POT
    if(GPD_POT==1)
        %DI的pot
        [threshold,DI,pot]=Step3_POT_DI(IDM,5,7,15); %一列1h数据，天数，minimum number of extremes，block period
        DI_Threshold = threshold;
        %参数估计方法
        canshugujimethod = {'ls','mom','ml','mps','pkd','pwm'};
        for CANSHUsuoyin=1:1:length(canshugujimethod)
            pot_gpd = Step3_gpd(pot,threshold,canshugujimethod{CANSHUsuoyin});
            str111 = strcat('L',mat2str(Psuoyin),'_',nianSTR,'_','GPD_POT','_',canshugujimethod{CANSHUsuoyin});
            eval([str111,'=pot_gpd;'])
            eval([str111,'.std=[std(pot),std(IDM)];'])
        end
    end

    %

end

%% 03. GPD-POT的不同参数估计方法的分析
if(GPD_POT_canshugujikeshihua==1)
    try
        Location = {'L1','L2','L3','L4','L5','L6'};
        nianSTR;
        moxingcaiyangmethod = {'GEV_IDM','GEV_AM','GEV_MM','GPD_POT','GPD_MIS'};
        canshugujimethod; %{'ls'}    {'mom'}    {'ml'}    {'mps'}    {'pkd'}    {'pwm'}
        canshugujimethod = {'ls','mom','ml','mps','pwm'};
        % rmse图；
        if(rmse_bar==1)
            vector = [];
            for i=1:1:length(Location)
                for j=1:1:length(canshugujimethod)
                    str111 = strcat('=',Location{i},'_',nianSTR,'_',moxingcaiyangmethod{4},'_',canshugujimethod{j});
                    eval(['temp13',str111]);
                    vector = [vector;temp13.rmse];
                end
            end
            matrix = reshape(vector,length(canshugujimethod),length(vector)/length(canshugujimethod));
            vector
            x = 1:1:length(vector)/length(canshugujimethod);
            figure('Name','rmse')
            bar(x,matrix,'grouped')
            legend(canshugujimethod)
        end

        % shape_VAR图
        if(shape_VAR==1)
            vector = [];
            for i=1:1:length(Location)
                for j=1:1:length(canshugujimethod)
                    str111 = strcat('=',Location{i},'_',nianSTR,'_',moxingcaiyangmethod{4},'_',canshugujimethod{j});
                    eval(['temp13',str111]);
                    vector = [vector;temp13.variance(1)];
                end
            end
            matrix = reshape(vector,length(canshugujimethod),length(vector)/length(canshugujimethod));
            x = 1:1:length(vector)/length(canshugujimethod);
            figure('Name','shape_VAR')
            bar(x,matrix,'grouped')
            legend(canshugujimethod)
        end

        % scale_VAR图
        if(scale_VAR==1)
            vector = [];
            for i=1:1:length(Location)
                for j=1:1:length(canshugujimethod)
                    str111 = strcat('=',Location{i},'_',nianSTR,'_',moxingcaiyangmethod{4},'_',canshugujimethod{j});
                    eval(['temp13',str111]);
                    vector = [vector;temp13.variance(2)];
                end
            end
            matrix = reshape(vector,length(canshugujimethod),length(vector)/length(canshugujimethod));
            x = 1:1:length(vector)/length(canshugujimethod);
            figure('Name','scale_VAR')
            bar(x,matrix,'grouped')
            legend(canshugujimethod)
        end

        % sum_VAR图
        if(sum_VAR==1)
            vector = [];
            for i=1:1:length(Location)
                for j=1:1:length(canshugujimethod)
                    str111 = strcat('=',Location{i},'_',nianSTR,'_',moxingcaiyangmethod{4},'_',canshugujimethod{j});
                    eval(['temp13',str111]);
                    vector = [vector;temp13.variance(1)+temp13.variance(2)];
                end
            end

            matrix = reshape(vector,length(canshugujimethod),length(vector)/length(canshugujimethod));
            vector
            x = 1:1:length(vector)/length(canshugujimethod);
            figure('Name','sum_VAR')
            bar(x,matrix,'grouped')
            legend(canshugujimethod)
        end
    end
end

%% 04. qqplot (包含各种方法)
if( qqplotss==1 )
    for Psuoyin=1:length(lon_selected)
        Psuoyin
        filename = strcat('Step3_Hs_P',mat2str(Psuoyin),'_',nianSTR);
        load(filename);
        % IDM
        IDM = P1(:);
        IDM = IDM(~isnan(IDM));
        % AM
        while(2)
            AM = zeros(nianshu,1);
            for i=1:1:nianshu
                temp1 = 12*(i-1)+1:1:12*(i-1)+12;
                temp2 = P1(:,temp1);
                AM(i) = nanmax(temp2(:));
            end
            break;
        end
        % MM
        while(3)
            MM = zeros(nianshu*12,1);
            for i=1:1:nianshu*12
                temp1 = P1(:,i);
                MM(i) = nanmax(temp1);
            end
            break
        end
        % POT
        while(4)
            [threshold,DI,pot]=Step3_POT_DI(IDM,5,7,15); %一列1h数据，天数，minimum number of extremes，block period
            DI_Threshold = threshold;
            break
        end
        % MIS
        while(5)
            tic
            [~,~,mis] = Step3_MIS(IDM,DI_Threshold);
            break
        end
        % QQplot3
        while(1)
            %% 句柄
            F1 = figure('NumberTitle', 'off', 'Name','1','color',[1,1,1]);
            xlima = 0; xlimb = 16;

            % IDM
            while(1)
                %
                qqplot_IDM = subplot(2,2,1);
                hold on;
                set(gca,'LineWidth',1)
                %
                phat = fitgev(IDM,'method','PWM');
                data=sort(phat.data(:));
                dist = phat.distribution;
                cphat = num2cell(phat.params,1);
                plotresq(data,dist,cphat{:});
                xlabel('')
                ylabel('')
                title('')
                LineObjects = findall(qqplot_IDM,'type','line');
                temp = LineObjects(1); delete(temp); %删除一条线
                temp_IDM = LineObjects(2); set(temp_IDM,'MarkerSize',8);
                xlim([xlima xlimb])
                ylim([xlima xlimb])
                set(gca,'Tickdir','in','Ticklength',[0.04 0.04]);
                %
                set(gca,'xtick',[0 5 10 15],'xticklabels',[{'0'};{'5'};{'10'};{'15'}],...
                    'fontname','times new roman','FontSize',14,...
                    'ytick',[5 10 15],'yticklabels',[{'5'};{'10'};{'15'}])
                %
                hold on;temp = plot([0 16],[0 16],'r:','linewidth',0.5);


                break
            end
            % BM
            while(1)
                %
                qqplot_BM = subplot(2,2,1); %需更改
                hold on;
                set(gca,'LineWidth',1)
                % AM
                while(1)
                    phat = fitgev(AM,'method','PWM'); %需更改
                    data=sort(phat.data(:));
                    dist = phat.distribution;
                    cphat = num2cell(phat.params,1);
                    plotresq(data,dist,cphat{:});
                    xlabel('')
                    ylabel('')
                    title('')
                    LineObjects = findall(qqplot_BM,'type','line'); %需更改
                    temp = LineObjects(1); delete(temp);
                    temp_AM = LineObjects(2); set(temp_AM,'MarkerSize',8);
                    xlim([xlima xlimb])
                    ylim([xlima xlimb])
                    set(gca,'Tickdir','in','Ticklength',[0.04 0.04]);


                    %
                    break
                end
                % MM
                while(1)
                    phat = fitgev(MM,'method','PWM'); %需更改
                    data=sort(phat.data(:));
                    dist = phat.distribution;
                    cphat = num2cell(phat.params,1);
                    plotresq(data,dist,cphat{:});
                    xlabel('')
                    ylabel('')
                    title('')
                    LineObjects = findall(qqplot_BM,'type','line'); %需更改
                    temp_MM = LineObjects(2); set(temp_MM,'MarkerSize',8,'color','r');
                    temp = LineObjects(1); delete(temp);
                    xlim([xlima xlimb])
                    ylim([xlima xlimb])
                    break
                end
                %
                set(gca,'xtick',[0 5 10 15],'xticklabels',[{'0'};{'5'};{'10'};{'15'}],...
                    'fontname','times new roman','FontSize',14,...
                    'ytick',[5 10 15],'yticklabels',[{'5'};{'10'};{'15'}])
                %
                hold on;temp = plot([0 16],[0 16],'r:','linewidth',0.5,'handlevisibility','off');
                %

                break
            end
            % POT
            while(1)
                %
                qqplot_POT = subplot(2,2,1); %需更改
                hold on;
                set(gca,'LineWidth',1)
                %
                while(1)
                    phat = fitgenpar(pot,'fixpar',[nan,nan,DI_Threshold],'method','PWM'); %需更改
                    data=sort(phat.data(:));
                    dist = phat.distribution;
                    cphat = num2cell(phat.params,1);
                    plotresq(data,dist,cphat{:});
                    xlabel('')
                    ylabel('')
                    title('')
                    LineObjects = findall(qqplot_POT,'type','line'); %需更改
                    temp = LineObjects(1); delete(temp);
                    temp_POT = LineObjects(2); set(temp_POT,'MarkerSize',8);
                    xlim([xlima xlimb])
                    ylim([xlima xlimb])
                    set(gca,'Tickdir','in','Ticklength',[0.04 0.04]);
                    %
                    break
                end
                %
                set(gca,'xtick',[0 5 10 15],'xticklabels',[{'0'};{'5'};{'10'};{'15'}],...
                    'fontname','times new roman','FontSize',14,...
                    'ytick',[5 10 15],'yticklabels',[{'5'};{'10'};{'15'}])
                %
                hold on;temp = plot([0 16],[0 16],'r:','linewidth',0.5);



                break
            end
            % MIS
            while(1)
                %
                qqplot_MIS = subplot(2,2,1); %需更改
                hold on;
                set(gca,'LineWidth',1)
                % Gum
                while(1)
                    phat = fitgev(mis,'fixpar',[0 nan nan],'method','ML'); %需更改
                    data=sort(phat.data(:));
                    dist = phat.distribution;
                    cphat = num2cell(phat.params,1);
                    plotresq(data,dist,cphat{:});
                    xlabel('')
                    ylabel('')
                    title('')
                    LineObjects = findall(qqplot_MIS,'type','line'); %需更改
                    temp = LineObjects(1); delete(temp);
                    temp_MISGum = LineObjects(2); set(temp_MISGum,'MarkerSize',8);
                    xlim([xlima xlimb])
                    ylim([xlima xlimb])
                    set(gca,'Tickdir','in','Ticklength',[0.04 0.04]);
                    %
                    break
                end
                % GPD
                while(1)
                    phat = fitgenpar(mis,'fixpar',[nan,nan,DI_Threshold],'method','PWM');; %需更改
                    data=sort(phat.data(:));
                    dist = phat.distribution;
                    cphat = num2cell(phat.params,1);
                    plotresq(data,dist,cphat{:});
                    xlabel('')
                    ylabel('')
                    title('')
                    LineObjects = findall(qqplot_MIS,'type','line'); %需更改
                    temp_MISGPD = LineObjects(2); set(temp_MISGPD,'MarkerSize',8,'color','r');
                    temp = LineObjects(1); delete(temp);
                    xlim([xlima xlimb])
                    ylim([xlima xlimb])
                    break
                end
                %
                set(gca,'xtick',[0 5 10 15],'xticklabels',[{'0'};{'5'};{'10'};{'15'}],...
                    'fontname','times new roman','FontSize',14,...
                    'ytick',[5 10 15],'yticklabels',[{'5'};{'10'};{'15'}])
                %
                hold on;temp = plot([0 16],[0 16],'r:','linewidth',0.5);


                break
            end
            % POT
            while(1)
                %
                qqplot_POT = subplot(2,2,1); %需更改
                hold on;
                set(gca,'LineWidth',1)
                %
                while(1)
                    phat = fitgenpar(pot,'fixpar',[nan,nan,DI_Threshold],'method','PWM'); %需更改
                    data=sort(phat.data(:));
                    dist = phat.distribution;
                    cphat = num2cell(phat.params,1);
                    plotresq(data,dist,cphat{:});
                    xlabel('')
                    ylabel('')
                    title('')
                    LineObjects = findall(qqplot_POT,'type','line'); %需更改
                    temp = LineObjects(1); delete(temp);
                    temp_POT = LineObjects(2); set(temp_POT,'MarkerSize',8);
                    xlim([xlima xlimb])
                    ylim([xlima xlimb])
                    set(gca,'Tickdir','in','Ticklength',[0.04 0.04]);
                    %
                    break
                end
                %
                set(gca,'xtick',[0 5 10 15],'xticklabels',[{'0'};{'5'};{'10'};{'15'}],...
                    'fontname','times new roman','FontSize',14,...
                    'ytick',[5 10 15],'yticklabels',[{'5'};{'10'};{'15'}])
                %
                hold on;temp = plot([0 16],[0 16],'r:','linewidth',0.5);



                break
            end
            % 坐标轴设置
            while(1)
                x = xlim();
                y = ylim();
                hold on;
                axis([x(1) x(end) y(1) y(end)]); %设置坐标轴axis取值范围
                set(gca,'Tickdir','in','Ticklength',[0.04 0.04]); %设置刻度外翻
                % ：：图形框右边和上边设置
                hold on;
                L1 = plot([x(end) x(end)],[y(1) y(end)],...
                    'color','k',...
                    'linewidth',1);hold on;
                L2 = plot([x(1) x(end)],[y(end) y(end)],...
                    'color','k',...
                    'linewidth',1);hold on;
                % ：：图形下边和左边
                L3 = plot([x(1) x(end)],[y(1) y(1)],...
                    'color','k',...
                    'linewidth',1);hold on;
                L4 = plot([x(1) x(1)],[y(1) y(end)],...
                    'color','k',...
                    'linewidth',1);hold on;
                % ：：去掉右上角刻度
                % get(gca)

                %
                break
            end
            % text:P, GEV
            while(1)
                a=get(gca);
                x=a.XLim;%获取横坐标上下限
                y=a.YLim;%获取纵坐标上下限
                k=[0.15 0.85];%给定text相对位置
                x0=x(1)+k(1)*(x(2)-x(1));%获取text横坐标
                y0=y(1)+k(2)*(y(2)-y(1));%获取text纵坐标
                temp2 = text(x0,y0,strcat('P',mat2str(Psuoyin)),'fontname','times new roman','FontSize',14,'FontWeight','bold');

                break
            end

            %% 调图
            while(1)
                qqplot_ = subplot(2,2,1);
                set(qqplot_,'position',[0.1 0.1 0.4 0.4])
                set(qqplot_,'LineWidth',1)
                %h = title( strcat('P',mat2str(Psuoyin)) )
                %set(h,'FontName','Times New Roman','FontSize',14)
                %qqplot_ = subplot(2,2,1);
                %LineObjects = findall(qqplot_MIS,'type','line');  %26条
                %temp = LineObjects(1); delete(temp);
                %temp = LineObjects(2); set(temp,'MarkerSize',8);
                %temp = LineObjects(2); set(temp,'MarkerSize',2)
                set(temp_IDM,'MarkerSize',2.5,'color',[0 0.4470 0.7410],'LineStyle','none','LineWidth',1.5,'marker','o','MarkerFaceColor',[0 0.4470 0.7410]);
                set(temp_AM,'MarkerSize',2.5,'color',[0.8500 0.3250 0.0980],'LineStyle','none','LineWidth',1.5,'marker','o','MarkerFaceColor',[0.8500 0.3250 0.0980]);
                set(temp_MM,'MarkerSize',2.5,'color',[0.9290 0.6940 0.1250],'LineStyle','none','LineWidth',1.5,'marker','o','MarkerFaceColor',[0.9290 0.6940 0.1250]);
                set(temp_POT,'MarkerSize',2.5,'color',[0.4940 0.1840 0.5560],'LineStyle','none','LineWidth',1.5,'marker','o','MarkerFaceColor',[0.4940 0.1840 0.5560]);
                set(temp_MISGum,'MarkerSize',2.5,'color',[0.4660 0.6740 0.1880],'LineStyle','none','LineWidth',1.5,'marker','none','MarkerFaceColor',[0.4660 0.6740 0.1880]);
                set(temp_MISGPD,'MarkerSize',2.5,'color',[0.3010 0.7450 0.9330],'LineStyle','none','LineWidth',1.5,'marker','o','MarkerFaceColor',[0.3010 0.7450 0.9330]);


                break
            end

            break
        end

    end
end

%% 05. returnlevel （包含各种方法）
if returnlevelss==1
    for Psuoyin=1:length(lon_selected)
        Psuoyin
        filename = strcat('Step3_Hs_P',mat2str(Psuoyin),'_',nianSTR);
        load(filename);
        figure('NumberTitle', 'off', 'Name','1','color',[1,1,1])
        ss = subplot('position',[0.1 0.1 0.3 0.3])
        set(ss,'position',[0.1 0.1 0.4 0.4])
        % IDM
        while(1)
            IDM = P1(:);
            IDM = IDM(~isnan(IDM));

            [IDM_shape,IDM_scale,IDM_location,IDM_p,IDM_rmse,IDM_102550100] = Step3_gev(IDM);
            break
        end
        % AM
        while(2)
            AM = zeros(nianshu,1);
            for i=1:1:nianshu
                temp1 = 12*(i-1)+1:1:12*(i-1)+12;
                temp2 = P1(:,temp1);
                AM(i) = nanmax(temp2(:));
            end

            [AM_shape,AM_scale,AM_location,AM_p,AM_rmse,AM_102550100] = Step3_gev(AM);
            break
        end
        % MM
        while(3)
            MM = zeros(nianshu*12,1);
            for i=1:1:nianshu*12
                temp1 = P1(:,i);
                MM(i) = nanmax(temp1);
            end
            [MM_shape,MM_scale,MM_location,MM_p,MM_rmse,MM_102550100] = Step3_gev(MM);
            break
        end
        % POT+Threshold
        while(4)
            %DI的pot
            [threshold,DI,pot]=Step3_POT_DI(IDM,5,7,15); %一列1h数据，天数，minimum number of extremes，block period
            DI_Threshold = threshold;
            %hold on;[POT_shape,POT_scale,POT_location,POT_p,POT_rmse,POT_102550100] = Step3_gpd(pot,threshold);
            hold on;gpd2 = Step3_gpd(pot,threshold,'pwm');
            break
        end
        % MISg+MISp
        while(5)
            [~,~,mis] = Step3_MIS(IDM,DI_Threshold);
            hold on;[MIS_shape,MIS_scale,MIS_location,MIS_p,MIS_rmse,MIS_102550100] = Step3_gum(mis);
            hold on;gpd2 = Step3_gpd(mis,DI_Threshold,'pwm');
            break
        end

        % title,label
        while(1)
            %h = legend('IDM','AM','MM','POT','MISg','MISp','Location','NorthWest');
            %https://blog.csdn.net/ma123rui/article/details/100590766
            %set(h,'FontName','Times New Roman','FontSize',4,'FontWeight','normal')
            h = title( strcat('P',mat2str(Psuoyin)) )
            set(h,'FontName','Times New Roman','FontSize',14)
            %xlabel('return period','fontname','Times New Roman','FontSize',14)
            %ylabel('return level','fontname','Times New Roman','FontSize',14)
            set(ss,'fontname','Times New Roman','FontSize',14)
            set(ss,'xtick',[0 50 100 150 200],'xticklabel',[{'0'};{'50'};{'100'};{'150'};{'200'}],...
                'ytick',[5 10],'yticklabel',[{'5'};{'10'}])
            break
        end
        % HSmax
        while(8)
            Hs_Max = max(IDM);
            Hs_Max = hline(Hs_Max,'--');
            break
        end
        % 坐标轴设置
        while(1)
            x = xlim();
            y = ylim();
            hold on;
            axis([x(1) x(end) y(1) y(end)]); %设置坐标轴axis取值范围
            set(gca,'Tickdir','in','Ticklength',[0.04 0.04]); %设置刻度外翻
            % ：：图形框右边和上边设置
            hold on;
            plot([x(end) x(end)],[y(1) y(end)],...
                'color','k',...
                'linewidth',1,'handlevisibility','off');hold on;
            plot([x(1) x(end)],[y(end) y(end)],...
                'color','k',...
                'linewidth',1,'handlevisibility','off');hold on;
            % ：：图形下边和左边
            plot([x(1) x(end)],[y(1) y(1)],...
                'color','k',...
                'linewidth',1,'handlevisibility','off');hold on;
            plot([x(1) x(1)],[y(1) y(end)],...
                'color','k',...
                'linewidth',1,'handlevisibility','off');hold on;
            % ：：去掉右上角刻度
            % get(gca)

            %
            break
        end
        % 调图
        while(1)
            %qqplot_ = subplot(2,2,1);
            %set(qqplot_,'position',[0.1 0.1 0.4 0.4])
            %h = title( strcat('P',mat2str(Psuoyin)) )
            %set(h,'FontName','Times New Roman','FontSize',14)
            %qqplot_ = subplot(2,2,1);
            
            %LineObjects = findall(ss,'type','line');  %11条
            %temp_MISGPD = LineObjects(6);
            %temp_MISGum = LineObjects(7);
            %temp_POT = LineObjects(8);
            %temp_MM = LineObjects(9);
            %temp_AM = LineObjects(10);
            %temp_IDM = LineObjects(11);

            %set(gca,'Tickdir','in','Ticklength',[0.03 0.03]);
            %set(Hs_Max,'LineStyle','--','color','r')
            %set(temp_IDM,'MarkerSize',2.5,'color',[0 0.4470 0.7410],'LineStyle','-','LineWidth',1.5,'marker','none','MarkerFaceColor',[0 0.4470 0.7410]);
            %set(temp_AM,'MarkerSize',2.5,'color',[0.8500 0.3250 0.0980],'LineStyle','-','LineWidth',1.5,'marker','none','MarkerFaceColor',[0.8500 0.3250 0.0980]);
            %set(temp_MM,'MarkerSize',2.5,'color',[0.9290 0.6940 0.1250],'LineStyle','-','LineWidth',1.5,'marker','none','MarkerFaceColor',[0.9290 0.6940 0.1250]);
            %set(temp_POT,'MarkerSize',2.5,'color',[0.4940 0.1840 0.5560],'LineStyle','-','LineWidth',1.5,'marker','none','MarkerFaceColor',[0.4940 0.1840 0.5560]);
            %set(temp_MISGum,'MarkerSize',2.5,'color',[0.4660 0.6740 0.1880],'LineStyle','none','LineWidth',1.5,'marker','none','MarkerFaceColor',[0.4660 0.6740 0.1880]);
            %set(temp_MISGPD,'MarkerSize',2.5,'color',[0.3010 0.7450 0.9330],'LineStyle','-','LineWidth',1.5,'marker','none','MarkerFaceColor',[0.3010 0.7450 0.9330]);

            break
        end

        %
    end
end

%% 06. sensitivity of threshold  (仅使用GPD-POT)
if SensitivityOfThreshold==1

    for Psuoyin=1:1:length(lon_selected)
        Psuoyin
        filename = strcat('Step3_Hs_P',mat2str(Psuoyin),'_',nianSTR);
        load(filename);
        figure('NumberTitle', 'off', 'Name','1','color',[1,1,1])
        ss = subplot('position',[0.1 0.1 0.3 0.3])
        set(ss,'position',[0.1 0.1 0.4 0.4])
        IDM = P1(:);
        IDM = IDM(~isnan(IDM));
        % POT+Threshold+kesei
        x = -0.1:0.04:0.1;
        temp = [];
        for(kesei1=-0.1:0.04:0.1)
            kesei1
            %DI的pot
            [threshold,DI,pot]=Step3_POT_DI_SensitOfThres(IDM,5,7,15,kesei1); %一列1h数据，天数，minimum number of extremes，block period
            DI_Threshold = threshold;
            %hold on;[POT_shape,POT_scale,POT_location,POT_p,POT_rmse,POT_102550100] = Step3_gpd(pot,threshold);
            hold on;gpd2 = Step3_gpd(pot,threshold,'pwm');
            temp = [temp gpd2.ReturnLevel(4)];
        end
        %temp1 = [-1:0.5:1;temp];
        %temp2 = [-1:0.1:1;temp];plot(temp2(1,:),temp2(2,:))
        %temp3 = [-0.1:0.01:0.1;temp]; %P1
        %temp4 = [-0.1:0.01:0.1;temp]; %P2
        figure('NumberTitle', 'off', 'Name','1','color',[1,1,1])
        ss = subplot('position',[0.1 0.1 0.3 0.3]);
        set(ss,'position',[0.1 0.1 0.4 0.4]);
        plot(x,temp);
        % title,label,tick
        while(1)
            %h = legend('IDM','AM','MM','POT','MISg','MISp','Location','NorthWest');
            %https://blog.csdn.net/ma123rui/article/details/100590766
            %set(h,'FontName','Times New Roman','FontSize',4,'FontWeight','normal')
            h = title( strcat('P',mat2str(Psuoyin)) )
            set(h,'FontName','Times New Roman','FontSize',14)
            %xlabel('δ','fontname','Times New Roman','FontSize',14)
            %ylabel('100-year return level','fontname','Times New Roman','FontSize',14)
            strrr = strcat('P',mat2str(Psuoyin));
            title(strrr,'fontname','Times New Roman','FontSize',14)
            ylim([0 15])
            set(gca,'ytick',[5 10 15],'fontname','Times New Roman','FontSize',14)
            break
        end
        % 坐标轴设置
        while(1)
            x = xlim();
            y = ylim();
            hold on;
            axis([x(1) x(end) y(1) y(end)]); %设置坐标轴axis取值范围
            set(gca,'Tickdir','in','Ticklength',[0.04 0.04]); %设置刻度外翻
            % ：：图形框右边和上边设置
            hold on;
            L1 = plot([x(end) x(end)],[y(1) y(end)],...
                'color','k',...
                'linewidth',1);hold on;
            L2 = plot([x(1) x(end)],[y(end) y(end)],...
                'color','k',...
                'linewidth',1);hold on;
            % ：：图形下边和左边
            L3 = plot([x(1) x(end)],[y(1) y(1)],...
                'color','k',...
                'linewidth',1);hold on;
            L4 = plot([x(1) x(1)],[y(1) y(end)],...
                'color','k',...
                'linewidth',1);hold on;
            % ：：去掉右上角刻度
            % get(gca)

            %
            break
        end
    end

end

%% 07. sensitivity of minimum time span   (仅使用GPD-POT)
if SensitivityOfMTS==1
    for Psuoyin=1:1:length(lon_selected)
        Psuoyin
        filename = strcat('Step3_Hs_P',mat2str(Psuoyin),'_',nianSTR);
        load(filename);
        figure('NumberTitle', 'off', 'Name','1','color',[1,1,1])
        ss = subplot('position',[0.1 0.1 0.3 0.3])
        set(ss,'position',[0.1 0.1 0.4 0.4])
        IDM = P1(:);
        IDM = IDM(~isnan(IDM));
        % POT+Threshold+kesei
        x = 100:10:140;
        temp = [];
        for(kesei1=100:10:140)
            kesei1
            %DI的pot
            [threshold,DI,pot]=Step3_POT_DI_SensitOfMTS(IDM,5,7,15,kesei1); %一列1h数据，天数，minimum number of extremes，block period
            DI_Threshold = threshold;
            %hold on;[POT_shape,POT_scale,POT_location,POT_p,POT_rmse,POT_102550100] = Step3_gpd(pot,threshold);
            hold on;gpd2 = Step3_gpd(pot,threshold,'pwm');
            temp = [temp gpd2.ReturnLevel(4)];
        end
        %temp = [x;temp];
        %temp11 = [x;temp]; %P1
        figure('NumberTitle', 'off', 'Name','1','color',[1,1,1])
        ss = subplot('position',[0.1 0.1 0.3 0.3]);
        set(ss,'position',[0.1 0.1 0.4 0.4]);
        plot(x,temp);
        % title,label
        while(1)
            %h = legend('IDM','AM','MM','POT','MISg','MISp','Location','NorthWest');
            %https://blog.csdn.net/ma123rui/article/details/100590766
            %set(h,'FontName','Times New Roman','FontSize',4,'FontWeight','normal')
            h = title( strcat('P',mat2str(Psuoyin)) )
            set(h,'FontName','Times New Roman','FontSize',14)
            %xlabel('minimum time span (hour)','fontname','Times New Roman','FontSize',14)
            %ylabel('100-year return level','fontname','Times New Roman','FontSize',14)
            ylim([0 15])
            set(gca,'ytick',[5 10 15],'fontname','Times New Roman','FontSize',14)
            break
        end
        % 坐标轴设置
        while(1)
            x = xlim();
            y = ylim();
            hold on;
            axis([x(1) x(end) y(1) y(end)]); %设置坐标轴axis取值范围
            set(gca,'Tickdir','in','Ticklength',[0.04 0.04]); %设置刻度外翻
            % ：：图形框右边和上边设置
            hold on;
            L1 = plot([x(end) x(end)],[y(1) y(end)],...
                'color','k',...
                'linewidth',1);hold on;
            L2 = plot([x(1) x(end)],[y(end) y(end)],...
                'color','k',...
                'linewidth',1);hold on;
            % ：：图形下边和左边
            L3 = plot([x(1) x(end)],[y(1) y(1)],...
                'color','k',...
                'linewidth',1);hold on;
            L4 = plot([x(1) x(1)],[y(1) y(end)],...
                'color','k',...
                'linewidth',1);hold on;
            % ：：去掉右上角刻度
            % get(gca)

            %
            break
        end

    end

end
%%
ylabel('100-year return level (m)','fontname','Times New Roman','FontSize',14,'fontweight','bold')
title("Minimum time span (hour)",'fontname','Times New Roman','FontSize',14,'fontweight','bold');

%% 08. shape 方差
if shapeVar == 1
    canshugujimethod = {'ls','mom','ml','mps','pwm'};
    nianduan = {'1950_1957'};
    MMMM = []; kkk=1;
    for canshugujimethodS = 1:length(canshugujimethod)
        for Psuoyin=1:6
            for nianduanS = 1:length(nianduan)
                str11s = strcat('L',mat2str(Psuoyin),'_',nianduan{nianduanS},'_GPD_POT_',canshugujimethod{canshugujimethodS})
                %eval(['MMMM(kkk,nianduanS)=',str11s,'.variance(1);']);
                eval(['MMMM(kkk,nianduanS)=',str11s,'.variance(1)+',str11s,'.variance(2);']);

            end
            kkk = kkk+1;

        end
    end
    MMMM;
    % 表格形式输出（可复制到Excel）

    for i=1:1:length(MMMM)
        for j=1:1:6
            fprintf('%4.3s\t',MMMM(i,j));
        end
        fprintf('\n');
    end


end

%% save
save(work_table_name);

%% 00. 调用的自定义函数
function [threshold,di,pot]=Step3_POT_DI(xn2,Tmin,Nmin,Tb)
%xn2 = IDM; % Hs
%Tmin = 5; % minimum distance between extremes %5days; no;
%Nmin = 7; % minimum number of extremes
%Tb = 15; % block period
Tmin = Tmin*24; %necessary
tc2 = dat2tc(xn2); %从数据中提取波峰和波谷
umin = median(tc2(:,2)); % 中值峰
Ie0 = findpot(tc2, 0.9*umin, Tmin); %索引
Ev = sort(tc2(Ie0,2));

Ne = numel(Ev); %数据个数
if Ne>Nmin && Ev(Ne-Nmin)>umin
    umax = Ev(Ne-Nmin);
else
    umax = umin;
end
Nu = floor((umax-umin)/0.025)+1;
u = linspace(umin,umax,Nu);

size(tc2(Ie0,:));
[di, threshold, ok_u] = disprsnidx(tc2(Ie0,:),'Tb', Tb ,'alpha',0.05, 'u',u); %Dispersion Index vs threshold
% plot(di)

pot = findpot(tc2, threshold, Tmin);
pot = tc2(pot,2);


end

function [gpd2] = Step3_gpd(Hs,thredhold,canshugujimethod)
%{
%% 参数估计
% Hs=DI_pot;
gpd1 = fitgenpar(Hs,'method','PWM');
shape = gpd1.params(1);
scale = gpd1.params(2);
location = gpd1.params(3);

%% p值
p = gpd1.pvalue;

%% rmse
model = 'genpar';
n = length(Hs);
eprob = ((1:n)-0.5)/n;

cphat = {gpd1.params(1),gpd1.params(2),gpd1.params(3)};
Hs_guji1 = feval(['inv' model],eprob,cphat{:})'; %??????????????????
HsSort = sort(Hs); %由小到大
gpd1_rmse = sqrt(mean((Hs_guji1-HsSort).^2));

%% return level
T = logspace(0.1,2,100); %重现期范围
%Hs_invgpd1 = invgenpar(1./T,phat,'lowertail',false,'proflog',false); %invgev 是求gev函数的逆函数，逆函数的函数值为Hs；
Hs_invgpd1 = invgenpar(1./T,gpd1,'lowertail',false,'proflog',false); %invgev 是求gev函数的逆函数，逆函数的函数值为Hs；
semilogx(T,Hs_invgpd1), hold on
% N=1:length(Hs); Nmax=max(N);
% plot(Nmax./N,sort(Hs,'descend'),'.'), hold on
%}
%
gpd2 = struct();

%
%% 参数估计
gpd1 = fitgenpar(Hs,'fixpar',[nan,nan,thredhold],'method',canshugujimethod);
shape = gpd1.params(1); gpd2.shape_scale_location = [gpd1.params(1) gpd1.params(2) gpd1.params(3)];
scale = gpd1.params(2);
location = gpd1.params(3);


%% rmse
model = 'genpar';
n = length(Hs);
eprob = ((1:n)-0.5)/n;
cphat = {gpd1.params(1),gpd1.params(2),gpd1.params(3)};
Hs_guji1 = feval(['inv' model],eprob,cphat{:})'; %??????????????????
HsSort = sort(Hs); %由小到大
gpd1_rmse = sqrt(mean((Hs_guji1-HsSort).^2));  gpd2.rmse = gpd1_rmse;

%% return level
T = logspace(0.1,2.3,100); %重现期范围
Hs_invgpd1 = invgenpar(1./T,gpd1,'lowertail',false,'proflog',false); %invgev 是求gev函数的逆函数，逆函数的函数值为Hs；
% semilogx(T,Hs_invgpd1), hold on
% plot(T,Hs_invgpd1,'Linewidth',1),hold on %画图

% N=1:length(Hs); Nmax=max(N);
% plot(Nmax./N,sort(Hs,'descend'),'.'), hold on
%
%% 10 25 50 100 200
T = [10 25 50 100 200];
Hs_invgpd1 = invgenpar(1./T,gpd1,'lowertail',false,'proflog',false);

gpd2.ReturnPeriods = T;
gpd2.ReturnLevel = Hs_invgpd1;

%% 其它
gpd2.upperbound = gpd1.upperbound;
gpd2.lowerbound = gpd1.lowerbound;
gpd2.variance = gpd1.variance;
gpd2.loglikemax = gpd1.loglikemax;
gpd2.logpsmax = gpd1.logpsmax;
end

