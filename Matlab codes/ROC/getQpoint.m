function idx = getQpoint(xdata, ydata)
qMeasure = sqrt((0-xdata).^2 + (1-ydata).^2);

[minV, minI] = min(qMeasure);
% disp(1-xdata(minI));
% disp(ydata(minI));
idx = minI;