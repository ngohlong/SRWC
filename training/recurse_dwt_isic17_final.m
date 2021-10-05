% Start with a folder and get a list of all subfolders.
% Finds all images in that folder and all of its subfolders
% mix the training, validation and test set together to obtain two classes
% benign and malignant
tic;
clear all; close all;
addpath(genpath('data'));
addpath('data/ISIC17');
dataset = 'myISIC';

%% load dictionary
data_fn = fullfile('data', strcat(dataset, '_training_cr80_256x192.mat'));
load(data_fn);
Y_train = Y; Y_train_label = Y_label;
Y_train_range = label_to_range(Y_train_label);
%% load validation images
data_fn = fullfile('data', strcat(dataset, '_validation_cr80_256x192.mat'));
load(data_fn);
Y_val = Y; Y_val_label = Y_label;
Y_val_range = label_to_range(Y_val_label);

%% load test images
data_fn = fullfile('data', strcat(dataset, '_test_cr80_256x192.mat'));
load(data_fn);
Y_test = Y; Y_test_label = Y_label;
Y_test_range = label_to_range(Y_test_label);

%% load additional test images
data_fn = fullfile('data', strcat(dataset, '_test_cr80plus_256x192.mat'));
load(data_fn);
Y_plus = Y; Y_plus_label = Y_label;

%% Mix the three sets together
tmp1 = Y_train_range(2);
Y_train_mela = Y_train(:,1:tmp1,:); Y_train_benign = Y_train(:,tmp1+1:end,:);
Y_train_mela_label = Y_train_label(:,1:tmp1,:); Y_train_benign_label = Y_train_label(:,tmp1+1:end,:);

tmp2 = Y_val_range(2);
Y_val_mela = Y_val(:,1:tmp2,:); Y_val_benign = Y_val(:,tmp2+1:end,:);
Y_val_mela_label = Y_val_label(:,1:tmp2,:); Y_val_benign_label = Y_val_label(:,tmp2+1:end,:);

tmp3 = Y_test_range(2);
Y_test_mela = Y_test(:,1:tmp3,:); Y_test_benign = Y_test(:,tmp3+1:end,:);
Y_test_mela_label = Y_test_label(:,1:tmp3,:); Y_test_benign_label = Y_test_label(:,tmp3+1:end,:);

Y_total = [Y_train_mela, Y_val_mela, Y_test_mela, Y_plus(:,1:1708,:), Y_train_benign, Y_val_benign, Y_test_benign];
Yw_label = [Y_train_mela_label, Y_val_mela_label, Y_test_mela_label, Y_plus_label(1:1708)...
            Y_train_benign_label, Y_val_benign_label, Y_test_benign_label];
Yw_range = label_to_range(Yw_label);
%% PCA dimensionality reduction
imgMat = Y_total;
C = double(imgMat * imgMat');
[V, D] = eig(C);
D = diag(D); % perform PCA on features matrix
D = cumsum(D) / sum(D);
k = find(D >= 1e-3, 1); % ignore 0.1% energy
V_pca = V(:, k:end); % choose the largest eigenvectors' projection
imgMat_pca = V_pca' * imgMat;
Yw = imgMat_pca; 

%% save data
fn = strcat('data/myISICcr80plus256_Wavelet1.mat');    
save(fn, 'Yw', 'Yw_range', '-v7.3');
toc;
% end