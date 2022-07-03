function [] = Step3_MIS_bin(events,duration)
% https://www.cnblogs.com/ziqiao/archive/2011/11/29/2268456.html
%{
series1=rand(1,5);
series2=rand(1,5);
bar1=bar([1:4:17],series1,'BarWidth',0.2,'FaceColor','b');
hold on;
bar2=bar([2:4:18],series2,'BarWidth',0.2,'FaceColor','c');
legend('series1','series2');
labelID = ['A';'B'; 'C'; 'D'; 'E'];
set(gca,'XTick',1.5:4:17.5);
set(gca,'XTickLabel',labelID);
%}


series1=events;
series2=duration;
%%
s
bar1=bar([1:4:45],series1,'BarWidth',0.2,'FaceColor','b');
hold on;

%h = legend('Events (Number)','Durations (Hours)','Location','NorthWest'); %https://www.douban.com/note/503620762/
%set(h,'FontName','Times New Roman','FontSize',8,'FontWeight','normal');
labelID = ['J';'F'; 'M'; 'A'; 'M';'J';'J';'A';'S';'O';'N';'D'];
set(gca,'XTick',1.5:4:45.5,'XTickLabel',labelID,'FontName','Times New Roman','FontSize',14);

%%
bar2=bar([2:4:46],series2,'BarWidth',0.2,'FaceColor','c');

end

