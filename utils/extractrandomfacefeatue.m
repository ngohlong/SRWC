%%% an example of extracting random face feature descriptors
%%%
clear all;
close all;
% parameter setting
tic

database = 1;
switch database
    case 1
        myRootDir = './data/Cropped_Yale';
        mySubDirPattern = 'yaleB*';
        myFileExtension = '*.pgm';
        dims = 504; % dimension of random-face feature descriptor
    case 2
        myRootDir = './data/Cropped_AR';
        mySubDirPattern = '*';
        myFileExtension = '*.bmp';
        dims = 540; % dimension of random-face feature descriptor
    case 3
        myRootDir = './data/coil-100';
        mySubDirPattern = 'obj*';
        myFileExtension = '*.png';
    case 4
        myRootDir = './data/Cropped_ARgender';
        mySubDirPattern = '*';
        myFileExtension = '*.bmp';
end

% Note that you should use the same randmatrix
% when you iterate all the input images and extract descriptors

[feature, Y_range] = recurse_sub(myRootDir, mySubDirPattern, myFileExtension);
%% generate the random matrix
randmatrix = randn(dims, size(feature, 1));
l2norms = sqrt(sum(randmatrix.*randmatrix, 2) + eps);
randmatrix = randmatrix./repmat(l2norms, 1, size(randmatrix, 2));
%% generate random feature descriptors 
randomfeature = randmatrix*feature;
Y = randomfeature; 
fn = strcat('data/myYaleB.mat' );
save(fn, 'Y', 'Y_range');

toc