programGo %='work_ERA5_nanhai_3Y'
wildcards1 %= 1950:1:1957
LatDeg %=0.125
LatMax %= 24;
LonDeg %=0.125
LonMin %= 105;
PointLon %= 108
PointLat %= 20
PointMatName %='Step3_Hs_PointMat_P1'



while(1)
    % tic
    %wildcards1 = 1950:1:1957
    wildcards2 = {'01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12'};
    
    P1 = nan(750,length(wildcards1)*12); %96个月，每个月的数据量<750，一天24个数据，
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
            lon = (PointLon-LonMin)/LonDeg+1;%108 116 119 114 116 110
            lat = (LatMax-PointLat)/LatDeg+1; %20 21 20 17 11 14
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
    
    % toc %历时 264.228867 秒。
    % save('Step3_Hs_P5_','P1');
    break
end


% 保存数据
str=strcat('../',programGo);
cd(str)
save(PointMatName,'P1');


%}

