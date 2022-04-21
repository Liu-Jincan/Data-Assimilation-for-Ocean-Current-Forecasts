%%%%ª≠Õº
clc,clear all

%% ≤Œ ˝
while(1)
    lon1=100;
    lon2=125;
    lat1=0;
    lat2=30;
    
    point_lon=[108 116 119 114 116 110]';
    point_lat=[20 21 20 17 11 14]';
    % point_name=['P1', 'P2', 'P3', 'P4', 'P5'];
    point_name={'P1', 'P2', 'P3', 'P4', 'P5', 'P6'};
    buoy_name={'1','2','3','4','5','6','7','8','9'};
    break
end

%% æ‰±˙
while(1)
    F1 = figure(1);
    path(path,'m_map');
    m_proj('Mercator','lon',[lon1 lon2],'lat',[lat1 lat2]);%%æÿ–Œ
    %
    [CS,CH]=m_etopo2('contourf',[-6000:200:0],'edgecolor','none');
    [ax,h]=m_contfbar(0.9,[0.2,0.8],CS,CH,'endpiece','no','axfrac',.05,'edgecolor','none',...
        'fontname','times new roman','fontsize',14);
    
    hold on
    for ii=1:5
        m_plot(point_lon(ii),point_lat(ii),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','markersize',5.2);
        hold on
        % m_text(point_lon(ii)-0.3,point_lat(ii)-0.6,point_name(2*(ii-1)+1:2*(ii-1)+2),'fontsize',12)
        point_name{ii};
        m_text(point_lon(ii)-0.7,point_lat(ii)-0.9,point_name{ii},'fontname','times new roman','FontSize',9);
        hold on
    end
    
    m_plot(point_lon(6),point_lat(6),'ro','MarkerEdgeColor','r','MarkerFaceColor','r','markersize',5.2);
    hold on
    point_name{6};
    m_text(point_lon(6)-0.5,point_lat(6)-0.9,point_name{6},'fontname','times new roman','FontSize',9);
    hold on
    
    %m_coast('patch',[.6 .6 .7]);
    % m_gshhs_c('patch',[.7 .7 .7]);
    %m_gshhs_l('patch',[.5 .5 .5]);
    m_gshhs_i('patch',[.7 .7 .7]);
    %m_gshhs_f('patch',[.7 .7 .7]); %full
    
    m_grid('box','fancy','tickdir','in','tickstyle','dm','xtick',[100 105 110 115 120 125 130 135],...
        'xticklabels',['100';'105';'110';'115';'120';'125';'130';'135';],'ytick',[5 10 15 20 25 30 35 40],...
        'yticklabels',['5 '; '10';'15';'20';'25';'30';'35';'40'],'fontname','times new roman','FontSize',14,...
        'linestyle','none');
    XL1 = xlabel('Longitude(°„E)','fontsize',14,'fontname','Times New Roman');
    YL1 = ylabel('Latitude(°„N)','fontsize',14,'fontname','Times New Roman');
    %
    A=[105 105 120 120 105;9 25 25 9 9];
    m_plot(A(1,:),A(2,:),'r-','linewidth',2);
    
    %
    point_lon=[118.2  116.17 117.34 119 111.53 111.83  111 117.29 109.17]';
    point_lat=[23.63 22.15  22.33  22.6 20.73 19.35 18.51 20.99 20.5]';
    hold on
    try
        m_plot(point_lon(1),point_lat(1),'s','MarkerEdgeColor','k','MarkerFaceColor','k','markersize',4);hold on %”““∆--º”°£œ¬“∆--ºı°£
        m_text(point_lon(1)+0.4,point_lat(1)+0.1,buoy_name{1},'fontname','times new roman','FontSize',8);hold on %◊Û“∆--ºı°£…œ“∆--º”°£

        m_plot(point_lon(2),point_lat(2),'s','MarkerEdgeColor','k','MarkerFaceColor','k','markersize',4);hold on %”““∆--º”°£œ¬“∆--ºı°£
        m_text(point_lon(2)-0.8,point_lat(2)+0.1,buoy_name{2},'fontname','times new roman','FontSize',8);hold on %◊Û“∆--ºı°£…œ“∆--º”°£
        
        m_plot(point_lon(3),point_lat(3),'s','MarkerEdgeColor','k','MarkerFaceColor','k','markersize',4);hold on %”““∆--º”°£œ¬“∆--ºı°£
        m_text(point_lon(3)+0.4,point_lat(3)+0.1,buoy_name{3},'fontname','times new roman','FontSize',8);hold on %◊Û“∆--ºı°£…œ“∆--º”°£
        
        m_plot(point_lon(4),point_lat(4),'s','MarkerEdgeColor','k','MarkerFaceColor','k','markersize',4);hold on %”““∆--º”°£œ¬“∆--ºı°£
        m_text(point_lon(4)+0.4,point_lat(4)+0.1,buoy_name{4},'fontname','times new roman','FontSize',8);hold on %◊Û“∆--ºı°£…œ“∆--º”°£
        
        m_plot(point_lon(5),point_lat(5),'s','MarkerEdgeColor','k','MarkerFaceColor','k','markersize',4);hold on %”““∆--º”°£œ¬“∆--ºı°£
        m_text(point_lon(5)+0.4,point_lat(5)+0.1,buoy_name{5},'fontname','times new roman','FontSize',8);hold on %◊Û“∆--ºı°£…œ“∆--º”°£
        
        m_plot(point_lon(6),point_lat(6),'s','MarkerEdgeColor','k','MarkerFaceColor','k','markersize',4);hold on %”““∆--º”°£œ¬“∆--ºı°£
        m_text(point_lon(6)+0.4,point_lat(6)+0.1,buoy_name{6},'fontname','times new roman','FontSize',8);hold on %◊Û“∆--ºı°£…œ“∆--º”°£
        
        m_plot(point_lon(7),point_lat(7),'s','MarkerEdgeColor','k','MarkerFaceColor','k','markersize',4);hold on %”““∆--º”°£œ¬“∆--ºı°£
        m_text(point_lon(7)+0.4,point_lat(7)+0.1,buoy_name{7},'fontname','times new roman','FontSize',8);hold on %◊Û“∆--ºı°£…œ“∆--º”°£
        
        m_plot(point_lon(8),point_lat(8),'s','MarkerEdgeColor','k','MarkerFaceColor','k','markersize',4);hold on %”““∆--º”°£œ¬“∆--ºı°£
        m_text(point_lon(8)+0.4,point_lat(8)+0.1,buoy_name{8},'fontname','times new roman','FontSize',8);hold on %◊Û“∆--ºı°£…œ“∆--º”°£
        
        m_plot(point_lon(9),point_lat(9),'s','MarkerEdgeColor','k','MarkerFaceColor','k','markersize',4);hold on %”““∆--º”°£œ¬“∆--ºı°£
        m_text(point_lon(9)-0.8,point_lat(9)+0.1,buoy_name{9},'fontname','times new roman','FontSize',8);hold on %◊Û“∆--ºı°£…œ“∆--º”°£
    end
    break
end

%% µ˜≤Œ
while(1)
    %----------------------------------------%
    CM_piece_num = 10;%colorbar
    CM = colormap(m_colmap('blues',CM_piece_num));%colormap(jet(CM_piece_num)); %colormap(m_colmap('blues')); %CM = colormap(cool(CM_piece_num));
    %cmocean_deep;% cmocean__deep; % colormap(cmocean__deep(round((256/5)*(1:1:5)),:));
    
    set(gcf,'color','w');  % otherwise 'print' turns lakes black
    set(ax.YLabel,'string','Water Depth (m)','fontname','times new roman','fontsize',14');
    set(ax,'position',[0.8 0.1 0.0388 0.8],...
        'Ytick',fliplr([0 -1200  -2400 -3600 -4800 -6000]),...%'Yticklabel',{'0';'600';'1200';'1800';'2400';'3000';'3600';'4200';'4800';'5400';'6000'},...
        'YTickLabelMode','auto',...
        'TickLength',[0.01 0.01],...
        'Ydir','reverse');
        

    break
end
