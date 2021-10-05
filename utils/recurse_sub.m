% function [imgMat, imgMat_range] = recurse_sub(myRootDir, mySubDirPattern, myFileExtension)
% Start with a folder and get a list of all subfolders.
% Finds all images in that folder and all of its subfolders
% tic;
database = 4;
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
end

mySubDirs = dir(fullfile(myRootDir, mySubDirPattern));
mySubDirs = mySubDirs(~ismember({mySubDirs.name},{'.','..'}));
numSubDirs = length(mySubDirs);
imgMat = [];
imgMat_range = 0;
%recurse sub-directories
for i = 1:numSubDirs
    imgSubMat = [];
    if (mySubDirs(i).isdir == 1) %myRootDir might have files as well
        
        currentSubDir = fullfile(myRootDir, mySubDirs(i).name);
        
        %get all filenames that match myFilePattern
        myFiles = dir(fullfile(currentSubDir, myFileExtension));
        numFiles = length(myFiles);
        
        %read all files in sub directory
        for k = 1:numFiles
            fileName = myFiles(k).name;
            fullFileName = fullfile(currentSubDir, fileName);
            X = imread(fullFileName);
            if size(X,3)==3
                X = rgb2gray(X);
%                 X = rgb2ycbcr(X);
%                 X = X(:,:,1);
            end
            X = imresize(X, [500, 500], 'bicubic');
% =========== Resize training images ======================================
%             X = imresize(X,1/4,'bicubic');
%               X = imresize(X, [32, 32]);
%             if size(X,1) > size(X,2)
%                 X = imresize(X,[300,250],'bicubic');
%             else
%                 X = imresize(X,[250,300],'bicubic');
%             end
% =========================================================================
            tmp = double(X(:)); 
            imgSubMat(:,k) = tmp;
        end
        imgMat = [imgMat imgSubMat];
        imgMat_range(i+1) = imgMat_range(i)+k;
    end
end
%% Dimension reduction
dims = 10000; % dimension of random-face feature descriptor
imgH = 500; % input image size
imgW = 500;
% generate the random matrix
randmatrix = randn(dims,imgH*imgW);
l2norms = sqrt(sum(randmatrix.*randmatrix,2)+eps);
randmatrix = randmatrix./repmat(l2norms,1,size(randmatrix,2));
Y = randmatrix*imgMat;
Y_range = imgMat_range;

switch database
    case 1
        fn = strcat('data/myYaleB.mat' );
    case 2
        fn = strcat('data/myAR.mat' );
    case 3
        fn = strcat('data/myCoil-100.mat' );
    case 4
        fn = strcat('data/myFlower');
    case 5
        fn = strcat('data/myARgender');
end
save(fn, 'Y', 'Y_range');
%toc;
% end