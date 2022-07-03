function [CL,vars]=Trend_MannKendallTest(x,y) %测试了一次
%% 参考：https://www.jianshu.com/p/7e1ac6a2f3b0  对95%置信度水平也有分析。（双边检验）
%% 参考：https://baike.baidu.com/item/Mann-Kendall%E8%B6%8B%E5%8A%BF%E6%A3%80%E9%AA%8C%E6%B3%95/17829790?fr=aladdin
%         明确给出了是双边检验
%% 参考：p值（极端概率、事后）和α（显著性水平、事前、弃真概率）的区别 https://zhidao.baidu.com/question/433851099.html

%% 初始数据
% x = rand(1,100);
% y = rand(1,100);
%% 求S
cd = length(x);
sgnsum = [];
for k=2:cd
    for j=1:(k-1)
        sgn = y(k)-y(j);
        if sgn>0
            sgn = 1;
        else
            if sgn<0
                sgn = -1;
            else
                sgn = 0;
            end
        end
        sgnsum = [sgnsum;sgn];
    end
end
add = sum(sgnsum); %S

%% 求tiedGroup, y需要是行向量
while(1)
    %{
    https://zhidao.baidu.com/question/546878015.html
    
    a = [1,4,2,3,4,4,5,5,2,6,6,6,6,6,6,6,6,6,6,100];
    b = union(a,[]);
    [N,X] = hist(a,b);
    Y = X(N>1);
    %}
    %% 找出y重复出现的元素Y,及其次数N
    a = y;
    b = union(a,[]);
    [N,X] = hist(a,b);
    Y = X(N>1); %Y是什么？
    YY = N(N>1); %这里错的很惨！！！！！，幸亏找出来了，不然血炸。
    %% }
    break
end

%% 求Var(S)
Sum = 0;
for i=1:1:length(YY)
    Sum = Sum+YY(i)*(YY(i)-1)*(2*YY(i)+5);
end
vars = (cd*(cd-1)*(2*cd+5)-Sum)/18;

%% 求Z
if(add>0)
    Z = (add-1)/sqrt(vars);
else
    if(add==0)
        Z = 0;
    else
        Z = (add+1)/sqrt(vars);
    end
end
Z
%% 求出Z统计量的cdf：统计意义是什么，趋势显著达到什么水平；
while(1)
    %% 参考：https://blog.csdn.net/sinat_26566137/article/details/80069481
    p = normcdf(1.645); %95
    p = normcdf(1.96);  %97.5
    %
    break
end
CL = abs(normcdf(Z)-normcdf(-Z)); %置信水平、累积概率  （有其对应的置信区间）
CL;

end