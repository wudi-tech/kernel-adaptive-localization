function [result,figureHandle] = MAIN_x(varargin)
% X 坐标估计
% 直接运行 MAIN_x。算法对象接口为 initial_p / train / evaluate / model。
% 函数包装用于返回结果，不清空工作区或关闭已有图窗。
parser = inputParser;
addParameter(parser,'MakeFigure',true,@(v) islogical(v) && isscalar(v));
addParameter(parser,'Visible','on',@(v) any(strcmp(v,{'on','off'})));
parse(parser,varargin{:});
options = parser.Results;

%% Prepare Data：读取定位数据
root = fileparts(mfilename('fullpath'));
train = readmatrix(fullfile(root,'辅助文件','11.xlsx'));
test = readmatrix(fullfile(root,'辅助文件','22.xlsx'));
assert(isequal(size(train),[70 5]) && isequal(size(test),[20 5]), ...
    'KAF:DataShape','训练表应为 70×5，测试表应为 20×5。');
assert(all(isfinite(train(:))) && all(isfinite(test(:))), ...
    'KAF:Data','数据必须全部为有限数值。');

inputDimension = 3;
[trainSize,~] = size(train);
[testSize,~] = size(test);
trainInput = zeros(inputDimension,trainSize);
for k = 1:trainSize
    trainInput(:,k) = train(k,3:3+inputDimension-1)';
end

indices = load(fullfile(root,'辅助文件','A.mat'),'A');
A = indices.A(:)';
assert(isequal(sort(A),1:trainSize),'KAF:Order','A 必须为训练点的完整排列。');
trainInput = trainInput(:,A);

testInput = zeros(inputDimension,testSize);
for k = 1:testSize
    testInput(:,k) = test(k,3:3+inputDimension-1)';
end

