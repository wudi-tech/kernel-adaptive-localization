function test_xy_learning_curves(varargin)
% 默认只使用代码内的微型合成数据；课程数据与历史基线不随仓库分发。
parser = inputParser;
addParameter(parser,'RunCourseExperiment',false,@(v) islogical(v) && isscalar(v));
addParameter(parser,'BaselineFile','',@(v) ischar(v) || isstring(v));
parse(parser,varargin{:});
options = parser.Results;
root = fileparts(fileparts(mfilename('fullpath')));
oldPath = path;
cleanup = onCleanup(@() path(oldPath));
addpath(root,'-begin');
test_ppt_class_structure;
X = [0.1 0.3;0.4 0.2;0.8 0.7;0.5 0.9];
y = [0.8;1.2;-0.4;0.6];
Xt = [0.2 0.4;0.6 0.5;0.9 0.1];
yt = [0.7;-0.1;0.4];
p = struct('sigma',0.8,'gam',0.07,'eta',0.2, ...
    'p',1,'alpha',1,'ker',1.4,'M',Inf,'kerneltype','gauss');
[~,predictions] = run_filter(KRLS(p),X,y,Xt,yt);
for n = 1:numel(y)
    K = independent_kernel(X(1:n,:),X(1:n,:),p.sigma);
    expected = independent_kernel(Xt,X(1:n,:),p.sigma)* ...
        ((K+p.gam*eye(n))\y(1:n));
    assert(max(abs(predictions(:,n)-expected))<1e-9,'KRLS 与直接解不一致。');
end
[~,ordinaryLms] = run_filter(KLMS(p),X,y,Xt,yt);
[~,fractionalLms] = run_filter(FrKLMS(p),X,y,Xt,yt);
assert(max(abs(ordinaryLms(:)-fractionalLms(:)))<1e-9, ...
    'FrKLMS 的 p=1 未退化为 KLMS。');
[~,fractionalRls] = run_filter(FrKRLS(p),X,y,Xt,yt);
assert(max(abs(predictions(:)-fractionalRls(:)))<1e-9, ...
    'FrKRLS 的 alpha=1 未退化为 KRLS。');
p.alpha = 0.8;
fractionalModel = FrKRLS(p);
[~,fractionalPredictions] = run_filter(fractionalModel,X,y,Xt,yt);
for n = 1:numel(y)
    centers = abs(X(1:n,:)).^p.alpha.*sign(X(1:n,:));
    H = independent_kernel(X(1:n,:),centers,p.sigma);
    G = fractionalModel.G(1:n,1:n);
    coefficients = (p.gam*eye(n)+G*H)\(G*y(1:n));
    expected = independent_kernel(Xt,centers,p.sigma)*coefficients;
    assert(max(abs(fractionalPredictions(:,n)-expected))<1e-9, ...
        'FrKRLS 与非对称加权核的直接解不一致。');
end
p.p = 2.3;
robustModel = KRGMC(p);
[mse,robustPredictions] = run_filter(robustModel,X,y,Xt,yt);
for n = 1:numel(y)
    K = independent_kernel(X(1:n,:),X(1:n,:),p.sigma);
    coefficients = (K+p.gam*diag(1./robustModel.g(1:n)))\y(1:n);
    expected = independent_kernel(Xt,X(1:n,:),p.sigma)*coefficients;
    assert(max(abs(robustPredictions(:,n)-expected))<1e-8, ...
        'KRGMC 与固定历史权重的直接解不一致。');
