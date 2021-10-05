function [dataset, Y_train, label_train, Y_test, label_test, Yw_train, ...
    label_w_train, Yw_test, label_w_test] = pickTrainTest_single(dataset, N_train_c)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ================== block: random projection ==========================
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     fprintf('random projection...')
%     d_new = 3000;
%     A = randn(d_new, size(Y,1))        ;
%     Y = A*Y;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------end of block: random projection ----------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch dataset
    case 'myYaleB'
        myRootDir = './CroppedYale';
        mySubDirPattern = 'yale*';
        myFileExtension = '*.pgm';
        
    case 'myAR'
        myRootDir = './CroppedAR';
        mySubDirPattern = '*';
        myFileExtension = '*.bmp';
        
    case 'coil-20'
        myRootDir = './coil-20-proc';
        mySubDirPattern = 'obj*';
        myFileExtension = '*.png';
        
    case 'myCoil-100'
        myRootDir = './coil-100';
        mySubDirPattern = 'obj*';
        myFileExtension = '*.png';
        
    case 'Caltech101'
        myRootDir = './101_ObjectCategories';
        mySubDirPattern = '*';
        myFileExtension = '*.jpg';
    case 'myFlower17'
        myRootDir = './myFlower17';
        mySubDirPattern = 'flower_*';
        myFileExtension = '*.jpg';
    case 'ADL'
        myRootDir = './ADL/Kidney';
        mySubDirPattern = '*';
        myFileExtension = '*.jpg';
end

[Y, Y_range] = recurse_sub(myRootDir, mySubDirPattern, myFileExtension);
[Yw, Yw_range] = recurse_dwt_sub(myRootDir, mySubDirPattern, myFileExtension);

% Y = normc(Y);
% Yw = normc(Yw);
d = size(Y,1); 
dw = size(Yw,1);
%=== Test mode ========================
if ~exist('Y_range', 'var')
    Y_range = label_to_range(label);
end
%=====================================
C = numel(Y_range) - 1;
N_total = Y_range(C+1);
N_train = C*N_train_c;
N_test = N_total - N_train;

Y_train = zeros(d, N_train);
Y_test = zeros(d, N_test);
label_train = zeros(1, N_train);
label_test = zeros(1, N_test);

Yw_train = zeros(dw, N_train); 
Yw_test = zeros(dw, N_test); 
label_w_train = zeros(1, N_train);
label_w_test = zeros(1, N_test);

% Ycbn_train = zeros(dw, N_train); 
% Ycbn_test = zeros(dw, N_test);
%%
cur_train = 0;
cur_test = 0;
for c = 1: C
    Yc = get_block_col(Y, c, Y_range);
    Ywc = get_block_col(Yw, c, Yw_range);
%     Ycbnc = get_block_col(Ycbn, c, Yw_range);
    
    N_total_c = size(Yc, 2);
    N_test_c = N_total_c - N_train_c;
    label_train(:, cur_train + 1: cur_train + N_train_c) = c*ones(1, N_train_c);
    label_test(:, cur_test + 1: cur_test + N_test_c) = c*ones(1, N_test_c);
    
    label_w_train(:, cur_train + 1: cur_train + N_train_c) = c*ones(1, N_train_c);
    label_w_test(:, cur_test + 1: cur_test + N_test_c) = c*ones(1, N_test_c);
    
    idx = randperm(N_total_c); %Random permutation
    
    Y_train(:, cur_train + 1: cur_train + N_train_c) = Yc(:, idx(1: N_train_c));
    Y_test(:, cur_test + 1: cur_test + N_test_c) = Yc(:, idx(N_train_c + 1: end));
    
    Yw_train(:, cur_train + 1: cur_train + N_train_c) = Ywc(:, idx(1: N_train_c));
    Yw_test(:, cur_test + 1: cur_test + N_test_c) = Ywc(:, idx(N_train_c + 1: end));
%     
%     Ycbn_train(:, cur_train + 1: cur_train + N_train_c) = Ycbnc(:, idx(1: N_train_c));
%     Ycbn_test(:, cur_test + 1: cur_test + N_test_c) = Ycbnc(:, idx(N_train_c + 1: end));
    
    cur_train = cur_train + N_train_c;
    cur_test = cur_test + N_test_c;
end
% Y_train = normc(Y_train);
% Y_test = normc(Y_test);
% Yw_train = normc(Yw_train);
% Yw_test = normc(Yw_test);
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


