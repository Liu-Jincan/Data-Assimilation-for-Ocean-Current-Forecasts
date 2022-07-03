function [shape,scale,location,p,gev1_rmse,Hs_invgev1] = Step3_gev(Hs)
%% 参数估计
gev1 = fitgev(Hs,'method','PWM');
% gev1 = fitgev(Hs,'method','PWM','plotflag',1)
% plotfitsumry(gev1);
phat = gev1;

shape = gev1.params(1);
scale = gev1.params(2);
location = gev1.params(3);
%% QQ图
% data=sort(phat.data(:));
% dist = phat.distribution;
% cphat = num2cell(phat.params,1);
% h3 = plotresq(data,dist,cphat{:});


%% p值
p = gev1.pvalue; 

%% rmse
model = 'gev';
n = length(Hs);
eprob = ((1:n)-0.5)/n;

cphat = {gev1.params(1),gev1.params(2),gev1.params(3)};
Hs_guji1 = feval(['inv' model],eprob,cphat{:})'; %??????????????????
HsSort = sort(Hs); %由小到大
gev1_rmse = sqrt(mean((Hs_guji1-HsSort).^2));

% qqplot(Hs_guji1,Hs_guji1);
% plotqq(Hs_guji1,Hs_guji1)
%% return level
T = logspace(0.1,2.3,100); %重现期范围

Hs_invgev1 = invgev(1./T,gev1,'lowertail',false,'proflog',false); 
%invgev   ：是求gev函数的逆函数，逆函数的函数值为Hs；
%           1./T ，是发生的概率；
%           'lowertail',false，1./T = Prob[X > 所求值]；
% semilogx(T,Hs_invgev1), hold on
plot(T,Hs_invgev1,'Linewidth',1),hold on

%N=1:length(Hs); Nmax=max(N);
%plot(Nmax./N,sort(Hs,'descend'),'.'), hold on
%% 10 25 50 100
T = [10 25 50 100 200];
Hs_invgev1 = invgev(1./T,gev1,'lowertail',false,'proflog',false);
%[Hs_invgev1,lo,up] = invgev(1./T,gev1,'lowertail',false,'proflog',true)
end