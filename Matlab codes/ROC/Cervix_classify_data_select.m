%BE_classify_data_select.m
%Classifies data.  Selects optimum parameter by maximizing AUC
%(in addition to any parameters specified).
%ROC and scatter plots are not generated.
%Column 2 is used as gold standard.

%Need functions, drawPlot.m, getAUC.m, getQpoint.m

%D. Shin
%9/27/2011

disp('**************************************************')

close all
clear all

% load BE_data_correlation;%load matrix, BE_data_correlation.mat
% load be_data_contrast;%load matrix, BE_data_correlation.mat
% load be_data_energy;%load matrix, BE_data_correlation.mat
% load be_data_homo;%load matrix, BE_data_correlation.mat
load be_data;   %load matrix

aucvector(1:16,1)=5:20;%offset feature #5-20
% aucvector(1:10,1)=5:14;%offset feature #5-14

%Start loop to select parameters (choose from features #5-20)
for p = [5:20]
params = [p];

%Select TRAIN and TEST data sets:
TRAIN = be_data;
TEST = be_data;

%Classify.
[testResult,err,posterior]=classify(TEST(:,params), TRAIN(:,params), TRAIN(:,2), 'linear',[0.5 0.5]);%Coloumn 2 is used as gold standard
posteriorArr = posterior(:,2);

%Calculate & report results
NoNeg = sum(TEST(:,2) == 1);%Coloumn 2 is used as gold standard
NoPos = sum(TEST(:,2) == 2);%Coloumn 2 is used as gold standard
rocTh= [1:-0.001:0];
Sensitivity = [];
Specificity = [];
testResult = [];
% Pooling result
for k = 1:length(rocTh),
        testResultArr = zeros(size(posteriorArr, 1), 1);
        abnormalIdx = find(posteriorArr >= rocTh(k));
        normalIdx = find(posteriorArr < rocTh(k));
        testResultArr(abnormalIdx) = 2;
        testResultArr(normalIdx) = 1;          
        % Report sensitivity & specificity
        trueNeg = sum((TEST(:,2) == 1) & (testResultArr ==1));%Coloumn 2 is used as gold standard
        truePos = sum((TEST(:,2) == 2) & (testResultArr ==2));%Coloumn 2 is used as gold standard
        if NoNeg > 0,
            Specificity(k)= trueNeg/NoNeg; %Specificity
        end
        if NoPos > 0,
            Sensitivity(k) = truePos/NoPos; %Sensitivity
        end
        testCell{k} = testResultArr;
end

if NoNeg >0 & NoPos > 0,
    aucIdx = getAUC(Sensitivity, 1-Specificity);
    
    
totalPerf = Sensitivity + Specificity;
[maxV, maxI] = max(totalPerf);
iidx = maxI;
 %disp(iidx);
testResult = testCell{iidx};
performance.auc = aucIdx;

end

performance.se = Sensitivity;
performance.sp = Specificity;

aucvector(p-4,2)=aucIdx;
end

%**************************************************************

plot(aucvector(:,1),aucvector(:,2));

aucsorted=sortrows(aucvector,2);
aucsorted=flipud(aucsorted);

disp(aucsorted(1:16,:));





