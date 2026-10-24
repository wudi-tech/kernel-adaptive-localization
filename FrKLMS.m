classdef FrKLMS < handle
    % 按 PPT 第 53 页：原始输入字典、分数阶误差更新。
    properties (GetAccess = public, SetAccess = private)
        p = 1.6;
        eta = 0.35;
        M = Inf;
        kerneltype = 'gauss';
        sigma = 14;
        dict = [];
        alpha = [];
        k = [];
    end
    methods
        function kaf = FrKLMS(parameters)
            if nargin>0
                names = fieldnames(parameters);
                for i = 1:numel(names)
                    if isprop(kaf,names{i})
                        kaf.(names{i}) = parameters.(names{i});
                    end
                end
            end
        end

        function initial_p(kaf,x,y)
            err = y(1);
            kaf.dict = x(:)';
            stepeta = kaf.eta/gamma(3-kaf.p);
            kaf.alpha = stepeta*abs(err)^(2-kaf.p)*sign(err);
        end

        function y_est = evaluate(kaf,x)
            if ~isempty(kaf.dict)
                kaf.k = kernel(kaf.dict,x,kaf.kerneltype,kaf.sigma);
                y_est = kaf.k'*kaf.alpha;
            else
                y_est = zeros(size(x,1),1);
            end
        end

        function train(kaf,x,y)
            if size(kaf.dict,1)<kaf.M
                y_est = kaf.evaluate(x);
                err = y(1)-y_est;
                kaf.dict = [kaf.dict; x(:)'];
                stepeta = kaf.eta/gamma(3-kaf.p);
                kaf.alpha = [kaf.alpha; stepeta*abs(err)^(2-kaf.p)*sign(err)];
            end
        end

        function [dict,weight] = model(kaf)
            dict = kaf.dict;
            % PPT 此处写成 theta，但该类实际保存的系数是 alpha。
            weight = kaf.alpha;
        end
    end
end
