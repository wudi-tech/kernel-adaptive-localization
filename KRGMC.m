classdef KRGMC < handle
    % 按 PPT 第 57 页：高斯输入核与广义相关熵误差权重。
    properties (GetAccess = public, SetAccess = private)
        sigma = 10;
        ker = 2;
        p = 2;
        gam = 0.01;
        M = Inf;
        kerneltype = 'gauss';
        dict = [];
        theta = [];
        P = [];
        H = [];
        g = [];
        jitter = 1e-12;
    end
    methods
        function kaf = KRGMC(parameters)
            if nargin>0
                names = fieldnames(parameters);
                for i = 1:numel(names)
                    if isprop(kaf,names{i})
                        kaf.(names{i}) = parameters.(names{i});
                    end
                end
            end
        end

        function y_est = evaluate(kaf,x)
            if ~isempty(kaf.dict)
                kaf.H = kernel(kaf.dict,x,kaf.kerneltype,kaf.sigma);
                y_est = kaf.H'*kaf.theta;
            else
                y_est = zeros(size(x,1),1);
            end
        end

        function initial_p(kaf,x,y)
            err = y(1);
            G = kaf.error_gain(err);
            % 等价于 PPT 的 (gam/G+1)^(-1)，同时允许 G=0。
            kaf.P = G/(kaf.gam+G);
            kaf.dict = x(:)';
            kaf.theta = kaf.P*err;
            kaf.g = G;
        end

        function train(kaf,x,y)
            if size(kaf.dict,1)<kaf.M
                y_est = kaf.evaluate(x);
                err = y(1)-y_est;
                z = kaf.P*kaf.H;
                G = kaf.error_gain(err);
                % s=1/r，r=gam/G+1-z'*H；以下写法避免 G=0 时除零。
                denom = kaf.gam+G*(1-kaf.H'*z);
                assert(isfinite(denom) && denom>0, ...
                    'KRGMC:Denominator','KRGMC 递推分母必须为正且有限。');
                s = G/max(denom,kaf.jitter);
                kaf.P = [kaf.P+s*(z*z'),-s*z;-s*z',s];
                kaf.dict = [kaf.dict;x(:)'];
                kaf.theta = [kaf.theta-s*z*err;s*err];
                kaf.g = [kaf.g;G];
            end
        end

        function [dict,weight] = model(kaf)
            dict = kaf.dict;
            weight = kaf.theta;
        end
    end
    methods (Access = private)
        function G = error_gain(kaf,err)
            ae = abs(err);
            if ae==0 && kaf.p<2
                ae = kaf.jitter;
            end
            G = kaf.p*ae^(kaf.p-2)/(2*kaf.ker^2)* ...
                exp(-ae^kaf.p/(2*kaf.ker^2));
            assert(isfinite(G) && G>=0,'KRGMC:Gain','相关熵权重必须非负且有限。');
        end
    end
end
