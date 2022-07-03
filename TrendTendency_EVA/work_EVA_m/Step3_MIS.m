function [events,durations,JZ] = Step3_MIS(Hs,threshold)
% https://jingyan.baidu.com/article/09ea3ededb08b681afde39d1.html
% Hs = [12 13 2 15 2 19 18 nan];
% threshold = 10;
%% nanȥ��
Hs = Hs(~isnan(Hs));
%% �߼�ֵ
A = (Hs>=threshold);
A = A'; %��ΪHs��������
%% 1��-1
k = diff([0 A 0]);
%% ��ʼλ��
ind = find(k==1);
%% ����ʱ��
num = find(k==-1)-ind;
%% �ܵĴ���
events = length(ind);
%% �ܵĳ���ʱ��
durations = sum(num);
%% ��ֵ����
JZ = zeros(events,1);
for i=1:1:events
    temp = Hs(ind(i):ind(i)+num(i)-1);
    JZ(i) = max(temp);
end

end

