function figures = plot_results(results,visible)
% 五条实测曲线，颜色、图例顺序和坐标范围按参考图设置。
figures = gobjects(3,1);
figures(1) = figure('Color','w','Name','X/Y 定位学习曲线', ...
    'Position',[100 100 1500 610],'Visible',visible);
layout = tiledlayout(figures(1),1,2,'TileSpacing','compact','Padding','compact');
for c = 1:2
    ax = nexttile(layout);
    draw_curve(ax,results,c);
end
for c = 1:2
    figures(c+1) = figure('Color','w', ...
        'Name',[results.coordinateNames{c},' 坐标估计'], ...
        'Position',[150 150 760 610],'Visible','off');
    ax = axes('Parent',figures(c+1));
    draw_curve(ax,results,c);
end
end

function draw_curve(ax,results,c)
colors = [0 0.4470 0.7410; 0.8500 0.3250 0.0980; ...
    0.9290 0.6940 0.1250; 0.4940 0.1840 0.5560; 0.4660 0.6740 0.1880];
hold(ax,'on');
for a = 1:5
    plot(ax,results.iteration,results.mseDb(:,a,c), ...
        'Color',colors(a,:),'LineWidth',2.2);
end
hold(ax,'off');
title(ax,['Learning curves (',results.coordinateNames{c},')']);
xlabel(ax,'Iteration');
ylabel(ax,'MSE (dB)');
legend(ax,results.algorithmNames,'Location','northeast','Interpreter','none');
xlim(ax,[0 70]);
db = results.mseDb(:,:,c);
limits = [floor(min(db(:))/2)*2,ceil(max(db(:))/2)*2];
if limits(1) == limits(2)
    limits = limits + [-1 1];
end
ylim(ax,limits);
xticks(ax,0:10:70);
grid(ax,'on');
box(ax,'on');
set(ax,'FontName','Arial','FontSize',14);
end
