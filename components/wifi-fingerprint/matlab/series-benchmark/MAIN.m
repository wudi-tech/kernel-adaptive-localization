% 1-step ahead prediction on Mackey Glass time series.
%
clear
clc
clear all
close all; clear;
MSE = zeros(1000,5,10);
mse = zeros(1000,5);

for MC=1:1
    disp(['Please wait...',num2str(MC),' times loops'])
end
%% PARAMETERS
inputDimension = 7;
predictionHorizon = 1;
% Data size for training and testing

trainsize = 1000;
testsize = 100;

    
    
%% Data Formatting
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%       Data Formatting
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load MK30
load alphanoise
alphastable = alphanoise(1,:);
noise=zeros(size(MK30));
varNoise = 0.01;
noise=alphastable';

% inputSignal=MK30+noise+sqrt(varNoise)*randn(size(MK30));
inputSignal=MK30+noise;
%Input training signal with data embedding
trainInput = zeros(inputDimension,trainsize);
for k = 1:trainsize
    trainInput(:,k) = inputSignal(k:k+inputDimension-1);
end

%Input test data with embedding
testInput = zeros(inputDimension,testsize);
for k = 1:testsize
    testInput(:,k) = inputSignal(k+trainsize:k+inputDimension-1+trainsize);
end
% Desired training signal
trainTarget = zeros(trainsize,1);
for ii=1:trainsize
    trainTarget(ii) = inputSignal(ii+inputDimension+predictionHorizon-1);
end

% Desired training signal
testTarget = zeros(testsize,1);
for ii=1:testsize
    testTarget(ii) = inputSignal(ii+inputDimension+trainsize+predictionHorizon-1);
end




  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%
  %%            FrLMS/LMS
  %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  stepSizeWeightVectorLMS = 0.001;
  stepSizeBias = 0;
   flagLearningCurve = 1;
[learningCurveLMS]= ...
    LMS(trainInput,trainTarget,testInput,testTarget,stepSizeWeightVectorLMS,stepSizeBias,flagLearningCurve);



stepSizeWeightVectorFrLMS = 0.00075;
alpha =0.9;
[learningCurveFrLMS]= ...
    FrLMS(trainInput,trainTarget,testInput,testTarget,stepSizeWeightVectorFrLMS,alpha,flagLearningCurve);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%
  %%            FrRLS/RLS
  %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
epsilon = 35;
pInitialFrRLS = (1/epsilon)*eye(inputDimension);
  alpha = 1.32;
  flagLearningCurve = 1;
 [weightVector,learningCurveFrRLS]= ...
    FrRLS(trainInput,trainTarget,testInput,testTarget,pInitialFrRLS,alpha,flagLearningCurve);
  
  
epsilon = 100;
pInitialRls = (1/epsilon)*eye(inputDimension);
tic
[weightVectorRls,learningCurveRls] = ...
    RLS(trainInput,trainTarget,testInput,testTarget,pInitialRls,flagLearningCurve);
% % =========end of RLS================
% toc
% disp('RLS')

figure(1)
plot(10*log(learningCurveRls),'LineWidth',2)
 hold on
plot(10*log(learningCurveFrRLS),'LineWidth',2)
plot(10*log(learningCurveLMS),'LineWidth',2)
plot(10*log(learningCurveFrLMS),'LineWidth',2)
hold off
xlabel('iteration'),ylabel('MSE')
 title('learningCurve')
 legend('RLS','FrRLS','LMS','FrLMS')