trainTarget_x = train(A,1);
testTarget_x = test(:,1);
trainTarget_y = train(A,2);
testTarget_y = test(:,2);
[n_train,~] = size(trainInput');
[n_test,~] = size(testInput');

% PPT 中 label_x=1 为 X 坐标，label_x=0 为 Y 坐标。
label_x = 1;
if label_x==1
    X_train = trainInput';
    y_train = trainTarget_x;
    X_test = testInput';
    y_test = testTarget_x;
else
    X_train = trainInput';
    y_train = trainTarget_y;
    X_test = testInput';
    y_test = testTarget_y;
end

%% Select algorithms：按 PPT 参数创建五个独立算法对象
algos = {};
i = 1;
algos{i} = KRLS(struct('M',Inf,'kerneltype','gauss', ...
    'sigma',13.07947,'gam',0.00212960)); i = i+1;
algos{i} = KLMS(struct('M',Inf,'kerneltype','gauss', ...
    'eta',0.259831,'sigma',31.39544)); i = i+1;
algos{i} = FrKLMS(struct('M',Inf,'kerneltype','gauss', ...
    'sigma',25.50261,'eta',0.354802,'p',1.225162)); i = i+1;
algos{i} = FrKRLS(struct('M',Inf,'kerneltype','gauss', ...
    'sigma',51.96353,'gam',0.00286774,'alpha',0.638342)); i = i+1;
algos{i} = KRGMC(struct('M',Inf,'kerneltype','gauss', ...
    'ker',4.53452,'p',2.29169,'sigma',78.35636,'gam',1.10139e-4));

%% Run Algorithms：逐点训练，并在固定测试集上评估
n_algos = length(algos);
MSE = zeros(n_train,n_algos);
VAR = zeros(n_train,n_algos);
final_mse = zeros(1,n_algos);
y_est_final = zeros(n_test,n_algos);
predictionHistory = zeros(n_test,n_train,n_algos);
titles = cell(n_algos,1);
parameters = cell(n_algos,1);
models = cell(n_algos,1);
elapsedSeconds = zeros(n_algos,1);

for j = 1:n_algos
    total_train_time = 0;
    kaf = algos{j};
    titles{j} = upper(class(kaf));
    parameterNames = {'sigma','gam','eta','p','ker','M','kerneltype'};
    params = struct;
    for k = 1:numel(parameterNames)
        name = parameterNames{k};
        if isprop(kaf,name)
            params.(name) = kaf.(name);
        end
    end
    if isa(kaf,'FrKRLS')
        params.alpha = kaf.alpha;
    end
    parameters{j} = params;
    fprintf('训练 X 坐标 %s',titles{j});

    for i = 1:n_train
        if ~mod(i,max(1,floor(n_train/10)))
            fprintf('.');
        end
        timer = tic;
        if i==1
            kaf.initial_p(X_train(i,:),y_train(i));
        else
            kaf.train(X_train(i,:),y_train(i));
        end
        total_train_time = total_train_time+toc(timer);
        y_est = kaf.evaluate(X_test);
        VAR(i,j) = var(y_test-y_est);
        MSE(i,j) = mean((y_test-y_est).^2);
        predictionHistory(:,i,j) = y_est;
        assert(isfinite(MSE(i,j)) && MSE(i,j)>=0, ...
            'KAF:NumericalFailure','%s 在第 %d 步出现非有限误差。',titles{j},i);
    end

    elapsedSeconds(j) = total_train_time;
    y_est_final(:,j) = y_est;
    final_mse(j) = MSE(end,j);
    [dict,weight] = kaf.model;
    centers = dict;
    inverse = [];
    gain = zeros(n_train,1);
    if isprop(kaf,'P')
        inverse = kaf.P;
    end
    if isa(kaf,'FrKRLS')
        centers = kaf.dictAlpha;
        gain = diag(kaf.G);
    elseif isa(kaf,'KRGMC')
        gain = kaf.g;
    end
    models{j} = struct('centers',centers,'rawDictionary',dict, ...
        'coefficients',weight,'gain',gain,'inverse',inverse, ...
        'parameters',params,'algorithm',class(kaf));
    fprintf(' 完成，MSE = %.8f\n',final_mse(j));
end

%% Convert MSE to dB：直接转换真实测试误差
Curve = 10*log10(max(MSE,realmin('double')));

%% Plot learning curves：与 PPT 相同的逐算法绘图
figureHandle = gobjects(0);
if options.MakeFigure
    figureHandle = figure('Color','w','Name','X 坐标估计', ...
        'Position',[150 150 760 610],'Visible',options.Visible);
    hold on;
    grid on;
    for j = 1:n_algos
        plot(1:n_train,Curve(:,j),'LineWidth',2.2);
    end
    title('Learning curves');
    xlabel('Iteration');
    ylabel('MSE (dB)');
    legend(titles,'Interpreter','none','Location','northeast');
    xlim([0 n_train]);
    ylim([floor(min(Curve(:))/2)*2,ceil(max(Curve(:))/2)*2]);
    set(gca,'FontName','Arial','FontSize',14);
    box on;
    hold off;
end

%% 返回主函数中计算的数据，便于组合显示和保存
result.coordinate = 'X';
result.algorithmNames = {'KRLS','KLMS','FrKLMS','FrKRLS','KRGMC'};
result.titles = titles;
result.MSE = MSE;
result.VAR = VAR;
result.Curve = Curve;
result.final_mse = final_mse;
result.y_est_final = y_est_final;
result.predictionHistory = predictionHistory;
result.parameters = parameters;
result.models = models;
result.elapsedSeconds = elapsedSeconds;
result.data = struct('trainInput',X_train,'trainTargets',[trainTarget_x trainTarget_y], ...
    'testInput',X_test,'testTargets',[testTarget_x testTarget_y],'order',A(:), ...
    'sourceFiles',{{fullfile(root,'辅助文件','11.xlsx'), ...
    fullfile(root,'辅助文件','22.xlsx'),fullfile(root,'辅助文件','A.mat')}});
end

