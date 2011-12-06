[FileName,PathName] = uigetfile({'*.*';'*.tif';'*.jpg';'*.bmp'},'Select an image file');
%%Need to come back and remove this later, this is to speed up debugging by
%%%using same image over and over
%FileName = 'R006_HRME2 122ms.avi 13db.jpg';
%PathName = '/Users/Ben/Desktop/RRK Cervix/Matlab codes/';
cd(PathName);
img = imread(FileName);
[SizeY SizeX] = size(img);
centerX = SizeX/2;
centerY = SizeY/2;
a_rad = 35; %analysis radius
if(centerX<centerY)
    rad = centerX;
else
    rad = centerY;
end
poss_centersX = centerX-rad:2*a_rad:centerX+rad;
poss_centersY = centerY-rad:2*a_rad:centerY+rad;
%define big outter circle with three points for purpose of
%isincircle routine, it's stupid
 X = [centerX centerX - rad centerX - rad/2];
 Y = sqrt(rad^2 - (X-centerX).^2) + centerY;
realcenters = [];
numcenters = 0;
 for i = 1:length(poss_centersX)
    for j = 1:length(poss_centersY)
        minX = poss_centersX(i) - a_rad;
        maxX = poss_centersX(i) + a_rad;
        minY = poss_centersY(j) - a_rad;
        maxY = poss_centersY(j) + a_rad;
        legit = 1;
        if(isincircle(X,Y,minX,poss_centersY(j))>0)
            legit = 0;
        elseif(isincircle(X,Y,maxX,poss_centersY(j))>0)
            legit = 0;
        elseif(isincircle(X,Y,poss_centersX(i),minY)>0)
            legit = 0;
        elseif(isincircle(X,Y,poss_centersX(i),maxY)>0)
            legit=0;
        end
        if(legit)
            numcenters = numcenters + 1;
            realcenters(numcenters, 1) = poss_centersX(i);
            realcenters(numcenters,2) = poss_centersY(j);
        end
  
    end
 end
%  imshow(img, 'Border', 'tight'); hold on;
%  for i =1:numcenters
%      DrawCircle(realcenters(i,1), realcenters(i,2), a_rad)
%      pause
%  end
clear NCratio;
imshow(img,'Border', 'tight'); hold on;
hold on
for i = 1:numcenters
    %close all;
     [splinex spliney] = CirclePol(realcenters(i,1), realcenters(i,2), a_rad);
     NCratio(i) = NC_ratio_BG(FileName,PathName, img, splinex, spliney);
     
end
NCratio = NCratio(find(isnan(NCratio) == 0)); %remove nan values