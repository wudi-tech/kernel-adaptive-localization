% RLS algorithm
classdef rls_r < handle

    properties (GetAccess = 'public',SetAccess ='private')
        gam = [];
        M=[]% maximum dictionary size
    end

    properties (GetAccess = 'public',SetAccess ='private')
        dict =[];%dictionary
        weightVector =[];%expansion coefficients
        P=[];
        IGamma=[];
        gamma=[];
        gain=[];
    end

    methods
        function kaf = rls_r(parameters)%contrustor
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
                y_est = (zeros(size(x,1),1))';% zeros if not initialized
            end
        end

        function initial_p(kaf,x,~)
            kaf.P = eye(1);
            kaf.IGamma = 1 + x*kaf.P*x';
            kaf.gamma = 1/kaf.IGamma;
            kaf.gain = kaf.P * x *kaf.gamma;
            kaf.dict = [kaf.dict;x];
            kaf.weightVector = zeros(length(x),1);
        end

        
        function train(kaf,x,y)%train the algorithm
            if(size(kaf.dict,1)<kaf.M)% avoid infinite growth
                kaf.IGamma = 1 + x*kaf.P*x';
                kaf.gamma = 1/kaf.IGamma;
                kaf.gain = kaf.P * x *kaf.gamma;
                y_est = kaf.evaluate(x);
                error = y-y_est;%instantaneous error
                kaf.weightVector = kaf.weightVector + (kaf.gain * error)';
                kaf.P = kaf.P - kaf.gain * kaf.gain' * kaf.IGamma;
                kaf.dict = [kaf.dict ; x]; %add base to dictionary
            end
        end

    end
end


