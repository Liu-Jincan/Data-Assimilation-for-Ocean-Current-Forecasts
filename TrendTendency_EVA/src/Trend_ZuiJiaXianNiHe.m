function [p1,p2]=Trend_ZuiJiaXianNiHe(x,y) %测试了一次

%% 初始数据
% x=[0.00310,0.00313,0.00316,0.00319,0.00322,0.00326,0.00329,0.00332];
% y=[9.985,9.893,9.810,9.729,9.646,9.581,9.507,9.451];
% x = [0 1 2];
% y = [0 1 2];
% x = rand(1,100);
% y = rand(1,100);
%% 拟合直线y=p(1)*x+p(2)
p = polyfit(x,y,1);
p1 = p(1);
p2 = p(2);
vpa(p,8);
%% 显示拟合前后直线，其中方框为拟合前数据，直线为拟合后的直线
% yy = polyval(p,x);
% plot(x,y,'s',x,yy);
%% 拟合的直线方程
% poly2sym(p,'x')



end 