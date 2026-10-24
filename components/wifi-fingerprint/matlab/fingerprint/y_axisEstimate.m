%基于RSSI值的室内定位算法，应用C++类形式编写
%IOT_AI
%消掉Matlab内存残留
clc;
clear all;
close all;

%% rng函数的功能：控制随机函数的生成
rng(005); 

%% 性能指标初始化
MSE = zeros(1000,5,10);
mse = zeros(1000,5);

%% 外围参数初始化
line_r = 1;

for l = 1:1:1
    %% 指标初始化
    i=1;
    % 【修复3】使用元胞数组的花括号 {}
    algos{i} = rls_r(struct('M',Inf)); i=i+1; %RLS算法
    algos{i} = lms_r(struct('M',Inf,'eta',0.00001)); i=i+1; %LMS算法
    algos{i} = Fr_lms_r(struct('M',Inf,'eta',0.00001,'alpha',0.8)); i=i+1; %FrLMS算法
    %后续可以再这个部分设计子函数
    algos{i} = Fr_rls_r(struct('M',Inf,'alpha',1)); i=i+1; %FrRLS算法


    %% 数据准备
    train=xlsread('Database_Scenario3.xlsx','WiFi');
    test=xlsread('Tests_Scenario3.xlsx','WiFi');
    inputDimension = 3;
    
    [trainSize,~] = size(train);
    [testSize,~] = size(test);
    
    trainInput = zeros(inputDimension, trainSize);
    for k = 1:trainSize
        trainInput(:, k) = train(k, 3:3+inputDimension-1);
    end
    A = randperm(length(trainInput));
    trainInput = trainInput(:,A);
    % Input test data with embedding
    testInput = zeros(inputDimension, testSize);

    for k = 1:testSize
        testInput(:, k) = test(k, 3:3+inputDimension-1);
    end
    
    % x坐标训练信号
    trainTarget_x = zeros(trainSize, 1);
    for ii=1:trainSize
        trainTarget_x(ii) = train(ii, 1);
    end
    trainTarget_x = trainTarget_x(A);

    % x坐标测试信号
    testTarget_x = zeros(testSize, 1);
    for ii=1:testSize
        testTarget_x(ii) = test(ii, 1);
    end
    
    % y坐标训练信号
    trainTarget_y = zeros(trainSize, 1);
    for ii=1:trainSize

        trainTarget_y(ii) = train(ii, 2); 
    end
    trainTarget_y = trainTarget_y(A);

    % y坐标测试信号
    testTarget_y = zeros(testSize, 1);
    for ii=1:testSize
        testTarget_y(ii) = test(ii, 2); 
    end
    
    [n_train, ~] = size(trainInput'); % 训练数据规模
    [n_test,L] = size(testInput');  % 测试数据规模
    
    label_x = 0;
    if(label_x==1)
        X_train = trainInput' ;
        y_train = trainTarget_x;
        X_test = testInput' ;
        y_test = testTarget_x;
    else
        X_train = trainInput' ;
        y_train = trainTarget_y;
        X_test = testInput' ;
        y_test = testTarget_y;        
    end

    %% RUN ALGORITHMS
    n_algos = length(algos);

    y_est_final = zeros(n_test,n_algos);
    titles = cell(n_algos,1);

    for j = 1:n_algos
        tic
        kaf = algos{j};
        titles{j} = upper(class(kaf));%store algorithm name
        fprintf('Training %s', titles{j});
        for i=1:n_train
            if ~mod(i,floor(n_train/10)), fprintf('.'); end %progress indicator
            if i==1
                kaf.initial_p(X_train(i,:),y_train(i));
            else
                kaf.train(X_train(i,:),y_train(i));% train with one input-output pair
            end
            y_est = kaf.evaluate(X_test); %evaluate on test data
            a=1;
            MSE(i,j,l) = mean((y_test - y_est).^2) ;%test error
            VAR(i,j) = var((y_test - y_est));
        end
        fprintf('\n');
        y_est_final(:,j) = y_est;
        toc
    end
    mse = sum(MSE,3)./l;
end

%%绘图，打印均方误差MSE(dB)
figure(1);
plot(10*log10(mse(:,1)),'linestyle','-.','LineWidth',3);
hold on 
plot(10*log10(mse(:,2)),'linestyle','-','LineWidth',3,'color',[0.9 0.1 0.1]);
plot(10*log10(mse(:,3)),'linestyle','--','LineWidth',3,'color',[0.1 0.45 0.9]);
plot(10*log10(mse(:,4)),'linestyle','--','LineWidth',3,'color',[0.5 0.45 0.6]);
grid on 
title(sprintf('learning Curves for y-axis prediction'))
legend('RLS','LMS','FrLMS','FrRLS');
xlabel('Iteration');
ylabel('MSE dB');
% fprintf('Final MSE: %2fdB\n\n',10*log10(MSE(end)));
% min(mse(40,:));
set(gcf,'color','w')

