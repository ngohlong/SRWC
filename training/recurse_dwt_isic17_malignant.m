% get additional malignant images from ISIC Archive
% database to balance the two classes (benign and malignant)
tic;
clear all; close all;
addpath(genpath('data'));
addpath('utils');

myRootDir = './data/ISIC-2019-malignant';
mySubDirPattern = '*';
myFileExtension = '*.jpg';

mySubDirs = dir(fullfile(myRootDir, mySubDirPattern));
mySubDirs = mySubDirs(~ismember({mySubDirs.name},{'.','..'}));
numSubDirs = length(mySubDirs);
imgMat = [];
Y_label = [];
position = 0;

for i = 1:numSubDirs
    imgSubMat = [];%imgSubMat1 = [];
    if (mySubDirs(i).isdir == 1) %myRootDir might have files as well
        currentSubDir = fullfile(myRootDir, mySubDirs(i).name);
        
        %get all filenames that match myFilePattern
        myFiles = dir(fullfile(currentSubDir, myFileExtension));
        numFiles = length(myFiles);
        
        if (i>1)
            previousSubDir = fullfile(myRootDir, mySubDirs(i-1).name);
            previousFiles = dir(fullfile(previousSubDir, myFileExtension));
            numPreviousFiles = length(previousFiles);
            position = position + numPreviousFiles;
        end
        
        %read all files in sub directory and transform to wavelet space
        for k = 1:(numFiles)
            fileName = myFiles(k).name;
            fullFileName = fullfile(currentSubDir, fileName);
            X = imread(fullFileName);
            if size(X,3)==3
                Xgray = rgb2gray(X);
            end
            [m, n] = size(Xgray);
            
            % crop the image first
            r = 0.8; % ratio between cropped image and the original one
            p = round(r*m); q = round(r*n);
            xmin = round((m-p)/2);
            ymin = round((n-q)/2);
            win = [xmin ymin p q];
            Xcr = Xgray(xmin:p, ymin:q);
            
            % resize the image
            Xfin = imresize(Xcr, [256, 192], 'bicubic');
            % =========================================================================
            [cA1, cH1, cV1, cD1] = dwt2(Xfin,'db1'); %haar transformation
            
            cA1_tmp(:,k+position) = double(cA1(:));      
            Y_label(k+position) = 1;
        end
    end
end

Y = cA1_tmp;
%% save data
fn = strcat('data/myISIC_test_cr80plus_256x192.mat' );
save(fn, 'Y', 'Y_label', '-v7.3');