tic;
clear all;
close all;

addpath(genpath('LCKSVD'));  
addpath('LCKSVD/OMPbox');
addpath('LCKSVD/ksvdbox');  % add K-SVD box
addpath('FDDL');
addpath('utils');
addpath('temp');

dataset = 'mySVHN';
N_train = 160; %Numbers of training samples from each class

for lp = 10:-1:1
    sumd = 0;
    for lp2 = 1:1 %1:6
        for lp3 = 1:1
            sumd = sumd + 1;
            %% ===== Split the data into training set and testing set =================
%             [dataset, Y_train, Y_test, label_train, label_test, Yw_train, ...
%                 label_w_train, Yw_test, label_w_test] = train_test_split(dataset, N_train);
            [dataset, Yw_train, label_w_train, Yw_test, label_w_test] = ...
                                        train_test_split(dataset, N_train);
            
%             range_train = label_to_range(label_train);
%             range_test = label_to_range(label_test);
            
            range_w_train = label_to_range(label_w_train);
            range_w_test = label_to_range(label_w_test);
            
            %% ===== Classification ===================================================
%             fprintf('===== Executing SRC...=====\n');
%             % 0.001:yale, ar; 0.01: coil; 0.1:ARgender; 
%             lambda = 0.001; % regularization parameter lambda
%             [pred, acc_src, X, E] = SRC_wrapper(Y_train, range_train, Y_test, ...
%                 range_test, lambda);
%             fprintf('Recognition rate of SRC = %.2f %% \n', acc_src*100);
%             
%             fprintf('===== Executing LCKSVD...=====\n');
%             valpha = 2e-12;
%             vbeta = 4e-12;
%             k = 30;
%             sparsitythres = 30;
%             [acc_lcksvd, rt] = LCKSVD_wrapper(Yw_train, label_w_train, Yw_test, label_w_test,...
%                 k, sparsitythres, valpha, vbeta);
%             fprintf('Recognition rate of LCKSVD = %.2f %% \n', acc_lcksvd*100);
%             
%             fprintf('===== Executing FDDL ===================\n');
%             k = 10; %optimal 20
%             lambda1 = 0.001;
%             lambda2 = 0.05;
%             [acc_fddl, rt] = FDDL_wrapper(Y_train, label_train, Y_test , label_test, ...
%                 k, lambda1, lambda2);
%             fprintf('Recognition rate of FDDL = %.2f %% \n', acc_fddl*100);
            
            fprintf('===== Executing SRWC...=====\n');
            % % 0.001:yale, ar, ARgender; 0.01: coil;
            lambda = 0.0005;
            [pred_w, acc_srwc, Xw, Ew] = SRC_wrapper(Yw_train, range_w_train, Yw_test, ...
                range_w_test, lambda);
            fprintf('Recognition rate of SRWC = %.2f %% \n', acc_srwc*100);
            
            %% Save results
%             acc_0 = [acc_src acc_lcksvd acc_fddl acc_srwc];
%             rec_src(lp,sumd) = round(acc_src*10000)/100;
%             rec_lcksvd1(lp,sumd)=acc_lcksvd(1);
%             rec_lcksvd2(lp,sumd)=acc_lcksvd(2);
%             rec_fddl(lp,sumd)=acc_fddl;
            rec_srwc(lp,sumd) = round(acc_srwc*10000)/100;
        end % lp3
    end % lp2
    %% Compute unnormalized/normalized confusion matrix and Precision-Recall
%     uC(:,:,lp) = confusionmat(label_test,pred_w);
%     nC(:,:,lp) = uC(:,:,lp)./repmat(sum(uC(:,:,lp),2),1,size(uC(:,:,lp),2));
%     nC(:,:,lp) = nC(:,:,lp)*100;
%     for i = 1:size(uC,1)
%         tp(i) = uC(i,i,lp);
%         fp(i) = sum(uC(:,i,lp)) - tp(i);
%         fn(i) = sum(uC(i,:,lp)) - tp(i);
%         tn(i) = sum(sum(uC(:,:,lp))) - (tp(i)+fp(i)+fn(i));
%         precision(lp,i) = tp(i)/(tp(i)+fp(i));
%         recall(lp,i) = tp(i)/(tp(i)+fn(i));    
%     end
%     plotConfusion(label_test,pred);
%     plotConfusion(label_w_test,pred_w);
    
%     clear('Y_train', 'Y_test', 'label_train', 'label_test', ...
%         'Yw_train', 'label_w_train', 'Yw_test', 'label_w_test');
    fprintf('End of loop %d %\n',lp);
    fprintf('\n');
end % lp

% avg_src = mean(rec_src);                  % average recognition rate
% std_src = std(rec_src);                   % standard deviation of the recognition rate
%
% avg_lcksvd1 = mean(rec_lcksvd1);                  % average recognition rate
% std_lcksvd1 = std(rec_lcksvd1);                   % standard deviation of the recognition rate
% avg_lcksvd2 = mean(rec_lcksvd2);                  % average recognition rate
% std_lcksvd2 = std(rec_lcksvd2);                   % standard deviation of the recognition rate

% avg_fddl = mean(rec_fddl);                  % average recognition rate
% std_fddl = std(rec_fddl);                   % standard deviation of the recognition rate

avg_srwc = mean(rec_srwc);                  % average recognition rate
std_srwc = std(rec_srwc);                   % standard deviation of the recognition rate

% avg_uC = mean(uC,3);
% avg_nC = mean(nC,3);
% avg_precision = mean(mean(precision));
% avg_recall = mean(mean(recall));
% dlmwrite('results.txt',[avg_srwc avg_precision avg_recall]);
%dlmwrite('nC_Coil-100.txt',avg_nC);
%dlmread('nC_YaleB.txt',avg_nC);
toc;