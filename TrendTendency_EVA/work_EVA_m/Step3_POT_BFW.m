function [pot,thredhold] = Step3_POT_BFW(Hs,Tmin,BFW)
%%
suoyin = 1:1:length(Hs);
Hs(:,2) = Hs(:,1);
Hs(:,1) = suoyin';
Tmin = Tmin*24; %necessary
%%
thredhold = quantile(Hs(:,2),BFW);
pot = findpot(Hs, quantile(Hs(:,2),BFW), Tmin);
pot = Hs(pot,2);

end

