function results = MAIN_compare_xy(varargin)
%MAIN_COMPARE_XY 同时运行 PPT 结构的 MAIN_x 和 MAIN_y，组合并保存结果。
% 直接运行 MAIN_compare_xy，显示组合图并导出数值、PNG、PDF、FIG。
% results = MAIN_compare_xy('Visible','off') 可用于后台运行。
% results = MAIN_compare_xy('MakeFigure',false,'SaveOutputs',false) 只计算。
% 此函数不清空工作区、不关闭原有图窗，也不修改 MATLAB 搜索路径。
parser = inputParser;
addParameter(parser,'Visible','on',@(v) any(strcmp(v,{'on','off'})));
addParameter(parser,'SaveOutputs',true,@(v) islogical(v) && isscalar(v));
addParameter(parser,'MakeFigure',true,@(v) islogical(v) && isscalar(v));
root = fileparts(mfilename('fullpath'));
addParameter(parser,'OutputDirectory',fullfile(root,'五算法定位曲线输出'), ...
    @(v) ischar(v) || (isstring(v) && isscalar(v)));
parse(parser,varargin{:});
options = parser.Results;
fprintf('读取 70 个训练点、20 个测试点，运行五算法 X/Y 坐标估计。\n');
xResult = MAIN_x('MakeFigure',false);
yResult = MAIN_y('MakeFigure',false);
results.algorithmNames = xResult.algorithmNames;
results.coordinateNames = {'X','Y'};
results.parameters = [xResult.parameters,yResult.parameters];
results.data = xResult.data;
results.iteration = (1:size(xResult.MSE,1))';
results.mse = cat(3,xResult.MSE,yResult.MSE);
results.variance = cat(3,xResult.VAR,yResult.VAR);
results.mseDb = cat(3,xResult.Curve,yResult.Curve);
results.predictionHistory = cat(4,xResult.predictionHistory,yResult.predictionHistory);
results.finalPredictions = cat(3,xResult.y_est_final,yResult.y_est_final);
results.models = [xResult.models,yResult.models];
results.elapsedSeconds = [xResult.elapsedSeconds,yResult.elapsedSeconds];
results.reference = '定位/室内定位的核自适应滤波方法-全.pptx，第 53–65 页';
results.structure = 'MAIN_x/MAIN_y 调用五个独立 handle 算法类';
results.metric = '每训练一个样本后，在固定 20 个测试点上计算 MSE；dB=10*log10(MSE)';
for c = 1:2
    fprintf('\n%s 坐标最终测试误差：\n',results.coordinateNames{c});
    for a = 1:5
        fprintf('%-7s MSE = %.8f, dB = %.6f\n',results.algorithmNames{a}, ...
            results.mse(end,a,c),results.mseDb(end,a,c));
    end
end
figures = gobjects(0);
if options.MakeFigure
    figures = plot_results(results,options.Visible);
end
if options.SaveOutputs
    save_results(results,figures,options.OutputDirectory);
    fprintf('\n输出目录：%s\n',options.OutputDirectory);
end
% 单坐标图用于导出，交互运行只显示组合图。
if numel(figures)>1
    close(figures(2:end));
end
end
