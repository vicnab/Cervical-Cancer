 a = imread('~/Desktop/RRK Cervix/Matlab codes/R006_HRME2 122ms.avi 13db.jpg');
 [ymax xmax ] = size(a);
 if (xmax < ymax)
     rad = xmax/2;
 else
     rad = ymax/2;
 end
 Xcent = xmax/2;
 Ycent = ymax/2;
 X = [Xcent Xcent - rad Xcent - rad/2];
 Y = sqrt(rad^2 - (X-Xcent).^2) + Ycent;
 b = a;
 for x = 1:xmax
for y= 1:ymax
if(isincircle(X,Y,x,y) < 1)
b(y,x) = 255;
end
end
end