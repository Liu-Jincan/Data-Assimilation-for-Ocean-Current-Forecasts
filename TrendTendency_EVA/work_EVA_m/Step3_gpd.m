function [shape,scale,location,p,gpd1_rmse,Hs_invgpd1] = Step3_gpd(Hs,thredhold)
%{
%% 参数估计
% Hs=DI_pot;
gpd1 = fitgenpar(Hs,'method','PWM');
shape = gpd1.params(1);
scale = gpd1.params(2);
location = gpd1.params(3);

%% p值
p = gpd1.pvalue; 

%% rmse
model = 'genpar';
n = length(Hs);
eprob = ((1:n)-0.5)/n;

cphat = {gpd1.params(1),gpd1.params(2),gpd1.params(3)};
Hs_guji1 = feval(['inv' model],eprob,cphat{:})'; %??????????????????
HsSort = sort(Hs); %由小到大
gpd1_rmse = sqrt(mean((Hs_guji1-HsSort).^2));

%% return level
T = logspace(0.1,2,100); %重现期范围
%Hs_invgpd1 = invgenpar(1./T,phat,'lowertail',false,'proflog',false); %invgev 是求gev函数的逆函数，逆函数的函数值为Hs；
Hs_invgpd1 = invgenpar(1./T,gpd1,'lowertail',false,'proflog',false); %invgev 是求gev函数的逆函数，逆函数的函数值为Hs；
semilogx(T,Hs_invgpd1), hold on
% N=1:length(Hs); Nmax=max(N);
% plot(Nmax./N,sort(Hs,'descend'),'.'), hold on
%}

%
%% 参数估计
gpd1 = fitgenpar(Hs,'fixpar',[nan,nan,thredhold],'method','PWM');
shape = gpd1.params(1);
scale = gpd1.params(2);
location = gpd1.params(3);
%% p值
p = gpd1.pvalue; 
%% rmse
model = 'genpar';
n = length(Hs);
eprob = ((1:n)-0.5)/n;
cphat = {gpd1.params(1),gpd1.params(2),gpd1.params(3)};
Hs_guji1 = feval(['inv' model],eprob,cphat{:})'; %??????????????????
HsSort = sort(Hs); %由小到大
gpd1_rmse = sqrt(mean((Hs_guji1-HsSort).^2));
%% return level
T = logspace(0.1,2.3,100); %重现期范围
Hs_invgpd1 = invgenpar(1./T,gpd1,'lowertail',false,'proflog',false); %invgev 是求gev函数的逆函数，逆函数的函数值为Hs；
% semilogx(T,Hs_invgpd1), hold on
plot(T,Hs_invgpd1,'Linewidth',1),hold on

% N=1:length(Hs); Nmax=max(N);
% plot(Nmax./N,sort(Hs,'descend'),'.'), hold on
%
%% 10 25 50 100
T = [10 25 50 100 200];
[Hs_invgpd1,lo,up ]= invgenpar(1./T,gpd1,'lowertail',false,'proflog',false);
lo
up

end