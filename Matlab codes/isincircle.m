%X and Y contain 3 points each that DEFINE a circle (x1,y1), (x2,y2),
%(x3,y3) are all points that lie on the circle where X = [x1 x2 x3] and Y
%]= [y1 y2 y3]. Synatx is isincircle(X,Y,x,y) where x,y is poitn to be
%determined if in or out of circle
function result = isincircle(X,Y,x,y)
x1 = X(1); 
x2 = X(2);
x3 = X(3);
y1 = Y(1);
y2 = Y(2);
y3 = Y(3);
k = ((x1-x2)*(x2*x2-x3*x3+y2*y2-y3*y3)-(x2-x3)*(x1*x1-x2*x2+y1*y1-y2*y2))/((2)*((y2-y3)*(x1-x2)-(y1-y2)*(x2-x3)));
h = ((y1-y2)*(y1+y2-2*k))/((2)*(x1-x2))+(x1+x2)/2;
r = sqrt((x3-h)*(x3-h)+(y3-k)*(y3-k));
val = (x-h)*(x-h)+(y-k)*(y-k)-r*r;
result = sign(val);