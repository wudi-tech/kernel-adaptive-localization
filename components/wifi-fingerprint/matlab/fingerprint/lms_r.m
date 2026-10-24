% LMS 算法实现
classdef lms_r < handle

    properties (GetAccess = 'public',SetAccess ='private')
        M = [];% maximum dictionary size
        eta = [];
    end

    properties(GetAccess = 'public',SetAccess ='private')
        dict = [];% dictionary
        weightVector =[]; %expansion coefficients
    end

    methods
        function kaf =lms_r(parameters)%constructor
            if (nargin > 0)%copy valid parameters
                for fn = fieldnames(parameters)'
                    if ismember(fn,fieldnames(kaf))
                        kaf.(fn{1}) = parameters.(fn{1});
                    end
                end
            end
        end


        function y_est = evaluate(kaf,x)%evaluate the algorithm
            if size(kaf.dict,1)>0
                y_est = (kaf.weightVector'*x')';
            else
                y_est = (zeros(size(x,1),1))';%zeros fi not initialized
            end

        end
        
        function initial_p(kaf,x,y)
            y_est = kaf.evaluate(x);
            err = y - y_est; %instantaneous error
            kaf.dict = [kaf.dict;x];%add base to dictionary
            kaf.weightVector = zeros(size(x,2),1);
            kaf.weightVector = kaf.weightVector + kaf.eta * err.* x'; %add new coefficient
        end

        function train(kaf,x,y)%train the algorithm
            if (size(kaf.dict,1) < kaf.M)% avoid infinite growth
                y_est = kaf.evaluate(x);
                err = y-y_est;%instantaneous error
                kaf.dict = [kaf.dict ;x];%add base to dictionary
                kaf.weightVector = kaf.weightVector + kaf.eta * err.* x'; %add new coefficient
            end
        end 
    end
end