end
assert(max(abs(mse-mean((yt-robustPredictions).^2,1)'))<1e-12);
[zeroMse,zeroPredictions] = run_filter(KRGMC(p),X,zeros(4,1),Xt,zeros(3,1));
assert(all(isfinite(zeroMse)) && all(zeroPredictions(:)==0));
% evaluate 会缓存核向量。每次 train 必须先用当前训练输入刷新缓存。
limitedParams = p;
limitedParams.M = 2;
limited = KRLS(limitedParams);
run_filter(limited,X,y,Xt,yt);
[dict,~] = limited.model;
assert(size(dict,1)==2,'M 的字典容量限制失效。');

if ~options.RunCourseExperiment
    fprintf('SYNTHETIC_NUMERICAL_TESTS=PASS; COURSE_EXPERIMENT=NOT_RUN; BASELINE=NOT_RUN\n');
    return;
end
requiredData = {fullfile(root,'辅助文件','11.xlsx'), ...
    fullfile(root,'辅助文件','22.xlsx'),fullfile(root,'辅助文件','A.mat')};
assert(all(cellfun(@isfile,requiredData)), ...
    'KAF:MissingPrivateData','课程数据不随仓库提供，请先阅读辅助文件/README.md。');
first = MAIN_compare_xy('MakeFigure',false,'SaveOutputs',false);
second = MAIN_compare_xy('MakeFigure',false,'SaveOutputs',false);
data = first.data;
assert(isequal(size(data.trainInput),[70 3]));
assert(isequal(size(data.testInput),[20 3]));
assert(isequal(sort(data.order(:)),(1:70)'));
assert(isequal(size(first.mse),[70 5 2]));
assert(isequal(size(first.finalPredictions),[20 5 2]));
assert(all(isfinite(first.mse(:))) && all(first.mse(:)>0));
assert(isequal(first.mse,second.mse),'固定数据重跑不一致。');
assert(max(abs(first.mse(:)-reshape(mean( ...
    (reshape(data.testTargets,20,1,1,2)-first.predictionHistory).^2,1),[],1)))<1e-12);
if strlength(string(options.BaselineFile))>0
    assert(isfile(options.BaselineFile),'KAF:MissingBaseline','指定的基线文件不存在。');
    baseline = load(options.BaselineFile,'results');
    maxMseDifference = max(abs(first.mse(:)-baseline.results.mse(:)));
    maxPredictionDifference = max(abs(first.predictionHistory(:)-baseline.results.predictionHistory(:)));
    assert(maxMseDifference<1e-9,'与给定基线的曲线误差超过容差。');
    assert(maxPredictionDifference<1e-9,'与给定基线的预测误差超过容差。');
    fprintf('BASELINE_MAX_MSE_DIFF=%.12g; BASELINE_MAX_PREDICTION_DIFF=%.12g\n', ...
        maxMseDifference,maxPredictionDifference);
else
    fprintf('BASELINE=NOT_RUN; 未提供私有历史基线。\n');
end

figures = plot_results(first,'off');
figureCleanup = onCleanup(@() close(figures));
axesHandles = findall(figures(1),'Type','axes');
assert(numel(axesHandles)==2);
for i = 1:numel(axesHandles)
    lines = findall(axesHandles(i),'Type','line');
    assert(numel(lines)==5);
    for j = 1:5
        assert(numel(lines(j).XData)==70 && numel(lines(j).YData)==70);
    end
end
[xResult,xFigure] = MAIN_x('Visible','off');
[yResult,yFigure] = MAIN_y('Visible','off');
singleFigureCleanup = onCleanup(@() close([xFigure,yFigure]));
assert(isequal(xResult.MSE,first.mse(:,:,1)) && isequal(yResult.MSE,first.mse(:,:,2)));
assert(numel(findall(xFigure,'Type','line'))==5 && numel(findall(yFigure,'Type','line'))==5);
fprintf('NUMERICAL_TESTS=PASS; DATA=70/20; CURVES=70x5x2; DETERMINISM=PASS; FIGURE=PASS\n');
end

function [mse,predictions] = run_filter(kaf,X,y,Xt,yt)
% 与 PPT 主函数相同的对象调用，测试中不使用合并算法分支。
N = numel(y);
predictions = zeros(numel(yt),N);
mse = zeros(N,1);
for n = 1:N
    if n==1
        kaf.initial_p(X(n,:),y(n));
    else
        kaf.train(X(n,:),y(n));
    end
    predictions(:,n) = kaf.evaluate(Xt);
    mse(n) = mean((yt-predictions(:,n)).^2);
end
end

function K = independent_kernel(a,b,sigma)
K = zeros(size(a,1),size(b,1));
for i = 1:size(a,1)
    for j = 1:size(b,1)
        K(i,j) = exp(-sum((a(i,:)-b(j,:)).^2)/(2*sigma^2));
    end
end
end
