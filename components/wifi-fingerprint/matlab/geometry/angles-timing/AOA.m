clear all;
close all;
clc;

%% ---------------- 前半截：核心算法（我为你补齐的） ----------------
% 1. 定位初始化 (双站定位)
Length = 100;
Width = 100;
Node_number = 2; % 双站角度测量，所以设为2个基站

for i=1:Node_number 
    Node(i).x = Width*rand;
    Node(i).y = Length*rand;
end

% 目标位置随机设定
Target.x = Width*rand;
Target.y = Length*rand;

% 2. 模拟基站测量目标信号的到达角度 (AOA)
theta = zeros(Node_number, 1);
for i=1:Node_number
    % 计算真实角度 atan2(y, x)
    real_theta = atan2(Target.y - Node(i).y, Target.x - Node(i).x);
    
    % 模拟测量误差（加入均值为0，标准差为 2度 的高斯白噪声）
    noise = (2 * pi / 180) * randn; 
    theta(i) = real_theta + noise;
end

% 3. 角度定位的矩阵解算 (最小二乘法)
% 原理公式: sin(θ) * x - cos(θ) * y = sin(θ) * x_i - cos(θ) * y_i
H = []; b = [];
for i=1:Node_number
    H = [H; sin(theta(i)), -cos(theta(i))];
    b = [b; sin(theta(i))*Node(i).x - cos(theta(i))*Node(i).y];
end

% 最小二乘法估计位置
Estimate = inv(H'*H)*H'*b; 
Est_Target.x = Estimate(1);
Est_Target.y = Estimate(2);

%% ---------------- 后半截：可视化代码（来自你的图片） ----------------
figure
hold on; box on; axis([0 120 0 120]);
for i=1:Node_number
    h1 = plot(Node(i).x,Node(i).y,'ko','MarkerFace','g','MarkerSize',10);
    text(Node(i).x+2,Node(i).y,['Node',num2str(i)]);
end

h2 = plot(Target.x,Target.y,'k^','MarkerFace','b','MarkerSize',10);
h3 = plot(Est_Target.x,Est_Target.y,'ks','MarkerFace','r','MarkerSize',10);
line([Target.x,Est_Target.x],[Target.y,Est_Target.y],'Color','k');
legend([h1,h2,h3],'观测站','真实位置','估计位置');

[Error_Dist]=DIST(Est_Target,Target);
xlabel(['error=',num2str(Error_Dist),'m']);
set(gcf,'Color','w');
title('双站角度定位')

% 函数定义部分
function [dist]=DIST(A,B)
    dist = sqrt((A.x-B.x)^2+(A.y-B.y)^2);
end