function [threshold,di,pot]=Step3_POT_DI_SensitOfThres(xn2,Tmin,Nmin,Tb,kesei)
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
threshold = threshold+kesei;
pot = findpot(tc2, threshold, Tmin);
pot = tc2(pot,2);


end