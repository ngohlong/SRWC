%function [imgMat, imgMat_range] = recurse_sub(myRootDir, mySubDirPattern, myFileExtension)
% Start with a folder and get a list of all subfolders.
% Finds all images in that folder and all of its subfolders
clear all; close all; 

myRootDir = './data/Cropped_ARgender';
mySubDirPattern = '*';
myFileExtension = '*.bmp';
        
mySubDirs = dir(fullfile(myRootDir, mySubDirPattern));
mySubDirs = mySubDirs(~ismember({mySubDirs.name},{'.','..'}));
numSubDirs = length(mySubDirs);
mat_train = []; mat_test = [];
train_range = 0; test_range = 0;
cur_train = 0; cur_test = 0;
%recurse sub-directories
for i = 1:numSubDirs
    sub_train = [];
    if (mySubDirs(i).isdir == 1) %myRootDir might have files as well
        
        currentSubDir = fullfile(myRootDir, mySubDirs(i).name);
        
        %get all filenames that match myFilePattern
        myFiles = dir(fullfile(currentSubDir, myFileExtension));
        numFiles = length(myFiles);
        N_train_i = numFiles/2; N_test_i = numFiles - N_train_i;
        %read all files in sub directory
        for k = 1:N_train_i
            trainName = myFiles(k).name;
            fulltrainName = fullfile(currentSubDir, trainName);
            X = imread(fulltrainName);
            if size(X,3)==3
                X = rgb2gray(X);
            end
            [cAx,cH,cV,~] = dwt2(X,'db1'); %daubechies transformation
            tmpX = double(cAx(:)); 
            sub_train(:,k) = tmpX;
        end
        mat_train = [mat_train sub_train];
        train_range(i+1) = train_range(i)+k;
        label_w_train(:, cur_train + 1: cur_train + N_train_i) = i*ones(1, N_train_i);
        cur_train = cur_train + N_train_i;
        
        for j = 1+N_train_i:numFiles
            testName = myFiles(j).name;
            fulltestName = fullfile(currentSubDir, testName);
            Y = imread(fulltestName);
            if size(Y,3)==3
                Y = rgb2gray(Y);
            end
            [cAy,cH,cV,~] = dwt2(Y,'db1'); %daubechies transformation
            tmpY = double(cAy(:)); 
            sub_test(:,j-N_train_i) = tmpY;
        end
        mat_test = [mat_test sub_test];
        test_range(i+1) = test_range(i)+k;
        label_w_test(:, cur_test + 1: cur_test + N_test_i) = i*ones(1, N_test_i);
        cur_test = cur_test + N_test_i;
    end
end
mat = [mat_train mat_test];
% % PCA dimensionality reduction for ARgender
% C_train = double(mat_train * mat_train');
% [V_train, D_train] = eig(C_train);
% D_train = diag(D_train); % perform PCA on features matrix
% D_train = cumsum(D_train) / sum(D_train);
% k = find(D_train >= 1.105e-3, 1); % ignore 0.1% energy
% V_train_pca = V_train(:, k:end); % choose the largest eigenvectors' projection
% mat_train_pca = V_train_pca' * mat_train;
% Yw_train = mat_train_pca; 
% 
% C_test = double(mat_test * mat_test');
% [V_test, D_test] = eig(C_test);
% D_test = diag(D_test); % perform PCA on features matrix
% D_test = cumsum(D_test) / sum(D_test);
% k = find(D_test >= 1.34e-3, 1); % ignore 0.1% energy
% V_test_pca = V_test(:, k:end); % choose the largest eigenvectors' projection
% mat_test_pca = V_test_pca' * mat_test;
% Yw_test = mat_test_pca; 

C = double(mat * mat');
[V, D] = eig(C);
D = diag(D); % perform PCA on features matrix
D = cumsum(D) / sum(D);
k = find(D >= 1e-3, 1); % ignore 0.1% energy
V_pca = V(:, k:end); % choose the largest eigenvectors' projection
mat_pca = V_pca' * mat;
Yw_train = mat_pca(:,1:length(mat_pca)/2);
Yw_test = mat_pca(:,1+length(mat_pca)/2:end);

fn = strcat('data/myARgender_Wavelet1_t.mat');
save(fn, 'label_w_train', 'label_w_test', 'Yw_train', 'Yw_test');

%end