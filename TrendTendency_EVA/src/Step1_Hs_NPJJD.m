
% tic
wildcards1 % = 1958:1:2020
programGo %='work_ERA5_nanhai_3Y'
lon_nodeNum %=121
lat_nodeNum %=121
LatDeg %=0.125
LatMin %= 9;
LatMax %= 24;
LonDeg %=0.125
LonMin %= 105;
LonMax %= 120;

wildcards2 = {'01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12'};
NPJJD = zeros(lon_nodeNum,lat_nodeNum,length(wildcards1)); %结点年平�????
for i=1:1:length(wildcards1)
    i
    nian = cell(lon_nodeNum,lat_nodeNum);
    for j=1:1:length(wildcards2)
        %% YearAnaMonth
        YearAnaMonth = strcat(num2str(wildcards1(i)),wildcards2(j));
        YearAnaMonth = cell2mat(YearAnaMonth);
        %
        %% filename
        filename = strcat('../nc/ERA5_',YearAnaMonth,'.nc');
        %% Step1_Hs
        M = ncread(filename,'swh');
        [M1 M2 M3] = size(M);
        % M(1,1,:);
        for k=1:1:M1
            for kk=1:1:M2
                temp1 = nian{k,kk};
                temp2 = M(k,kk,:);
                [~,~,temp0] = size(temp2);
                temp2 = reshape(temp2,temp0,1); %temp2必须reshape�????1×1×*不可
     
                nian{k,kk} = [temp1;temp2]; %cell必须使用{}；结点对应；
            end
        end
        
        %% eval
        %str = strcat('NanHai_Hs_',YearAnaMonth);
        %eval([str '=M;']);
        %% save
        %save(str,str);
        %% clear
        %eval(['clear ' str]);
    end
    %
    for k=1:1:M1
        for kk=1:1:M2
            nian{k,kk} = nanmean(nian{k,kk});
            NPJJD(k,kk,i) = nian{k,kk}; %结点对应
        end
    end
    
end

% 保存NPJJD数据
str=strcat('../',programGo);
cd(str)
save('Step1_Hs_NPJJD.mat')




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 趋势分析
str=strcat('../src');
cd(str)

xielvAll = zeros(lon_nodeNum,lat_nodeNum);
CL_All = zeros(lon_nodeNum,lat_nodeNum);
for k=1:1:lon_nodeNum
    for kk=1:1:lat_nodeNum
        kk
        x = wildcards1;
        [~,~,temp] = size(NPJJD(k,kk,:));
        y = reshape(NPJJD(k,kk,:),1,temp);
        if(isnan(y(1)))
            xielvAll(k,kk) = nan;
            CL_All(k,kk) = nan;
        else
            %% Thei-Sen and MannKendall
            alpha = 0.05;
            [k2] = Trend_TheiSenNiHe(x,y,alpha);
            [CL,~] = Trend_MannKendallTest(x,y); %置信水平
            
            %%
            xielvAll(k,kk) = k2;
            CL_All(k,kk) = CL;
        end

    end
end
%save('Step1_Hs_NPJJD.mat')
% 保存NPJJD数据
str=strcat('../',programGo);
cd(str)
save('Step1_Hs_NPJJD.mat')


%%
str=strcat('../src');
cd(str)

xielvAll2 = zeros(lon_nodeNum,lat_nodeNum);
for k=1:1:lon_nodeNum
    for kk=1:1:lat_nodeNum
        kk
        x = wildcards1;
        [~,~,temp] = size(NPJJD(k,kk,:));
        y = reshape(NPJJD(k,kk,:),1,temp);
        if(isnan(y(1)))
            xielvAll2(k,kk) = nan;
        else
            %% �????佳线拟合
            [k2,~] = Trend_ZuiJiaXianNiHe(x,y);
            
            %%
            xielvAll2(k,kk) = k2;
        end

    end
end
% 保存NPJJD数据
str=strcat('../',programGo);
cd(str)
save('Step1_Hs_NPJJD.mat')

