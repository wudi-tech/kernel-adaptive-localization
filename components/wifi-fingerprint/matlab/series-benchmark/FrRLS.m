function [weightVector,learningCurve]= ...
    FrRLS(trainInput,trainTarget,testInput,testTarget,pInitial,alpha,flagLearningCurve)

[inputDimension,trainSize] = size(trainInput);

learningCurve = zeros(trainSize,1);

weightVector = zeros(inputDimension,1);

P = pInitial;

% training
for n = 1:trainSize
    u = trainInput(:,n);
    v = sign(trainInput(:,n)) .*abs(trainInput(:,n)).^alpha;
    error = trainTarget(n) - u'*weightVector;
    g = abs(error)^(1-alpha);
    iGamma = 1/g+u'*P*v;
    gamma = 1/iGamma;
    gain = P*u*gamma;
    gaink = P*v*gamma;
%     error = trainTarget(n) - u'*weightVector;
    weightVector = weightVector + gain*error;
    P = P - gaink*gain'*iGamma;

%     learningCurve(n) = error^2;
     if flagLearningCurve
        % testing
        err = testTarget -(testInput'*weightVector);
        learningCurve(n) = mean(err.^2);
    end
end

return