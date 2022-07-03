function [value,b,kCIu,b2,kCIl,b3]=Trend_TheiSenNiHe(x,y,alpha) %测试了一次
%% 参考：https://www.jianshu.com/p/bff8b4058d5d
%% 初始数据：x，年份，顺序不能乱；y，NSWH 
% x=[0.00310,0.00313,0.00316,0.00319,0.00322,0.00326,0.00329,0.00332];
% y=[9.985,9.893,9.810,9.729,9.646,9.581,9.507,9.451];
% x = [0 1 2];
% y = [0 1 2];
% x = rand(1,100);
% y = rand(1,100);
%% 拟合直线y=p(1)*x+p(2) 
%% 求斜率
cd = length(x); %n
while(1)
    valuesum=[];
    for k1=2:1:cd
        for k2=1:1:(k1-1)
            cz=y(k1)-y(k2);
            jl=k1-k2;
            value=cz/jl;
            valuesum=[valuesum;value];
        end
    end
    valuesum;
    value=median(valuesum); %斜率
        %
    break
end
%% 求截距
b = mean(y)-value*mean(x);

%% 显示拟合前后直线，其中方框为拟合前数据，直线为拟合后的直线
% p = [value b]
% yy = polyval(p,x);
% plot(x,y,'s',x,yy);

%% 拟合的直线方程
% poly2sym(p,'x')

%% 调用MannKendallTest
[~,vars]=Trend_MannKendallTest(x,y);

%% 对T进行排序（从小到大，保留疑问？从大到小）
T = sort(valuesum);

%% 求斜率在一定α下的CI（置信区间）,即斜率有1-α概率在这上面------重点
% alpha = 0.05;
while(1)
    SD = sqrt(vars);
    alpha; %α是显著性水平，弃真概率
    temp1 = (length(T)+SD*norminv(1-alpha/2))/2; %保留疑问，n？N？
    temp2 = (length(T)-SD*norminv(1-alpha/2))/2;
    kCIu = T(ceil(temp1)); %向上取整
    kCIl = T(floor(temp2)); %向下取整
    %
    break
end

%% 求截距
b2 = mean(y)-kCIu*mean(x);
b3 = mean(y)-kCIl*mean(x);

end 