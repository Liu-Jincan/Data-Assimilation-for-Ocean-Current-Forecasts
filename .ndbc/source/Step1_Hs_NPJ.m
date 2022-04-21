%{
tic
wildcards1 = 1958:1:2019
wildcards2 = {'01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12'};

NPJ = zeros(62,1); %盆地年平均
for i=1:1:length(wildcards1)
    i
    nian = [];
    for j=1:1:length(wildcards2)
        %% YearAnaMonth
        YearAnaMonth = strcat(num2str(wildcards1(i)),wildcards2(j));
        YearAnaMonth = cell2mat(YearAnaMonth);
        %
        %% filename
        filename = strcat('G:\ERA5_China_nanhai\ERA5_',YearAnaMonth,'.nc');
        %% Step1_Hs
        M = ncread(filename,'swh');
        [M1 M2 M3] = size(M);
        M = reshape(M,M1*M2*M3,1); %good idea
        nian = [nian;M];
        %% eval
        %str = strcat('NanHai_Hs_',YearAnaMonth);
        %eval([str '=M;']);
        %% save
        %save(str,str);
        %% clear
        %eval(['clear ' str]);
    end
    NPJ(i) = nanmean(nian);
end
toc

% 1958-2019年，不包括2020年 历时 514.730064 秒。
% NPJ = [1.30781336948453;1.27885396668589;1.34181488736432;1.34480769560987;1.35756028556620;1.29254809834639;1.37588609379600;1.27194112394667;1.27008982927394;1.48338265766448;1.24513720232195;1.27280413919238;1.33941762266060;1.49046062779923;1.27964888013526;1.35422280544340;1.42403518685518;1.32205618391158;1.32684333294254;1.37063468527312;1.37105687988808;1.27271494253546;1.30840430567936;1.34358832328773;1.26163231597575;1.27664136468971;1.32721508042759;1.35003739301222;1.40459217148958;1.26512721757873;1.41329468522933;1.37350938065372;1.35225895993183;1.37971276367788;1.34150463853329;1.38082506819679;1.34589718241678;1.42347290629250;1.43974986425316;1.27518692947426;1.22746336098053;1.49486650946231;1.43055671030522;1.40338936942687;1.32041730938100;1.39071994436220;1.35918924712701;1.37735976138728;1.41010682407150;1.38807765297920;1.43600921429493;1.44691146522565;1.26858915534206;1.55876755518673;1.36979841174569;1.41446267582663;1.34931978731608;1.30915360342255;1.35956486883605;1.43672287033705;1.43674592720100;1.38128718218020]
%}
%*************************************************************************
%*************************************************************************
tic
clear all
load('Step1_Hs_NPJ')
x = 1958:1:2019;
y = NPJ;

%% The line of best fit
[k1,b1] = Trend_ZuiJiaXianNiHe(x,y);

%% Thei-Sen and MannKendall 
alpha = 0.05;
[k2,b2,k3,b3,k4,b4] = Trend_TheiSenNiHe(x,y,alpha);
[CL,~] = Trend_MannKendallTest(x,y); %置信水平

%% plot
close all
figure('NumberTitle', 'off', 'Name','1','color',[1,1,1])
hold on
plot(x,polyval([k1,b1],x),'r');
plot(x,polyval([k2,b2],x),'k');
plot(x,polyval([k3,b3],x),'--k');
plot(x,polyval([k4,b4],x),'--k');
plot(x,y,'k');
ylabel("mean SWH (m)",'FontName','Times New Roman')

xlim([1957 2020])

% ：：坐标轴设置
while(1)
    x = xlim();
    y = ylim();
    axis([x(1) x(end) y(1) y(end)]); %设置坐标轴axis取值范围
    set(gca,'Tickdir','out'); %设置刻度外翻
    % ：：图形框右边和上边设置
    plot([x(end) x(end)],[y(1) y(end)],...
        'color','k',...
        'linewidth',1);
    plot([x(1) x(end)],[y(end) y(end)],...
        'color','k',...
        'linewidth',1);
    % ：：图形下边和左边
    plot([x(1) x(end)],[y(1) y(1)],...
        'color','k',...
        'linewidth',1);
    plot([x(1) x(1)],[y(1) y(end)],...
        'color','k',...
        'linewidth',1);
    % ：：去掉右上角刻度
    % get(gca)
    
    %
    break
end
%
legend('d','T','T±CL','Location','NorthWest')

toc