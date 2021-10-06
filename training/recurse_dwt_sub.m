
tic;
clear all; close all;

addpath(genpath('utils'));
addpath('data');

database = 8;
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
        myRootDir = './data/Cropped_ARgender';
        mySubDirPattern = '*';
        myFileExtension = '*.bmp';
end

mySubDirs = dir(fullfile(myRootDir, mySubDirPattern));
mySubDirs = mySubDirs(~ismember({mySubDirs.name},{'.','..'}));
numSubDirs = length(mySubDirs);
imgMat = []; 
imgMat_range = 0;

%% recurse sub-directories
for i = 1:numSubDirs
    imgSubMat = [];%imgSubMat1 = [];
    if (mySubDirs(i).isdir == 1) % myRootDir might have files as well
        
        currentSubDir = fullfile(myRootDir, mySubDirs(i).name);
        
        % get all filenames that match myFilePattern
        myFiles = dir(fullfile(currentSubDir, myFileExtension));
        numFiles = length(myFiles);
        
        % read all files in sub directory and transform to wavelet space
        for k = 1:(numFiles)
            fileName = myFiles(k).name;
            fullFileName = fullfile(currentSubDir, fileName);
            X = imread(fullFileName);
            if size(X,3)==3
                X = rgb2gray(X);
            end
            % ===========================================================
            [cA1,~,~,~] = dwt2(X1,'db1'); %daubechies transformation
            cA1_tmp = double(cA1(:));
            imgSubMat(:,k) = cA1_tmp;
        end
        imgMat = [imgMat imgSubMat];
        imgMat_range(i+1) = imgMat_range(i) + k;
    end
end

%% PCA dimensionality reduction
C = double(imgMat * imgMat');
[V, D] = eig(C);
D = diag(D); % perform PCA on features matrix
D = cumsum(D) / sum(D);
k = find(D >= 1e-3, 1); % ignore 0.1% energy
V_pca = V(:, k:end); % choose the largest eigenvectors' projection
imgMat_pca = V_pca' * imgMat;
Yw = imgMat_pca; Yw_range = imgMat_range;

%% save data
switch database
    case 1
        fn = strcat('data/myYaleB_Wavelet1.mat');
    case 2
        fn = strcat('data/myAR_Wavelet1.mat' );
    case 3
        fn = strcat('data/myCoil-100_Wavelet1.mat' );
    case 4
        fn = strcat('data/myARgender_Wavelet1');
end
save(fn, 'Yw', 'Yw_range');
toc;