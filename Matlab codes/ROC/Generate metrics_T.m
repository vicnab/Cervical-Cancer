% Generate metrix
% for TEFO

% Created by TEFO 11/10/2011

clear;
cervix_data = [];

% Set index number for measurement
for i=1:44  %% total 44 sites
    cervix_data(i,1)=i;
end

% Put N/C ratio in column2 (feature)
[cervix_data(:,2)]=xlsread('F:\Botswana Cervix\Matlab code\cervix_hrme.xlsx','Sheet1','d1:d45');

% Put Diagnosis #1 (Normal vs. LG/HG) in column3
[cervix_data(:,3)]=xlsread('F:\Botswana Cervix\Matlab code\cervix_hrme.xlsx','Sheet1','e1:e45');
% Put Diagnosis #1 (Normal/LG vs. HG) in column4
[cervix_data(:,4)]=xlsread('F:\Botswana Cervix\Matlab code\cervix_hrme.xlsx','Sheet1','f1:f45');

save 'F:\Botswana Cervix\Matlab code\cervix_data.mat' cervix_data
