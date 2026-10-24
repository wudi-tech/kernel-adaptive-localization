% Fractional RLS algorithm
classdef Fr_rls_r < handle

    properties (GetAccess = 'public',SetAccess ='private')
        gam = [];
        M=[];               % maximum dictionary size
        alpha = 1;
        pInitial = 1;
    end

    properties (GetAccess = 'public',SetAccess ='private')
        dict =[];           % dictionary
        weightVector =[];   % expansion coefficients
        P=[];
        IGamma=[];
        gamma=[];
        gain=[];
        gaink=[];
    end

    methods
        function kaf = Fr_rls_r(parameters)%contrustor
            if(nargin>0)%copy valid parameters
                for fn = fieldnames(parameters)'
                    if ismember(fn,fieldnames(kaf))
                        kaf.(fn{1}) = parameters.(fn{1});
                    end
                end
            end
        end

        function y_est = evaluate(kaf,x)% evaluate the algorithm
            if size(kaf.dict,1) > 0
                y_est = (kaf.weightVector'*x')';
            else
                y_est = zeros(size(x,1),1);% zeros if not initialized
            end
        end

        function initial_p(kaf,x,y)
            inputDimension = size(x,2);
             kaf.P = eye(1);
%             if isscalar(kaf.pInitial)
%                 kaf.P = kaf.pInitial * eye(inputDimension);
%             else
%                 kaf.P = kaf.pInitial;
%             end
            kaf.weightVector = zeros(inputDimension,1);
            kaf.updateWeight(x,y);
            kaf.dict = [kaf.dict;x];
        end

        function train(kaf,x,y)%train the algorithm
            if(size(kaf.dict,1)<kaf.M)% avoid infinite growth
                kaf.updateWeight(x,y);
                kaf.dict = [kaf.dict ; x]; %add base to dictionary
            end
        end
    end

    methods (Access = private)
        function updateWeight(kaf,x,y)
            u = x(:);
            v = sign(u) .* abs(u).^kaf.alpha;

            y_est = kaf.evaluate(x);
            error = y-y_est;%instantaneous error
            g = abs(error)^(1-kaf.alpha);

            if g == 0
                kaf.IGamma = Inf;
                kaf.gamma = 0;
                kaf.gain = zeros(size(u));
                kaf.gaink = zeros(size(u));
                return
            else
                kaf.IGamma = 1/g + u'*kaf.P*v;
                kaf.gamma = 1/kaf.IGamma;
            end

            kaf.gain = kaf.P*u*kaf.gamma;
            kaf.gaink = kaf.P*v*kaf.gamma;
            kaf.weightVector = kaf.weightVector + kaf.gain*error;
            kaf.P = kaf.P - kaf.gaink*kaf.gain'*kaf.IGamma;
        end
    end
end
