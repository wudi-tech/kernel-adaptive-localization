clear all;
close all;
Length = 100;
Width = 100;
Node_number = 6;
%观测站位置随机给定

for i = 1 : Node_number
    Node(i).x = Width*rand;
    Node(i).y = Length*rand;
    Node(i).D = Node(i).x^2 + Node(i).y^2;
end

%目标的位置随机设定
Target.x = Width*rand;
Target.y = Length*rand;

%观测点探测目标

X=[] ; Z=[];
for i = 1 : Node_number
    [d1,d2] = DIST (Node(i),Target);
    d1 = d1 + sqrt(5)*randn;
    X = [X;Node(i).x, Node(i).y];
    Z = [Z, d1];
end

H = []; b = [];

for i = 2 :Node_number
    H = [H;2*(X(i,1)-X(1,1)), 2*(X(i,2)-X(1,2))];
    b = [b;Z(1)^2 - Z(i)^2 + Node(i).D - Node(1).D];
end

Estimate = inv(H'*H)*H'*b;
Est_Target.x = Estimate(1); Est_Target.y = Estimate(2); 

%画图
figure
hold on; box on; axis([0 100 0 100]);
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
title('基于测距的最小二乘定位算法')
set(gcf, 'Color', 'w');







