% function [imgMat, imgMat_range] = recurse_dwt_sub(myRootDir, mySubDirPattern, myFileExtension)
% Start with a folder and get a list of all subfolders.
% Finds all images in that folder and all of its subfolders
% tic;
clear all; close all;

addpath(genpath('utils'));
addpath('data');

database = 7;
switch database
    case 1
        myRootDir = './data/Cropped_Yale';
        mySubDirPattern = 'yaleB*';
        myFileExtension = '*.pgm';
    case 2
        myRootDir = './data/Cropped_AR';
        mySubDirPattern = '*';
        myFileExtension = '*.bmp';
    case 3
        myRootDir = './data/coil-100';
        mySubDirPattern = 'obj*';
        myFileExtension = '*.png';
    case 4
        myRootDir = './data/myFlower17';
        mySubDirPattern = 'flower_*';
        myFileExtension = '*.jpg';
    case 5
        myRootDir = './data/Cropped_ARgender';
        mySubDirPattern = '*';
        myFileExtension = '*.bmp';
    case 6
%         myRootDir = './data/coil-100_PhiHatVF_PNG';
        myRootDir = './data/coil-100_PsiHatVF_PNG';
%         myRootDir = './data/coil-100_PGVF_PNG';
        mySubDirPattern = 'obj*';
        myFileExtension = '*.png';
    case 7
        myRootDir = './data/Cropped_Yale_PhiHat';
        mySubDirPattern = 'yaleB*';
        myFileExtension = '*.png';
end

mySubDirs = dir(fullfile(myRootDir, mySubDirPattern));
mySubDirs = mySubDirs(~ismember({mySubDirs.name},{'.','..'}));
numSubDirs = length(mySubDirs);
imgMat = []; %imgMat1 = [];
imgMat_range = 0;
%recurse sub-directories
for i = 1:numSubDirs
    imgSubMat = [];%imgSubMat1 = [];
    if (mySubDirs(i).isdir == 1) %myRootDir might have files as well
        
        currentSubDir = fullfile(myRootDir, mySubDirs(i).name);
        
        %get all filenames that match myFilePattern
        myFiles = dir(fullfile(currentSubDir, myFileExtension));
        numFiles = length(myFiles);
        
        %read all files in sub directory and transform to wavelet space
        for k = 1:(numFiles)
            fileName = myFiles(k).name;
            fullFileName = fullfile(currentSubDir, fileName);
            X = imread(fullFileName);
            if size(X,3)==3
                X = rgb2gray(X);
%                 X = rgb2ycbcr(X);
%                 X = X(:,:,1);
            end
% =========== Resize training images ======================================            
              if database == 6
%                 X = imresize(X, [64, 64], 'bicubic');
                X = imresize(X, [420, 420], 'bicubic');
              end
%             if size(X,1) > size(X,2)
%                 X = imresize(X,[300,250],'bicubic');
%             else
%                 X = imresize(X,[250,300],'bicubic');
%             end
% =========================================================================
            [cA1,cH,cV,cD] = dwt2(X,'db1'); %daubechies transformation
%             cA = 0.6 .*cA1 + 0.2 .*cH + 0.2 .*cV;
            cA1_tmp = double(cA1(:));
%             cD_tmp = double(cD(:));
            imgSubMat(:,k) = cA1_tmp;
        end
        imgMat = [imgMat imgSubMat]; %imgMat1 = [imgMat1 imgSubMat1];
        imgMat_range(i+1) = imgMat_range(i)+k;
    end
end
% PCA dimensionality reduction
C = double(imgMat * imgMat');
[V, D] = eig(C);
D = diag(D); % perform PCA on features matrix
D = cumsum(D) / sum(D);
k = find(D >= 1e-3, 1); % ignore 0.1% energy
V_pca = V(:, k:end); % choose the largest eigenvectors' projection
imgMat_pca = V_pca' * imgMat;
Yw = imgMat_pca; Yw_range = imgMat_range;

switch database
    case 1
        fn = strcat('data/myYaleB_Wavelet1.mat' );
    case 2
        fn = strcat('data/myAR_Wavelet1.mat' );
    case 3
        fn = strcat('data/myCoil-100_Wavelet1.mat' );
    case 4
        fn = strcat('data/myFlower_Wavelet1');
    case 5
        fn = strcat('data/myARgender_Wavelet1');
    case 6
        fn = strcat('data/myCoil-100_PsiHatVF_resize420x420_Wavelet1.mat');
%         fn = strcat('data/myCoil-100_PhiHatVF_resize64x64_Wavelet1.mat');
%         fn = strcat('data/myCoil-100_PGVF_Wavelet1.mat');
    case 7
        fn = strcat('data/myYaleB_PhiHatVF_Wavelet1.mat');
end
save(fn, 'Yw', 'Yw_range');
%toc;
% end