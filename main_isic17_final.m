% binary classification on ISIC 2017 database: 521 melanoma, 2229 benign  

% profile on
clear all;
close all;
tic;
fprintf('Start at %s\n', datestr(now,'dd-mmm-yyyy HH:MM:SS'))

addpath(genpath('utils'));
addpath('temp');

dataset = 'myISIC2018_NoVF_crop500x500';
opts.no_train_p = 0.9; % Numbers of training samples from each class (in percentage)
t = 1;

for lp = t:-1:1
    
    %% ===== Split the data into training set and testing set =================
    [dataset, Yw_train, label_w_train, Yw_test, label_w_test] = train_test_split(dataset, opts.no_train_p);
    
    range_w_train = label_to_range(label_w_train);
    range_w_test = label_to_range(label_w_test);
    C = numel(range_w_train) - 1;
    
    %----- balance the classes of the dictionary -----
    tmp = 2;
    Yw_train = Yw_train(:, 1:round(tmp*range_w_train(2)));
    range_w_train = [0, range_w_train(2), round(tmp*range_w_train(2))];
    Yw_test = Yw_test(:, 1:round(tmp*range_w_test(2)),:);
    range_w_test = [0, range_w_test(2), round(tmp*range_w_test(2))];
    label_w_test = range_to_label(range_w_test);
    
    %% ===== Classification ===================================================
    fprintf('===== Executing SRWC... =====\n');
    opts.lambda = 0.001;
    [pred_w, acc_srwc, Xw, Ew] = SRC_wrapper(Yw_train, range_w_train, Yw_test, ...
        range_w_test, opts);
    fprintf('Recognition rate of SRWC = %.2f %% \n', acc_srwc*100);
    
    %% Save results
    ACC(lp) = acc_srwc;
    
    %     clear('Y_train', 'Y_test', 'label_train', 'label_test', ...
    %         'Yw_train', 'label_w_train', 'Yw_test', 'label_w_test');
    
    %% Compute unnormalized/normalized confusion matrix and Precision-Recall
    % Test if it belongs to melanoma or not
    uC_test = confusionmat(label_w_test, pred_w);
    nC_test = uC_test./repmat(sum(uC_test,2),1,size(uC_test,2));
    nC_test = nC_test*100;
    tp = uC_test(1, 1);
    fp = uC_test(2, 1);
    fn = uC_test(1, 2);
    tn = uC_test(2, 2);
    confM(lp,:) = [tp, fp, fn, tn];
%     fp = sum(uC_test(:,1)) - tp;
%     fn = sum(uC_test(1,:))-tp;
%     tn = sum(sum(uC_test,1))-fn-fp-tp;

    precision = tp/(tp + fp); % also called as  Positive Predictive Value (PPV)
    PRE(lp) = precision;
    recall = tp/(tp + fn); % also called as True Positive Rate (TPR) or Sensitivity
    SEN(lp) = recall;
    specificity = tn/(tn + fp); % also called True Negative Rate (TNR)
    SPE(lp) = specificity;
    F1_tmp = 2*precision*recall/ (precision + recall); %F-measure or F-score
    F1(lp) = F1_tmp;
    JCC(lp) = tp/(tp+fp+fn); % Jaccard's coefficient of community = F1/(2-F1)
    MCC(lp) = (tp*tn-fp*fn)/sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn));
    
    REC = 100*[ACC', SPE', SEN', PRE', F1', JCC'];
    %     clear('Y_train', 'Y_test', 'label_train', 'label_test', ...
    %         'Yw_train', 'label_w_train', 'Yw_test', 'label_w_test');
    fprintf('End of loop %d %\n', lp);
    fprintf('\n');
end % lp

avg_srwc = mean(ACC);                  % average recognition rate
max_srwc = max(ACC);                   % maximum recognition rate
min_srwc = min(ACC);                   % minimum recognition rate
% std_srwc = std(rec_srwc);                   % standard deviation of the recognition rate
avg_precision = mean(PRE);
avg_sensitivity = mean(SEN);
avg_specificity = mean(SPE);
avg_F1 = mean(F1);
avg_JCC = mean(JCC);

avg_results = round(10000*[avg_srwc, avg_specificity, avg_sensitivity, avg_precision, avg_F1, avg_JCC])/100;

toc;
% profile viewer
fprintf('Finish at %s\n', datestr(now,'dd-mmm-yyyy HH:MM:SS'))