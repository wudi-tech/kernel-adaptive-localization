classdef FrKRLS < handle
    % 按 PPT 第 54–56 页恢复，保留两条非对称核向量。
    properties (GetAccess = public, SetAccess = private)
        sigma = 10;
        gam = 0.01;
        alpha = 0.8;
        M = Inf;
        kerneltype = 'gauss';
        jitter = 1e-12;
        dict = [];
        dictAlpha = [];
        theta = [];
        P = [];
        G = [];
        lastError = [];
        lastG = [];
    end
    methods
        function kaf = FrKRLS(parameters)
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
            if ~isempty(kaf.dictAlpha)
                Ktest = kernel(x,kaf.dictAlpha,kaf.kerneltype,kaf.sigma);
                y_est = Ktest*kaf.theta;
            else
                y_est = zeros(size(x,1),1);
            end
        end

        function initial_p(kaf,x,y)
            x = x(:)';
            y = y(1);
            xa = kaf.frac_transform(x);
            kk = kernel(xa,x,kaf.kerneltype,kaf.sigma);
            g = kaf.frac_gain(y);
            rr = kaf.safe_den(kaf.gam+kk*g);
            kaf.P = 1/rr;
            kaf.theta = kaf.P*g*y;
            kaf.G = g;
            kaf.dict = x;
            kaf.dictAlpha = xa;
            kaf.lastError = y;
            kaf.lastG = g;
        end

        function train(kaf,x,y)
            if size(kaf.dict,1)>=kaf.M
                return;
            end
            x = x(:)';
            y = y(1);
            xa = kaf.frac_transform(x);
            Mvec = kernel(kaf.dictAlpha,x,kaf.kerneltype,kaf.sigma);
            Kvec = kernel(kaf.dict,xa,kaf.kerneltype,kaf.sigma);
            y_est = Mvec'*kaf.theta;
            err = y-y_est;
            g = kaf.frac_gain(err);
            % 与 PPT 的 P*G*Kvec 等价；先算 G*Kvec，保持原有运算顺序。
            ZG = kaf.P*(kaf.G*Kvec);
            Z = Mvec'*kaf.P;
            kk = kernel(x,xa,kaf.kerneltype,kaf.sigma);
            rr = kaf.safe_den(g*kk+kaf.gam-g*(Mvec'*ZG));
            kaf.P = [kaf.P+(g/rr)*ZG*Z,-ZG/rr;-(g/rr)*Z,1/rr];
            oldM = size(kaf.G,1);
            kaf.G = [kaf.G,zeros(oldM,1);zeros(1,oldM),g];
            kaf.theta = [kaf.theta-(g/rr)*ZG*err;(g/rr)*err];
            kaf.dict = [kaf.dict;x];
            kaf.dictAlpha = [kaf.dictAlpha;xa];
            kaf.lastError = err;
            kaf.lastG = g;
        end

        function [dict,weight] = model(kaf)
            dict = kaf.dict;
            weight = kaf.theta;
        end
    end
    methods (Access = private)
        function xa = frac_transform(kaf,x)
            xa = abs(x).^kaf.alpha.*sign(x);
        end

        function g = frac_gain(kaf,e)
            ae = max(abs(e),kaf.jitter);
            g = max(ae^(1-kaf.alpha),kaf.jitter);
        end

        function d = safe_den(kaf,d)
            assert(isreal(d) && isfinite(d), ...
                'FrKRLS:Denominator','FrKRLS 的递推分母必须为有限实数。');
            if abs(d)<kaf.jitter
                if d<0
                    d = -kaf.jitter;
                else
                    d = kaf.jitter;
                end
            end
        end
    end
end
