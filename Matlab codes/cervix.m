clear;
home;
[filename, filepath] = uigetfile('../*.png');
path(path, filepath);
f = imread(filename);
f_in = imcomplement(f);

%% Load circular ROI B/W mask
roi = imread('C:\Documents and Settings\tcb1\Desktop\hrme analysis\Circular ROI mask (830px).jpg'); %%50 pixel inside from the edge
bw_roi = im2bw(roi, 0.5); %%B/W circular mask

bw_roi_area = sum(bw_roi(:) == 1); %% Area of ROI
f_roi = immultiply(f, bw_roi); %% An image for analysis

%% Create artifact filter for too bright area
gaussianFilter = fspecial('gaussian', [11,11],3);
f_f = imfilter(f_roi, gaussianFilter, 'symmetric', 'conv');
f_eq = histeq(f_f);
f_tmp = medfilt2(f_eq, [80 80]);
thres = graythresh(f_tmp);
bw_art_b = im2bw(f_tmp, thres+0.33);
bw_art_b_area = sum(bw_art_b(:) == 1); %% Area of artifact#1

%% Create artifact filter for too dim area
f_roi2 = immultiply(f_in, bw_roi);
f_f = imfilter(f_roi2, gaussianFilter, 'symmetric', 'conv');
f_eq = histeq(f_f);
f_tmp = medfilt2(f_eq, [80 80]);
thres_d = graythresh(f_tmp);
bw_art_d = im2bw(f_tmp, thres_d+0.37);
bw_art_d_area = sum(bw_art_d(:) == 1); %% Area of artifact#2

%% Smart creation of ROI avoiding artifacts (too bright or too dim)
bw_smt = immultiply(bw_roi,~bw_art_b);
bw_smt = immultiply(bw_smt,~bw_art_d);
se_roi = strel('disk', 20); %% How far from the artifacts
se_smh = strel('disk', 80); %% How smooth ROI is
bw_smt = imerode(bw_smt, se_roi);
bw_smt = imopen(bw_smt, se_smh);

%% bw_smt is a final ROI
bw_smt_area = sum(bw_smt(:) == 1); %% Area of final ROI
f_f = immultiply(f, bw_smt);
f_f = imfilter(f_f, gaussianFilter, 'symmetric', 'conv');

%% Segmentation
se =  strel('disk',10,8); %?? 6 %% parameter '8' is the best discriminate nuclei
se2 =  strel('disk',4,8); %%for open
f_t = imtophat(f_f,se);
f_o = imopen(f_t, se2); %%Opening tophatted image with 2
bw_open = im2bw(f_o, graythresh(f_o));
bw_seg = imclearborder(bw_open);
bw_seg = bwareaopen(bw_seg, 10);
bw_seg_area = sum(bw_seg(:) == 1); %% Area of segmented area without artifacts

%% Internuclear distance %%
bw= bwmorph(bw_seg, 'fill', Inf);
bw2 = bwmorph(bw, 'shrink', Inf);
[r,c] = find(bw2==1);

 figure, imshow(f);
 hold on
 voronoi(c,r, 'green'); %% draw voronoi diagram
dt = DelaunayTri(c,r);
 hold on
 triplot(dt, 'yellow'); %% draw triplot

[p q] = size(dt.X);
for i=1:p
    for j=1:p
        if(i == j)
            tmp_e(j,1) = 1000000; %%just huge number
            tmp_e(j,2) = j;
        else
            tmp_e(j,1) = sqrt((dt.X(j,1)-dt.X(i,1))^2 + (dt.X(j,2)-dt.X(i,2))^2);
            tmp_e(j,2) = j;
        end
    end
    [dist jj] = min(tmp_e(:,1));
    tmp_dist(i,1) = dist;
    tmp_dist(i,2) = i;
    tmp_dist(i,3) = jj;
end
 hold on
 for i=1:p
     line([dt.X(uint16(tmp_dist(i,2)),1) dt.X(uint16(tmp_dist(i,3)),1)],[dt.X(uint16(tmp_dist(i,2)),2) dt.X(uint16(tmp_dist(i,3)),2)],'Color','r','LineWidth',2);
end
hold off
mean_inter_d_near = mean(tmp_dist);
std_inter_d_near = std(tmp_dist);


%% N/C ratio
n_sum = bw_seg_area;
c_sum = bw_smt_area - bw_seg_area;
c_sum_RRK = bw_smt_area; %% RRK N/C ratio

nc_ratio = n_sum/c_sum;
nc_ratio_RRK = n_sum/c_sum_RRK;

k = 1;
ratio(k) = nc_ratio;
ratio_RRK(k) = nc_ratio_RRK;

cc = bwconncomp(bw_seg);
s = regionprops(cc, 'Orientation', 'MajorAxisLength', 'Area', ...
    'MinorAxisLength', 'Eccentricity', 'Centroid', 'Solidity', 'EquivDiameter');
