%
wildcards1 = {'59334' '59506' '59515' '59544' '59765' '59861' '59964' 'G7425' 'G9599' 'N9170'};
lon_reana_all = [118.25 116.125 117.375 119 111.5 111.875 111 114.875 117.25 109.125];
lat_reana_all = [22.625 22.125 22.375 22.625 20.75 19.375 18.5 21.875 21 20.5];
% 
close all
for ss=10%:1:length(lon_reana_all)
    obs_all = []
    reana_all = []
    str = strcat('D:\文献阅读\毕业设计\my\dataEvalue\to ljc\CHN_',wildcards1{ss},'.dat')
    A = load(str);
    lon_reana = lon_reana_all(ss);
    lat_reana = lat_reana_all(ss);
    
    %
    wildcards2 = {'01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12'};
    yue = [];
    for i=1:1:12
        if(sum(find(A(:,2)==i)))
            yue = [yue i];
        end
    end
    
    % reana
    reana = [];
    for i=1:1:length(yue)
        %% YearAnaMonth
        YearAnaMonth = strcat('2020',wildcards2{yue(i)});
        %% filename
        filename = strcat('E:\ERA5_China_nanhai\ERA5_',YearAnaMonth,'.nc');
        %% JD;matrix
        M = ncread(filename,'swh');
        M = permute(M,[2 1 3]); %转置，结点与Panoply的array 1对应，nan+未转置图像判断是否正确（成功），（lat-索引大lat小，lon-索引大lon大，data）
        % lon: 110.125  105-120 0.125
        % lat: 17.125  9-24 0.125
        lon = (lon_reana-105)/0.125+1;
        lat = (24-lat_reana)/0.125+1;
        M = M(lat,lon,:);
        M = M(:);
        [m,n] = size(M);
        %
        B = zeros(m,4);
        B(:,1) = yue(i);
        while(1)
            days = m/24;
            ri = (1:days)';
            ri = repelem(ri,24);
            break
        end
        B(:,2) = ri;
        while(1)
            shi = (0:1:23)';
            shi = repmat(shi,days,1);
            break
        end
        B(:,3) = shi;
        B(:,4) = M;
        %% tichu ?
        MM = [];
        %B = [1 2 3 4;1 3 4 5];
        %A = [0 1 2 3;0 1 3 4];
        [m,~] = size(B);
        [m2,n2] = size(A);
        for j=1:1:m
            flag = 0;
            for k=1:1:m2
                if( A(k,2)==B(j,1) & A(k,3)==B(j,2) & A(k,4)==B(j,3))
                    flag =1;
                    break
                end
            end
            if(flag==1)
                MM = [MM;B(j,4)];
            end
        end
        reana = [reana;MM];
        
        
    end
    
    % obs
    obs = A(:,6);
    %******************************************************************
    
    
    obs_all = [obs_all;obs];
    reana_all = [reana_all;reana];
    
    %%
    % nan
    suoyin = ~isnan(obs_all);
    obs_all = obs_all(suoyin);
    reana_all = reana_all(suoyin);
    %
    fprintf('Buoy ID: %s\n',wildcards1{ss})
    % min max std mean
    fprintf('       obs          reana\n')
    fprintf('min:  %.3f         %.3f\n',min(obs_all),min(reana_all))
    fprintf('max:  %.3f         %.3f\n',max(obs_all),max(reana_all))
    fprintf('std:  %.3f         %.3f\n',std(obs_all),std(reana_all))
    fprintf('mean: %.3f         %.3f\n',mean(obs_all),mean(reana_all))
    
    % rmse
    N = length(obs_all);
    
    error = obs_all-reana_all;
    rmse = sqrt(mean(error.*error)); %N
    bias = mean(-1*error);
    PE = sqrt(mean((error./obs_all).^2))*100;
    SI = rmse/mean(obs_all);
    
    r = min(min(corrcoef(obs_all, reana_all)));
    fprintf('\n')
    fprintf('rmse: %.3f\t%.2f%%\n',rmse,(rmse/max(obs_all))*100)
    fprintf('bias: %.3f\n',bias)
    fprintf('  SI: %.3f\n',SI)
    fprintf('  PE: %.3f\n',PE)
    fprintf('   r: %.3f\n',r)
    fprintf('%d\t%.2f\t%.2f(%.2f%%)\t%.2f\n',N,r,rmse,(rmse/max(obs_all))*100,bias)
    
    % plot
    figure(1)
    plot(obs_all);hold on;plot(reana_all);
    figure(2)
    qqplot(obs_all,reana_all);
end

close all




