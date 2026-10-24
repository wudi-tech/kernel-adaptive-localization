clear all;
close all;

Length = 100;
Width = 100;
Node_number = 6;
num_runs = 1000; % 设定蒙特卡洛模拟的次数为 1000 次

% 提前准备一个空数组，用来记录这 1000 次中每一次的误差
error_array = zeros(1, num_runs); 

% 开启蒙特卡洛大循环
for run = 1 : num_runs
    
    % 1. 每次都重新随机撒下观测站
    for i = 1 : Node_number
        Node(i).x = Width*rand;
        Node(i).y = Length*rand;
        Node(i).D = Node(i).x^2 + Node(i).y^2;
    end
    
    % 2. 每次都重新随机生成目标位置
    Target.x = Width*rand;
    Target.y = Length*rand;
    
    % 3. 模拟测距并加入噪声
    X=[]; Z=[];
    for i = 1 : Node_number
        [d1,d2] = DIST(Node(i), Target);
        d1 = d1 + sqrt(5)*randn;  % 依然是加入方差为5的随机噪声
        X = [X; Node(i).x, Node(i).y];
        Z = [Z, d1];
    end
    
    % 4. 构建矩阵并用最小二乘法求解
    H = []; b = [];
    for i = 2 : Node_number
        H = [H; 2*(X(i,1)-X(1,1)), 2*(X(i,2)-X(1,2))];
        b = [b; Z(1)^2 - Z(i)^2 + Node(i).D - Node(1).D]; 
    end
    
    Estimate = inv(H'*H)*H'*b;
    Est_Target.x = Estimate(1); 
    Est_Target.y = Estimate(2); 
    
    % 5. 计算本次估计位置和真实位置的误差，并存入数组
    [Error_Dist, d2] = DIST(Est_Target, Target);
    error_array(run) = Error_Dist; 
    
end

% ====== 1000次循环结束，开始进行数据统计与可视化 ======

% 1. 计算这 1000 次的平均误差
mean_error = mean(error_array);

% 在命令行窗口打印出结果
fprintf('蒙特卡洛模拟 %d 次完成！\n', num_runs);
fprintf('算法的平均定位误差为: %.4f 米\n', mean_error);

% 2. 画出误差分布的直方图（统计图表）
figure;
% 将这1000个误差值分成50个柱子进行统计
histogram(error_array, 50, 'FaceColor', '#4DBEEE', 'EdgeColor', 'k'); 
xlabel('定位误差 (米)', 'FontSize', 12);
ylabel('出现次数 (频数)', 'FontSize', 12);
title(['基于测距的最小二乘法误差分布 (共 ', num2str(num_runs), ' 次)'], 'FontSize', 14);
grid on; % 打开网格线辅助查看
set(gcf, 'Color', 'w'); % 背景设为白色

% 在图上画一条红色的虚线，标出平均误差的位置
hold on;
xline(mean_error, 'r--', ['平均误差: ', num2str(mean_error, '%.2f'), 'm'], 'LineWidth', 2, 'LabelVerticalAlignment', 'top');