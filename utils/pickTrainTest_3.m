function [Yw_train, label_w_train, Yw_test, label_w_test] = ...
                                        pickTrainTest_3(dataset, N_train_p)

data_dwt_fn = fullfile('data', strcat(dataset, '_Wavelet1.mat'));
load(data_dwt_fn);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ================== block: random projection ============================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     fprintf('random projection...')
%     d_new = 3000;
%     A = randn(d_new, size(Y,1))        ;
%     Y = A*Y;
% if strcmp(dataset, 'myCoil-100')
%     N_train_c = N_train_c + 5;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------end of block: random projection ----------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Yw = normc(Yw); 
dw = size(Yw,1);
%=== Test mode ========================
if ~exist('Yw_range', 'var')
    Yw_range = label_to_range(Yw_label);
end
%=====================================
C = numel(Yw_range) - 1;
Yw_train = []; 
Yw_test = []; 
label_w_train = [];
label_w_test = [];
%%
cur_train = 0;
cur_test = 0;
for c = 1: C
    Ywc = get_block_col(Yw, c, Yw_range);
    
    N_total_c = size(Ywc, 2);
    N_train_c = round(N_train_p * N_total_c);
    N_test_c = N_total_c - N_train_c;  
    
    label_w_train(:, cur_train + 1: cur_train + N_train_c) = c*ones(1, N_train_c);
    label_w_test(:, cur_test + 1: cur_test + N_test_c) = c*ones(1, N_test_c);
    
    idx = randperm(size(Ywc, 2)); %Random permutation
    
    Yw_train(:, cur_train + 1: cur_train + N_train_c, :) = Ywc(:, idx(1: N_train_c));
    Yw_test(:, cur_test + 1: cur_test + N_test_c, :) = Ywc(:, idx(N_train_c + 1: N_total_c));
    
    cur_train = cur_train + N_train_c;
    cur_test = cur_test + N_test_c;
end

Yw_train = normc(Yw_train);
Yw_test = normc(Yw_test);
% d_new = 3000;
% if size(Y,1) > d_new
%     fprintf('pca...')
%     [W,frac] = pcam(Y',d_new);
%     Y_train = normc((Y_train'*W)');
%     Y_test = normc((Y_test'*W)');
%     fprint    myRootDir = './CroppedAR';
% else
%         Y_train = normc(Y_train);
%         Y_test = normc(Y_test);
% end
end


