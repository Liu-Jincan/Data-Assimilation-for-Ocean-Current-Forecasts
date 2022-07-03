%% 我们首先定义一些参数，Nmin,Tmin,Tb，来控制declustering，并识别那些超过中值峰大小90%的且至少被Tmin分开的峰。
Nmin=7; % minimum number of extremes
Tmin=5; % minimum distance between extremes
%Tb = 15; % block period ，Block period (same unit as the sampled times)  (default 1)
xn = load('sea.dat');

% plot(xn(:,2));
% dt = xn(2,1)-xn(1,1); % in seconds
tc = dat2tc(xn); %从数据中提取波峰和波谷
umin = median(tc(tc(:,2)>0,2)); %>0部分，中值峰
Ie0 = findpot(tc, 0.9*umin, Tmin); %pot找到的数据
Ev = sort(tc(Ie0,2));

Ne = numel(Ev) %数据个数
if Ne>Nmin && Ev(Ne-Nmin)>umin,
   umax = Ev(Ne-Nmin);
else
  umax = umin;
end

%% 接下来，我们计算umin和umax之间阈值的expected residual life和dispersion index，并为峰数选择一个与泊松分布相容的区间。
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
% [di, threshold, ok_u] = disprsnidx(tc(Ie0,:), 'Tb', Tb, 'alpha',0.05, 'u',u); %Dispersion Index vs threshold

[di, threshold, ok_u] = disprsnidx(tc(Ie0,:),  'alpha',0.05, 'u',u); %Dispersion Index vs threshold

%% 两种方法的阈值图像
figure(1); plot(di)
vline(threshold) % Threshold from dispersion index
vline(umin0,'g') % Threshold from mean residual life plot
figure(2); plot(mrl)
vline(threshold) % Threshold from dispersion index
vline(umin0,'g') % Threshold from mean residual life plot

%% 使用阈值进行分析
Ie = findpot(tc, threshold, Tmin);

timeSpan = (xn(end,1)-xn(1,1))/60; % in minutes
lambda = numel(Ie)/timeSpan; % # Y> threshold per minute
varLambda = lambda*(1-(dt/60)*lambda)/timeSpan;
stdLambd = sqrt(varLambda)
Ev = tc(Ie,2);
phat = fitgenpar(Ev, 'fixpar',[nan,nan,threshold], 'method','mps');