clear all;
close all;
Length = 100;
Width = 100;
Node_number = 3;
%观测站位置随机给定

for i = 1 : Node_number
    Node(i).x = Width*rand;
    Node(i).y = Length*rand;
    Node(i).D = Node(i).x^2 + Node(i).y^2;
end

%目标的位置随机设定
Target.x = Width*rand;
Target.y = Length*rand;

%各观测站对目标检测10次，将平均值作为最终Rssi

Z=[];
for i = 1 : Node_number
    for t = 1:10
        [d1] = DIST (Node(i),Target);
        Z(i,t) = GetRssiValue(d1);
    end
end
%求观测均值

ZZ = [];

for i = 1 :Node_number
    ZZ(i)=sum(Z(i,:))/10;
end
%根据采样RSSI，求观测距离
Zd=[];
for i = 1:Node_number
    Zd(i)=GetDistByRssi(ZZ(i));
end

%根据观测距离，用最小二乘法，求目标位置
H = []; b = []; 

for i = 2 :Node_number
    H = [H;2*(Node(i).x-Node(1).x), 2*(Node(i).y-Node(1).y)];
    b = [b;Zd(1)^2 - Zd(i)^2 + Node(i).D - Node(1).D];
end

Estimate = inv(H'*H)*H'*b;
Est_Target.x = Estimate(1); Est_Target.y = Estimate(2); 

%画图
figure
hold on; box on; axis([0 120 0 120]);
for i=1:Node_number
    h1 = plot(Node(i).x , Node(i).y, 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 10);
    text(Node(i).x +2, Node(i).y ,['Node',num2str(i)]);
end

h2 = plot(Target.x ,Target.y,'k^','MarkerFaceColor', 'b', 'MarkerSize', 10);
h3 = plot(Est_Target.x, Est_Target.y, 'ks', 'MarkerFaceColor', 'r', 'MarkerSize', 10);

line([Target.x, Est_Target.x], [Target.y, Est_Target.y], 'Color', 'k');

%legend([h1, h2, h3], 'Observation Station', 'Target Position', 'Estimate Position');
legend([h1, h2, h3], '观测站', '真实位置', '估计位置');

[Error_Dist, d2]=DIST(Est_Target, Target);
xlabel(['error=', num2str(Error_Dist), 'm']);
title('RSSI定位算法')
set(gcf, 'Color', 'w');





