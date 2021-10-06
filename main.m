tic;
clear all;
close all;

addpath(genpath('utils'));
addpath('temp');

dataset = 'myYaleB_Wavelet1'; % choose the dataset to run
N_train = 30; % numbers of training samples from each class

for lp = 10:-1:1 % number of loops
    %% ===== Split the data into training set and testing set =======
    [dataset, Yw_train, label_w_train, Yw_test, label_w_test] = ...
        train_test_split(dataset, N_train);
    
    range_w_train = label_to_range(label_w_train);
    range_w_test = label_to_range(label_w_test);
    
    %% ===== Classification =======================================
    
    fprintf('===== Executing SRWC...=====\n');
    lambda = 0.001;
    [pred_w, acc_srwc, Xw, Ew] = SRC_wrapper(Yw_train, range_w_train, ...
                                            Yw_test, range_w_test, lambda);
    fprintf('Recognition rate of SRWC = %.2f %% \n', acc_srwc*100);
    
    %% Save results
    rec_srwc(lp) = round(acc_srwc*10000)/100;
    %% Compute unnormalized/normalized confusion matrix and Precision-Recall
    fprintf('End of loop %d %\n',lp);
    fprintf('\n');
end % lp

avg_srwc = mean(rec_srwc);                      % average recognition rate
std_srwc = std(rec_srwc);     % standard deviation of the recognition rate
toc;