classdef KRLS < handle
    % PPT 第 25–29 页的递推，接口与其他核自适应滤波类相同。
    properties (GetAccess = public, SetAccess = private)
        sigma = 10;
        gam = 0.01;
        M = Inf;
        kerneltype = 'gauss';
        dict = [];
        theta = [];
        P = [];
        H = [];
        jitter = 1e-12;
    end
    methods
        function kaf = KRLS(parameters)
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
            kaf.P = 1/(kaf.gam+1);
            kaf.theta = kaf.P*y(1);
        end

        function y_est = evaluate(kaf,x)
            if ~isempty(kaf.dict)
                kaf.H = kernel(kaf.dict,x,kaf.kerneltype,kaf.sigma);
                y_est = kaf.H'*kaf.theta;
            else
                y_est = zeros(size(x,1),1);
            end
        end

        function train(kaf,x,y)
            if size(kaf.dict,1)<kaf.M
                y_est = kaf.evaluate(x);
                err = y(1)-y_est;
                z = kaf.P*kaf.H;
                r = kaf.gam+1-kaf.H'*z;
                assert(isfinite(r) && r>0,'KRLS:Denominator','KRLS 递推分母必须为正且有限。');
                r = max(r,kaf.jitter);
                kaf.P = [kaf.P+z*z'/r,-z/r;-z'/r,1/r];
                kaf.theta = [kaf.theta-z*err/r;err/r];
                kaf.dict = [kaf.dict;x(:)'];
            end
        end

        function [dict,weight] = model(kaf)
            dict = kaf.dict;
            weight = kaf.theta;
        end
    end
end
