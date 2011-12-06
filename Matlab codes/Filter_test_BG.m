%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
% Matlab program to segment nuclei in HRME images                         %
% Requires user to choose an image, select a polygonal ROI, set threshold %
% Returns a list of segmented nuclear areas and centroids                 %
% Returns mean N/C ratio, mean and standard deviation of nuclear area     %
% Mark Pierce - 04/17/2011, last revision 06/20/2011                      %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

s = pwd;
%[FileName,PathName] = uigetfile({'*.*';'*.tif';'*.jpg';'*.bmp'},'Select an image file');
%%Need to come back and remove this later, this is to speed up debugging by
%%using same image over and over
FileName = 'R006_HRME2 122ms.avi 13db.jpg';
PathName = '/Users/Ben/Desktop/RRK Cervix/Matlab codes/';
%%
[token, remain] = strtok(FileName,'.');
cd(PathName);

raw_image = imread(FileName);
[BW, x, y] = roipoly(raw_image);
close(gcf);

figure; imshow(raw_image(:,:,1), 'Border', 'tight');

B = double(raw_image(:,:,1)).*BW;
B = uint8(B);

C = ordfilt2(B,12, ones(4,4)); 

D = adapthisteq(C,'NumTiles',[25 25],'clipLimit',0.15,'Distribution','rayleigh');

E = medfilt2(D, [4 4]);

thresh = 0.65;                    % User input threshold

F = im2bw(E,thresh);

G = bwareaopen(F, 50);  % Remove components from binary image with < 50 pixels (noise)
H = bwareaopen(G, 1500);  

I = G - H;  % Remove components from binary image with > 1500 pixels (clumps)
   
J = bwlabel(I);  

stats = regionprops(J, 'Area', 'Centroid');

[M,L] = bwboundaries(I, 'noholes');    
[N,O] = bwboundaries(H, 'noholes');    

figure; imshow(raw_image(:,:,1), 'Border', 'tight');
hold on
for k = 1:length(M)
    boundary = M{k};
    plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);
end

for k = 1:length(N)
    boundary = N{k};
    plot(boundary(:,2), boundary(:,1), 'y', 'LineWidth', 2);
end

hold on
axis manual
plot(x,y, 'g', 'LineWidth', 2);
cd(PathName);
%saveas(gcf,[token,'_ROI_nuclei.bmp']);
cd(s);

for k = 1:size(stats,1)
    x1(k) = stats(k).Area;
    x2(k) = stats(k).Centroid(1);
    x3(k) = stats(k).Centroid(2);
end

t = numel(nonzeros(B)); 
NC_ratio = sum(x1)/(t - sum(x1) - bwarea(H));
Mean_area = mean(x1);
SD_area = std(x1);

cd(PathName);
Param_list = {'Area' 'Centroid_Row' 'Centroid_Col' 'NC_ratio' 'Mean_area' ' SD_area' '# Nuclei' 'Threshold'}; 
xlswrite([token,'_metrics','.xls'], x1' , 'A2:A500');
xlswrite([token,'_metrics','.xls'], x2' , 'B2:B500');
xlswrite([token,'_metrics','.xls'], x3' , 'C2:C500');
xlswrite([token,'_metrics','.xls'], NC_ratio , 'D2:D2');
xlswrite([token,'_metrics','.xls'], Mean_area , 'E2:E2');
xlswrite([token,'_metrics','.xls'], SD_area , 'F2:F2');
xlswrite([token,'_metrics','.xls'], k , 'G2:G2');
xlswrite([token,'_metrics','.xls'], thresh , 'H2:H2');
xlswrite([token,'_metrics','.xls'], Param_list, 'A1:H1');



