%classify_mock_data_fixed.m
%Classifies mock data using a fixed subset of "measured" params 2-11.
%ROC and scatter plots are generated.
%Column 3 or 4 is used as gold standard.

%R. Schwarz
%1/18/2008

%Modified by Tefo 11/10/2011

disp('**************************************************')

close all
clear all

load cervix_data;

%Define features to use for classification (choose from features #2-11)
% params = [8 6 5 7];
% params = [8 6 5];
% params = [8 6];
params = [2]; %% column 2 (N/C ratio)
% dx_col = 3; %Nm vs.LG/HG
dx_col = 4;  %Nm/LG vs. HG
%Select TRAIN and TEST data sets:
TRAIN=cervix_data;
TEST=cervix_data;

%Classify.
[testResult,err,posterior]=classify(TEST(:,params), TRAIN(:,params), TRAIN(:,dx_col), 'linear',[0.5 0.5]);
posteriorArr = posterior(:,2);

%Calculate & report results
NoNeg = sum(TEST(:,dx_col) == 1);
NoPos = sum(TEST(:,dx_col) == 2);
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
        trueNeg = sum((TEST(:,dx_col) == 1) & (testResultArr ==1));
        truePos = sum((TEST(:,dx_col) == 2) & (testResultArr ==2));
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
    
drawPlot(performance, testResult);

%%Accuracy from others - TEFO
hold on
%Dx1 (Normal vs.LG/HG)
% plot(1-0.8333,0.5938,'bs');%RRK
% plot(1-0.833,0.719,'rs');%Doreen
% plot(1-0.917,0.656,'gs');%Clinical

% Dx2 (Nm/LG vs. HG)
plot(1-0.733,0.929,'bs');%RRK
plot(1-0.7,0.857,'rs');%Doreen
plot(1-0.833,0.643,'gs');%Clinical



hold off
%Scatter plot of posterior probability & path Dx
figure
for j=1:length(posteriorArr)
    if (TEST(j,dx_col)==1)
        plot (j, posteriorArr(j),'bs')
        hold on
    elseif (TEST(j,dx_col)==2)
        plot (j, posteriorArr(j),'rs')
        hold on
    else
        plot (j, posteriorArr(j),'ko')
        hold on
    end
end
ylabel('Posterior Probability');
