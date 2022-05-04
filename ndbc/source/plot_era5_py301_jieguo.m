clear all
close all
clc
% data=load('ERA5_PY301_match.dat');
load('SWH_buoy_era5_dat.mat')
a = obs_all;
b = reana_all;
%load('SWH_buoy_era5_dat_2011')
%c = obs_all;
%d = reana_all;
%clear obs_all
%clear reana_all
ndbc_swh = [a];
era5_swh = [b];

[d,de]=DensScat(ndbc_swh,era5_swh); %1
set(gca,'xlim',[0,8],'ylim',[0,8],'fontsize',14,'fontname','Times New Roman')
colormap('Jet')
hc = colorbar;
set(hc,'ticks',[10 40 80 120 160 200 240],'ticklabels',[{'10'};{'40'};{'80'};{'120'};{'160'};{'200'};{'240'};],...
    'LineWidth',1,...
    'fontname','times new roman','FontSize',14,...
    'TickLabelInterpreter','tex',...
    'visible','on');
set(hc.Label,'String','Number of points','fontname','times new roman','FontSize',14);
%hc.Label.String = 'Number of points';
hold on
plot(0:0.01:9,0:0.01:9,'k-','linewidth',2)
xlabel('Buoy SWH (m)','fontsize',14,'fontname','Times New Roman')
ylabel('ERA5 SWH (m)','fontsize',14,'fontname','Times New Roman')

N=length(ndbc_swh);

%[bias,rms,corr]=cal_index(N,ndbc_swh,era5_swh); %2
error = ndbc_swh-era5_swh;
rmse = sqrt(mean(error.*error)) %N
maxBouySWH = max(ndbc_swh)
rmse_max = rmse/maxBouySWH
bias = mean(-1*error)
r = min(min(corrcoef(ndbc_swh, era5_swh)))


hold on
text(1,6.8,['Bias = -0.07 m'],'fontsize',14,'fontname','Times New Roman')
hold on
text(1,7.5,['RMSE = 0.35 m (5.06%)'],'fontsize',14,'fontname','Times New Roman')
hold on
text(1,6.1,['R = 0.95'],'fontsize',14,'fontname','Times New Roman')

