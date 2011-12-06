%********************************************************************************
% filterbp : getAUC
%
% Author : Sun Young Park,
% Created: Nov 30, 2006
% Modified: 
% Copyright: Optical Spectroscopy Lab. Biomedical Engineering Dep.
% University of Texas at Austin 2003-2007
% Uses: 
%********************************************************************************

function [aucIdx] = getAUC(y, x)

auc = 0;
for i = 1:length(x)-1;
    deltaX = (x(i+1) - x(i));
    auc = auc + deltaX * (y(i)+y(i+1))/2;    
end

aucIdx = auc;