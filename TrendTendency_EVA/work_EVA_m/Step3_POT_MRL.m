function [threshold,mrl,pot]=Step3_POT_MRL(xn2,Tmin,Nmin)
%xn2 = IDM; % Hs
%Tmin = 5; % minimum distance between extremes %5days; no;
%Nmin = 7; % minimum number of extremes
Tmin = Tmin*24; %necessary
tc2 = dat2tc(xn2); %从数据中提取波峰和波谷
umin = median(tc2(:,2)); % 中值峰
Ie0 = findpot(tc2, 0.9*umin, Tmin); %pot找到的数据
Ev = sort(tc2(Ie0,2));

Ne = numel(Ev); %数据个数
if Ne>Nmin && Ev(Ne-Nmin)>umin
    umax = Ev(Ne-Nmin);
else
    umax = umin;
end

Nu = floor((umax-umin)/0.025)+1;
u = linspace(umin,umax,Nu);
mrl = reslife(Ev, 'u',u); %
umin0 = umin;
for io= numel(mrl.data):-1:1,
    CI = mrl.dataCI(io:end,:);
    if ~(max(CI(:,1))<= mrl.data(io) & mrl.data(io)<=min(CI(:,2))),
        umin0 = mrl.args(io);
    break;
    end
end %MRL vs threshold

% plot(mrl)
% vline(umin0,'g') % Threshold from mean residual life plot
threshold = umin0;
pot = findpot(tc2, threshold, Tmin);
pot = tc2(pot,2);

end