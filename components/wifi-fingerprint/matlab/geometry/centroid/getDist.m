function d = getDist(p1, p2)
    % getDist 计算两点之间的欧氏距离
    % 输入: 
    %   p1, p2 - 包含字段 x 和 y 的结构体 (例如 Target.x, Target.y)
    % 输出:
    %   d - 欧氏距离
    
    dx = p1.x - p2.x;
    dy = p1.y - p2.y;
    
    d = sqrt(dx^2 + dy^2);
end