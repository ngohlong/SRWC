% Start with a folder and get a list of all subfolders.
% Finds all images in that folder and all of its subfolders
% 3 separate sets of training, validation and test images
tic;
clear all; close all;
addpath(genpath('data'));
addpath('utils');
mode = 3;

switch mode
    case 1
        myRootDir = './data/ISIC_2017+_PhiHatVF/ISIC-2017_Training_Data_PhiHatVF';
        myFileExtension = '*.png';
        groundTruthFile = 'ISIC-2017_Training_Part3_GroundTruth.csv';
    case 2
        myRootDir = './data/ISIC_2017+_PhiHatVF/ISIC-2017_Validation_Data_PhiHatVF';
        myFileExtension = '*.png';
        groundTruthFile = 'ISIC-2017_Validation_Part3_GroundTruth.csv';
    case 3
        myRootDir = './data/ISIC_2017+_PhiHatVF/ISIC-2017_Test_v2_Data_PhiHatVF';
        myFileExtension = '*.png';
        groundTruthFile = 'ISIC-2017_Test_v2_Part3_GroundTruth.csv';
end

%% Initial
groundTruth = csvread(groundTruthFile, 1, 1);
imgSubMat_mela = []; imgSubMat_benign = [];
tmp_label_mela = []; tmp_label_benign = [];
s = 1; t = 1;
%%% recurse sub-directories

%% get all filenames that match�myFilePattern
myFiles = dir(fullfile(myRootDir, myFileExtension));
numFiles = length(myFiles);

%% read all files in sub directory and transform to wavelet space
for i = (numFiles):-1:1
    fileName = myFiles(i).name;
    fullFileName = fullfile(myRootDir, fileName);
    X = imread(fullFileName);    
    if size(X,3)==3
        Xgray = rgb2gray(X);
    end
    [m, n] = size(Xgray);
    % crop the image first
    r = 1; % ratio between cropped image and the original one
    p = round(r*m); q = round(r*n);
    xmin = round((m-p)/2)+1;
    ymin = round((n-q)/2)+1;
    win = [xmin ymin p q];
    Xcr = Xgray(xmin:p, ymin:q);
    
    % resize the image
    Xfin = imresize(Xcr, [256, 192], 'bicubic'); %192x256 or 256x192 or 600x450 or 256x256 or 128x96 
    % or 230x172 or 272x204
    % wavelet decomposition in quaternions
    [cA1,cH1,cV1,cD1] = dwt2(Xfin, 'db1'); %daubechies transformation    
    tmp = double(cA1(:));    
%     tmp = double(cD1(:));    
    if groundTruth(i,1)==1;
        imgSubMat_mela(:,s) = tmp;    
        tmp_label_mela(s) = 1;
        s = s+1;
    else
        imgSubMat_benign(:,t) = tmp;   
        tmp_label_benign(t) = 2;
        t = t+1;
    end
end
imgMat = [imgSubMat_mela imgSubMat_benign];
label = [tmp_label_mela tmp_label_benign];

%% save data
Y = imgMat; Y_label = label;
switch mode
    case 1
        fn = strcat('data/myISIC17-PhiHatVF_training_256x192.mat');
    case 2
        fn = strcat('data/myISIC17-PhiHatVF_validation_256x192.mat');    
    case 3
        fn = strcat('data/myISIC17-PhiHatVF_test_256x192.mat');
end
save(fn, 'Y', 'Y_label', '-v7.3');
toc;
% end