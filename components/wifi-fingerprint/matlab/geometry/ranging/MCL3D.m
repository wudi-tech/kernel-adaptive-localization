clear all;
close all;

Length = 100;
Width = 100;
Hight = 100;     % 保持原图拼写
Node_number = 5; % 注意：幻灯片里把节点数降到了5个
num_runs = 1000; % 蒙特卡洛模拟次数

error_array = zeros(1, num_runs);

for run = 1 : num_runs
    % 1. 每次重新随机撒下5个观测站
    for i = 1:Node_number
        Node(i).x = Width*rand;
        Node(i).y = Length*rand;
        Node(i).z = Hight*rand;
        Node(i).D = Node(i).x^2 + Node(i).y^2 + Node(i).z^2;
    end
    
    % 2. 重新随机生成目标的三维坐标
    Target.x = Width*rand;
    Target.y = Length*rand;
    Target.z = Hight*rand;
    
    % 3. 模拟测距并加入噪声
    X = []; Z = [];
    for i = 1:Node_number
        [d1, d2] = DIST3(Node(i), Target);
        d1 = d1 + sqrt(5)*randn; 
        X = [X; Node(i).x, Node(i).y, Node(i).z];
        Z = [Z, d1];
    end
    
    % 4. 构建矩阵求解 (超定方程组)
    H = []; b = [];
    for i = 2:Node_number
        H = [H; 2*(X(i,1)-X(1,1)), 2*(X(i,2)-X(1,2)), 2*(X(i,3)-X(1,3))];
        b = [b; Z(1)^2 - Z(i)^2 + Node(i).D - Node(1).D];
    end
    
    Estimate = inv(H'*H)*H'*b;
    Est_Target.x = Estimate(1);
    Est_Target.y = Estimate(2);
    Est_Target.z = Estimate(3);
    
    % 5. 计算三维空间误差
    [Error_Dist, ~] = DIST3(Est_Target, Target);
    error_array(run) = Error_Dist;
end

% ====== 可视化与统计 ======
mean_error = mean(error_array);
fprintf('三维空间蒙特卡洛模拟 %d 次完成！\n', num_runs);
fprintf('算法的平均定位误差为: %.4f 米\n', mean_error);

figure;
% 换个颜色区分一下二维和三维的图表
histogram(error_array, 50, 'FaceColor', '#D95319', 'EdgeColor', 'k'); 
xlabel('三维空间定位误差 (米)', 'FontSize', 12);
ylabel('出现次数 (频数)', 'FontSize', 12);
title(['基于测距的三维最小二乘法误差分布 (共 ', num2str(num_runs), ' 次)'], 'FontSize', 14);
grid on;
set(gcf, 'Color', 'w');
hold on;
xline(mean_error, 'r--', ['平均误差: ', num2str(mean_error, '%.2f'), 'm'], 'LineWidth', 2, 'LabelVerticalAlignment', 'top');