classdef KLMS < handle
    % 核最小均方算法，采用 PPT 的独立类和统一方法接口。
    properties (GetAccess = public, SetAccess = private)
        eta = 0.1;
        M = Inf;
        kerneltype = 'gauss';
        sigma = 10;
        dict = [];
        alpha = [];
        k = [];
    end
    methods
        function kaf = KLMS(parameters)
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
            kaf.dict = x(:)';
            kaf.alpha = kaf.eta*y(1);
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
                kaf.alpha = [kaf.alpha; kaf.eta*err];
            end
        end

        function [dict,weight] = model(kaf)
            dict = kaf.dict;
            weight = kaf.alpha;
        end
    end
end
