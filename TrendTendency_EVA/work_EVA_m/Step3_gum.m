function [shape,scale,location,p,gev1_rmse,Hs_invgev1] = Step3_gum(Hs)
%{
%% 参数估计
gum1 = fitgumb(Hs);
shape = gum1.params(1);
scale = gum1.params(2);
location = gum1.params(3);

%% p值
p = gum1.pvalue; 

%% rmse
model = 'gev';
n = length(Hs);
eprob = ((1:n)-0.5)/n;

cphat = {gum1.params(1),gum1.params(2),gum1.params(3)};
Hs_guji1 = feval(['inv' model],eprob,cphat{:})'; %??????????????????
HsSort = sort(Hs); %由小到大
gev1_rmse = sqrt(mean((Hs_guji1-HsSort).^2));

%% return level
T = logspace(0.1,2,100); %重现期范围

Hs_invgev1 = invgev(1./T,gum1,'lowertail',false,'proflog',false); %invgev 是求gev函数的逆函数，逆函数的函数值为Hs；
semilogx(T,Hs_invgev1), hold on
%N=1:length(Hs); Nmax=max(N);
%plot(Nmax./N,sort(Hs,'descend'),'.'), hold on
%}
%
%% 参数估计
gev1 = fitgev(Hs,'fixpar',[0 nan nan],'method','ML');
shape = gev1.params(1);
scale = gev1.params(2);
location = gev1.params(3);

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

%% return level
T = logspace(0.1,2.3,100); %重现期范围

Hs_invgev1 = invgev(1./T,gev1,'lowertail',false,'proflog',false); %invgev 是求gev函数的逆函数，逆函数的函数值为Hs；
% semilogx(T,Hs_invgev1), hold on
plot(T,Hs_invgev1,'Linewidth',1),hold on

%N=1:length(Hs); Nmax=max(N);
%plot(Nmax./N,sort(Hs,'descend'),'.'), hold on
%% 10 25 50 100
T = [10 25 50 100 200];
Hs_invgev1 = invgev(1./T,gev1,'lowertail',false,'proflog',false);
end