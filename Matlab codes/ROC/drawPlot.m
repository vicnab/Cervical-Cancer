function drawPlot(performance1,testResult)
figure; plot(1-performance1.sp, performance1.se, 'r','LineWidth',2);
hold on; plot([0 1], [0 1], 'k');
xlabel('1-Specificity');
ylabel('Sensitivity');
set(gcf, 'Color', 'White');
% title(['EEM' num2str(FLAGS.eemno) ', Norm ~ cin1 (All)vs. HG(All)  using ' FLAGS.modelname ]);
xlabel([' AUC:' num2str(performance1.auc)]); 
[idx]= getQpoint(1-performance1.sp, performance1.se);
disp('Sensitivity:');
disp(performance1.se(idx));
disp('Specificity:');
disp(performance1.sp(idx));

seIdx80 = find(performance1.se >= 0.8);
x = [performance1.se(seIdx80(1)-1) performance1.se(seIdx80(1))];
y = [performance1.sp(seIdx80(1)-1) performance1.sp(seIdx80(1))];
y80 = interp1(x, y, 0.8);

%Display cutoff for 80/xx:  1 - 0.001*[average of seIdx80(1)-1 and seIdx80(1)]
%(added by RAS, 10/28/2007):
disp('Cutoff:')
disp(1 - 0.001*((seIdx80(1)-1)+seIdx80(1))/2)

spIdx80 = find(performance1.sp >= 0.8);
x = [performance1.se(spIdx80(end)+1) performance1.se(spIdx80(end))];
y = [performance1.sp(spIdx80(end)+1) performance1.sp(spIdx80(end))];
x80 = interp1(y, x, 0.8);

% se80Idx = findInit(performance1.se, 0.8);
% sp80Idx = findInit(performance1.sp, 0.8);
hold on;
text(0.6, 0.3, [' Se:' num2str(performance1.se(idx)) ', Sp:' num2str(performance1.sp(idx)) ]);
text(0.6, 0.2, [' Se: 0.80   Sp:' num2str(y80) ]);
text(0.6, 0.15, [' Se:' num2str(x80) ', Sp: 0.80']);

totalPerf = performance1.se + performance1.sp;
[maxV, maxI] = max(totalPerf); 
iidx = maxI;
%reportTool4(dxID, tissueType, testResult);
%disp(':'); disp(maxV);
%disp('Sensitivity & Specificity');
%disp('Sensitivity'); disp(performance1.se(iidx-3:iidx+3));
%disp('Specificity'); disp(performance1.sp(iidx-3:iidx+3));
%performance1.maxSens = performance1.se(iidx);
%performance1.maxSpec = performance1.sp(iidx);