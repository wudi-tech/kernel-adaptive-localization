function save_results(results,figures,outputDirectory)
% 保存全量原始 MSE、每步测试预测、模型及可编辑图形。
if ~isfolder(outputDirectory)
    mkdir(outputDirectory);
end
save(fullfile(outputDirectory,'results.mat'),'results');
names = results.algorithmNames;
summaryCoordinate = cell(10,1);
summaryAlgorithm = cell(10,1);
finalMse = zeros(10,1);
finalDb = zeros(10,1);
elapsedSeconds = zeros(10,1);
for c = 1:2
    coord = results.coordinateNames{c};
    curve = array2table([results.iteration,results.mse(:,:,c),results.mseDb(:,:,c)], ...
        'VariableNames',[{'Iteration'},strcat(names,'_MSE'),strcat(names,'_dB')]);
    writetable(curve,fullfile(outputDirectory,['learning_curve_',coord,'.csv']));
    predictions = array2table([(1:20)',results.data.testTargets(:,c), ...
        results.finalPredictions(:,:,c)],'VariableNames',[{'TestPoint','Target'},names]);
    writetable(predictions,fullfile(outputDirectory,['predictions_',coord,'.csv']));
    rows = (c-1)*5+(1:5);
    summaryCoordinate(rows) = repmat({coord},5,1);
    summaryAlgorithm(rows) = names';
    finalMse(rows) = results.mse(end,:,c)';
    finalDb(rows) = results.mseDb(end,:,c)';
    elapsedSeconds(rows) = results.elapsedSeconds(:,c);
end
summary = table(summaryCoordinate,summaryAlgorithm,finalMse,finalDb,elapsedSeconds, ...
    'VariableNames',{'Coordinate','Algorithm','FinalMSE','FinalMSE_dB','ElapsedSeconds'});
writetable(summary,fullfile(outputDirectory,'summary.csv'));
for i = 1:numel(figures)
    if i == 1
        stem = 'learning_curves_XY';
    else
        stem = ['learning_curve_',results.coordinateNames{i-1}];
    end
    exportgraphics(figures(i),fullfile(outputDirectory,[stem,'.png']),'Resolution',180);
    exportgraphics(figures(i),fullfile(outputDirectory,[stem,'.pdf']),'ContentType','vector');
    savefig(figures(i),fullfile(outputDirectory,[stem,'.fig']));
end
end