%}


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 可视化
%% xielv contour ：Thei-Sen
str=strcat('../',programGo);
cd(str)
load('Step1_Hs_NPJJD.mat')
path(path,'../m_map');
temp5 = figure('NumberTitle', 'off', 'Name', '1','color',[1,1,1]);
temp2 = subplot('position',[0.1 0.1 0.3 0.3])
set(temp2,'position',[0.04 0.2 0.45 0.45])
%set(temp2,'position',[0.2 0.2 0.45 0.45])
while(1)
    tic
    % m_proj
    while(1)
        % LatMin = 9;
        % LatMax = 24;
        % LonMin = 105;
        % LonMax = 120;
        m_proj('Mercator','long',[LonMin LonMax],... %121.1667
            'lat',[LatMin LatMax])
        break
    end
    %
    %
    %
    jingdu = LonMin:LonDeg:LonMax;
    weidu = LatMax:-LatDeg:LatMin; %纬度为什么是这样？为了结点对�????
    jingdu2 = zeros(1,length(jingdu));
    for i=1:1:length(jingdu)
        [jingdu2(i),~] = m_ll2xy(jingdu(i),weidu(1));
    end
    weidu2 = zeros(1,length(weidu));
    for i=1:1:length(weidu)
        [~,weidu2(i)] = m_ll2xy(jingdu(1),weidu(i));
    end
    [X,Y] = meshgrid(jingdu2,weidu2); %结点对应（横坐标经度！！lon*lat�????
    %
    hold on
    max(max(xielvAll)) %0.0032  %%需更改
    min(min(xielvAll)) %-0.0012  %%需更改
    %
    %Z= fillmissing(zi,'nearest');
    xielvAll = fillmissing(xielvAll,'nearest');
    contourf(X,Y,xielvAll',10,'LineStyle','none');
    % grid
    while(1)
        %m_usercoast('Step0_NanHaiMmap.mat','patch',[0.7 0.7 0.7]); %路径  大陆颜色
        m_gshhs_i('patch',[.7 .7 .7]);

        %m_grid('tickdir','in','tickstyle','dm','xtick',[105 111 117],...
        %    'xticklabels',['105';'111';'117'],'ytick',[12 18 24],...
        %    'yticklabels',['12';'18';'24'],'fontname','times new roman','FontSize',14,...
        %    'linestyle','none');
        m_grid('tickdir','in','tickstyle','dm','xtick',[],...
            'ytick',[],...
            'fontname','times new roman','FontSize',14,...
            'linestyle','none');

        %         xlabel('Longitude(°E)','fontsize',14,'fontname','Times New Roman')
        ylabel('Latitude(°N)','fontsize',14,'fontname','Times New Roman')
        break
    end
    
    %colormap
    colormap('Jet')
    h = colorbar();
    %caxis([[-0.0011 0.003]])
    %set(h,'ticks',[-0.001 0 0.001 0.002 0.003],'ticklabels',[{'-1'};{'0'};{'1'};{'2'};{'3'}],...
        % 'LineWidth',1,...
        % 'fontname','times new roman','FontSize',14,...
        % 'TickLabelInterpreter','tex',...
        % 'visible','off')
    
    % text(0.4271,0.18,'×10^3','fontname','times new roman','FontSize',14)
    
    %
    title('Theil-Sen','fontsize',14,'fontname','Times New Roman')
    ylabel('Latitude(°N)','fontname','times new roman','FontSize',14)
    toc
    break
end

%
tic
%% xielv contour :�????佳线拟合
temp3 = subplot('position',[0.6 0.1 0.3 0.3])
set(temp3,'position',[0.45 0.2 0.45 0.45])
while(1)
    path(path,'../m_map');
    % m_proj
    while(1)
        % LatMin = 9;
        % LatMax = 24;
        % LonMin = 105;
        % LonMax = 120;

        % m_proj('miller','long',[LonMin LonMax],... %121.1667
        %     'lat',[LatMin LatMax],...
        %     'clo',119.3750,... %子午�????
        %     'rec','on');% 正方�????

        m_proj('Mercator','long',[LonMin LonMax],... %121.1667
            'lat',[LatMin LatMax])
        break
    end
    %
    %
    jingdu = LonMin:LonDeg:LonMax;
    weidu = LatMax:-LatDeg:LatMin; %纬度为什么是这样？为了结点对�????
    jingdu2 = zeros(1,length(jingdu));
    for i=1:1:length(jingdu)
        [jingdu2(i),~] = m_ll2xy(jingdu(i),weidu(1));
    end
    weidu2 = zeros(1,length(weidu));
    for i=1:1:length(weidu)
        [~,weidu2(i)] = m_ll2xy(jingdu(1),weidu(i));
    end
    [X,Y] = meshgrid(jingdu2,weidu2); %结点对应（横坐标经度！！lon*lat�????
    %
    hold on
    %
    xielvAll2 = fillmissing(xielvAll2,'nearest');
    contourf(X,Y,xielvAll2',10,'LineStyle','none');
    %grid
    while(1)
        % m_usercoast('Step0_NanHaiMmap.mat','patch',[0.7 0.7 0.7]); %路径  大陆颜色
        m_gshhs_i('patch',[.7 .7 .7]);

        % m_grid('tickdir','in','tickstyle','dm','xtick',[],...
        %     'xticklabels',['105';'111';'117'],'ytick',[],...
        %     'yticklabels',['12';'18';'24'],'fontname','times new roman','FontSize',14,...
        %     'linestyle','none');

        m_grid('tickdir','in','tickstyle','dm','xtick',[],...
            'ytick',[],...
            'fontname','times new roman','FontSize',14,...
            'linestyle','none');


        %         xlabel('Longitude(°E)','fontsize',14,'fontname','Times New Roman')
        %         ylabel('Latitude(°N)','fontsize',14,'fontname','Times New Roman')
        break
    end
    
    %colormap
    colormap('Jet')
    h = colorbar()
    % caxis([[-0.0011 0.003]])
    % set(h,'ticks',[-0.001 0 0.001 0.002 0.003],'ticklabels',[{'-1'};{'0'};{'1'};{'2'};{'3'}],...
    %     'LineWidth',1,...
    %     'fontname','times new roman','FontSize',14,...
    %     'TickLabelInterpreter','tex',...
    %     'visible','on')

    h_label = get(h,'label');
    set(h_label,'string','Trends (m/year)','fontname','times new roman','FontSize',14)
    % figure(1)
    % text
    while(1)
        a=get(gca);
        x=a.XLim;%获取横坐标上下限
        y=a.YLim;%获取纵坐标上下限
        k=[1.04 1.05];%给定text相对位置
        x0=x(1)+k(1)*(x(2)-x(1));%获取text横坐标
        y0=y(1)+k(2)*(y(2)-y(1));%获取text纵坐标
        temp1 = text(x0,y0,'×10^{-3}','fontname','times new roman','FontSize',14);
        set(temp1,'position',[0.148 0.46 0])
        break
    end
    %
    title('The Line of Best Fit','fontsize',14,'fontname','Times New Roman')
    
    toc
    break
end

%%
temp6 = annotation('textbox',[0.4,0.01,0.2,0.1],...,
    'LineStyle','none',...
    'fontname','times new roman','FontSize',14,...
    'String','Longitude(°E)');
set(temp6,'position',[0.37,0.05,0.2,0.1])


% 保存fig
str=strcat('../',programGo);
cd(str)
savefig(temp5,strcat('step1__Hs_NPJJD_LR_TS','.fig'));
%}














%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%% MK
load('Step1_Hs_NPJJD.mat')
figure('NumberTitle', 'off', 'Name', '2','color',[1,1,1]);
temp1 = subplot('position',[0.2 0.2 0.5 0.5]);
set(temp1,'position',[0.2 0.2 0.6 0.6])
while(1)
    % 斜率为负时的CL
    CL_All2 = zeros(lon_nodeNum,lat_nodeNum);
    for i=1:1:lon_nodeNum
        for j=1:1:lat_nodeNum
            if(xielvAll(i,j)<0)
                CL_All2(i,j) = -CL_All(i,j);
            else
                CL_All2(i,j) = CL_All(i,j);
            end
        end
    end
    %
    path(path,'../m_map');
    
    % m_proj
    while(1)
        % LatMin = 9;
        % LatMax = 24;
        % LonMin = 105;
        % LonMax = 120;

        % m_proj('miller','long',[LonMin LonMax],... %121.1667
        %     'lat',[LatMin LatMax],...
        %     'clo',119.3750,... %子午�????
        %     'rec','on');% 正方�????

        m_proj('Mercator','long',[LonMin LonMax],... %121.1667
        'lat',[LatMin LatMax])

        break
    end
    %
    % 
    jingdu = LonMin:LonDeg:LonMax;
    weidu = LatMax:-LatDeg:LatMin; %纬度为什么是这样？为了结点对�????
    jingdu2 = zeros(1,length(jingdu));
    for i=1:1:length(jingdu)
        [jingdu2(i),~] = m_ll2xy(jingdu(i),weidu(1));
    end
    weidu2 = zeros(1,length(weidu));
    for i=1:1:length(weidu)
        [~,weidu2(i)] = m_ll2xy(jingdu(1),weidu(i));
    end
    [X,Y] = meshgrid(jingdu2,weidu2); %结点对应（横坐标经度！！lon*lat�????
    %
    % colormap
    while(1)
        v = [-1 -0.95 -0.9 -0.75 0.75 0.9 0.95 0.99 1]; %为什么没�?-0.99的颜色，�?要对-1~-0.99进行颜色选取，�?�不了�??
        CL_All2 = fillmissing(CL_All2,'nearest');
        hold on;[c,h] = contourf(X,Y,CL_All2',v)%'linestyle','none');
        % clabel(c,h,'FontSize',9);
        
        % colormap
        load('mycmap.mat');
        colormap(mycmap);
        break
    end
        
    % grid
    while(1)
        m_usercoast('Step0_NanHaiMmap.mat','patch',[0.7 0.7 0.7]); %路径  大陆颜色
        m_grid('tickdir','in','tickstyle','dm','xtick',[105 111 117],...
            'xticklabels',['105';'111';'117'],'ytick',[12 18 24],...
            'yticklabels',['12';'18';'24'],'fontname','times new roman','FontSize',14,...
            'linestyle','none');
        xlabel('Longitude(°E)','fontsize',14,'fontname','Times New Roman')
        ylabel('Latitude(°N)','fontsize',14,'fontname','Times New Roman')
        break
    end
    
    break
end
%{
figure(1)
colormap
colormapeditor
ax = gca %https://blog.csdn.net/qq_29007291/article/details/78215819
% mycmap = get(gcf,'colormap')
mycmap = colormap(ax)
save('mycmap','mycmap')
%}

%}