ecc = [s.Eccentricity];

%% Second artifact filter
ind_AXIS = find(ecc <0.95);
ind_AXIS_2 = find(ecc >=0.95);
bw_AXIS = ismember(labelmatrix(cc), ind_AXIS); %% Segmented image without artifact #2 as well as bright and deem
bw_art_l = ismember(labelmatrix(cc), ind_AXIS_2); %% Artifact #2

bw_art_l_area = sum(bw_art_l(:) == 1); %% Area of artifact#2
bw_seg_no_art_area = sum(bw_AXIS(:) == 1); %% Area of segmented without artifact #1,2

ratio_long(k) = (n_sum - bw_art_l_area)/(c_sum - bw_art_l_area);

%% Caculate regional properties again without any artifacts 
cc = bwconncomp(bw_AXIS); 
s = regionprops(cc, 'Orientation', 'MajorAxisLength', 'Area', ...
    'MinorAxisLength', 'Eccentricity', 'Centroid', 'Solidity', 'EquivDiameter');
ecc = [s.Eccentricity];
major_x_length = [s.MajorAxisLength];
equiDia = [s.EquivDiameter];
area = [s.Area];
solid = [s.Solidity];

mean_ecc(k) = mean(ecc(:));
std_ecc(k) = std(ecc(:));
mean_major(k) = mean(major_x_length(:));
std_major(k) = std(major_x_length(:));
mean_area(k) = mean(area(:));
std_area(k) = std(area(:));
mean_solidity(k) = mean(solid(:));
std_solidity(k) = std(solid(:));

%% 99% CI - not good for nc ratio
CI1 = mean_area(k) + 3*std_area(k);
CI2 = mean_area(k) - 3*std_area(k);
ind_CI = find(area <= CI1 & area>=CI2);
CI_area = area(ind_CI);
mean_CI_area(k) = mean(CI_area(:));
std_CI_area(k) = std(CI_area(:));

CIx1 = mean_major(k) + 3*std_major(k);
CIx2 = mean_major(k) - 3*std_major(k);
ind_CIx = find(major_x_length <= CIx1 & major_x_length>=CIx2);
CI_major = major_x_length(ind_CIx);
mean_CI_major(k) = mean(CI_major(:));
std_CI_major(k) = std(CI_major(:));

CI_ecc_area = ecc(ind_CI); %% Eccentricity whose area within 99CI
CI_ecc_major = ecc(ind_CIx); %% Eccentricity whose major axis within 99CI

mean_CI_ecc_area(k) = mean(CI_ecc_area(:));
mean_CI_ecc_major(k) = mean(CI_ecc_major(:));

bw_seg_CI = ismember(labelmatrix(cc), ind_CI); %% Final segment area
bw_out_CI = bw_AXIS - bw_seg_CI; %% out of 99CI segment

bw_seg_X_CI = ismember(labelmatrix(cc), ind_CIx); %% Final segment area of major axis
bw_out_X_CI = bw_AXIS - bw_seg_X_CI; %% out of 99CI segment of major axis

n_sum = sum(bw_seg_CI(:) == 1);
c_sum = bw_smt_area - bw_seg_no_art_area - bw_art2_area - sum(bw_out_CI(:) == 1);
ratio_CI(k) = n_sum/c_sum;

%% Figures
figure, imshow(f);
hold on
b = bwboundaries(bw_roi);
for k = 1:numel(b)
    plot(b{k}(:,2), b{k}(:,1), 'b', 'Linewidth', 2)
end
hold on
b = bwboundaries(bw_art_b);
for k = 1:numel(b)
    plot(b{k}(:,2), b{k}(:,1), 'r', 'Linewidth', 2)
end
hold on
b = bwboundaries(bw_art_d);
for k = 1:numel(b)
    plot(b{k}(:,2), b{k}(:,1), 'm', 'Linewidth', 2)
end
hold on
b = bwboundaries(bw_smt);
for k = 1:numel(b)
    plot(b{k}(:,2), b{k}(:,1), 'c', 'Linewidth', 2)
end
hold on
b = bwboundaries(bw_seg);
for k = 1:numel(b)
    plot(b{k}(:,2), b{k}(:,1), 'w', 'Linewidth', 2)
end
hold on
voronoi(c,r, 'green'); %% draw voronoi diagram
hold on
triplot(dt, 'yellow');
hold on
for i=1:p
     line([dt.X(uint16(tmp_dist(i,2)),1) dt.X(uint16(tmp_dist(i,3)),1)],[dt.X(uint16(tmp_dist(i,2)),2) dt.X(uint16(tmp_dist(i,3)),2)],'Color','r','LineWidth',2);
 end
hold off

%% Feature display
ratio
mean_area
% mean_CI_area
mean_major
% mean_CI_major
mean_ecc
% mean_CI_ecc_area
% mean_CI_ecc_major
mean_solidity
mean_inter_d_near(1)

