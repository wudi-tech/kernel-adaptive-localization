% Fractional LMS algorithm
classdef Fr_lms_r < handle

    properties (GetAccess = 'public', SetAccess = 'private')
        M = [];             % maximum dictionary size
        eta = [];           % step size
        alpha = 0.8;        % fractional order, usually 0 < alpha <= 1
    end

    properties (GetAccess = 'public', SetAccess = 'private')
        dict = [];          % dictionary
        weightVector = [];  % expansion coefficients
    end

    methods
        function kaf = Fr_lms_r(parameters)
            if nargin > 0
                for fn = fieldnames(parameters)'
                    if ismember(fn, fieldnames(kaf))
                        kaf.(fn{1}) = parameters.(fn{1});
                    end
                end
            end
        end

        function y_est = evaluate(kaf, x)
            if size(kaf.dict, 1) > 0
                y_est = (kaf.weightVector' * x')';
            else
                y_est = zeros(size(x, 1), 1);
            end
        end

        function initial_p(kaf,x,y)
            u = x(:);
            y_est = kaf.evaluate(x);
            err = y - y_est; %instantaneous error
            kaf.dict = [kaf.dict;x];%add base to dictionary
            kaf.weightVector = zeros(size(x,2),1);
            kaf.weightVector = kaf.weightVector +2* kaf.eta/gamma(3-kaf.alpha).*abs(err)^(2-kaf.alpha).*sign(err).*sign(u).*abs(u).^kaf.alpha;
        end

        function train(kaf,x,y)%train the algorithm
            if (size(kaf.dict,1) < kaf.M)% avoid infinite growth
                u = x(:);
                y_est = kaf.evaluate(x);
                err = y-y_est;%instantaneous error
                kaf.dict = [kaf.dict ;x];%add base to dictionary
                kaf.weightVector = kaf.weightVector +2* kaf.eta/gamma(3-kaf.alpha).*abs(err)^(2-kaf.alpha).*sign(err).*sign(u).*abs(u).^kaf.alpha;
            end
        end 
    end

end
