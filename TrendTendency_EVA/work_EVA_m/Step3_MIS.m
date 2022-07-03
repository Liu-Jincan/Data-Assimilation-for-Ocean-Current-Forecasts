function [events,durations,JZ] = Step3_MIS(Hs,threshold)
% https://jingyan.baidu.com/article/09ea3ededb08b681afde39d1.html
% Hs = [12 13 2 15 2 19 18 nan];
% threshold = 10;
%% nan去除
Hs = Hs(~isnan(Hs));
%% 逻辑值
A = (Hs>=threshold);
A = A'; %因为Hs是列向量
%% 1，-1
k = diff([0 A 0]);
%% 开始位置
ind = find(k==1);
%% 持续时间
num = find(k==-1)-ind;
%% 总的次数
events = length(ind);
%% 总的持续时间
durations = sum(num);
%% 极值序列
JZ = zeros(events,1);
for i=1:1:events
    temp = Hs(ind(i):ind(i)+num(i)-1);
    JZ(i) = max(temp);
end

end

