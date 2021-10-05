function [dataset, Yw_train, label_w_train, Yw_test, label_w_test] = train_test_split(dataset, N_train)

% function [dataset, Y_train, Y_test, label_train, label_test, Yw_train, ...
%     label_w_train, Yw_test, label_w_test] = train_test_split(dataset, N_train)

%myrng();

fprintf('Picking Train and Test set of %s database...\n', dataset);
switch dataset
    case 'myARgender1'
        ARgender_fn = fullfile('data', 'myARgender_300.mat');%Build the file name from parts
        load(ARgender_fn);
        Y_train = normc(double(Y_train));
        train_range = label_to_range(label_train);
        Y_train = PickDfromY(Y_train, train_range, N_train);
        C = numel(train_range) - 1;
        label_train = range_to_label(N_train*(0:C));
        Y_test = normc(double(Y_test));
        
        ARgender_W_fn = fullfile('data', 'myARgender_PCA_Wavelet1.mat');%Build the file name from parts
        load(ARgender_W_fn);
        Yw_train = normc(double(Yw_train));
        train_range_w = label_to_range(label_w_train);
        Yw_train = PickDfromY(Yw_train, train_range_w, N_train);
        C = numel(train_range_w) - 1;
        label_w_train = range_to_label(N_train*(0:C));
        Yw_test = normc(double(Yw_test));
        
    case 'myARreduce'
        dataset = 'test mode';
        load('data/AR_EigenFace.mat');
        % ---------------  -------------------------
        Y_train = normc(tr_dat);
        Y_test = normc(tt_dat);
        % ---------------  -------------------------
        label_train = trls;
        label_test = ttls;
        
    case 'myFlower102'
        dataset = 'myFlower102';
        % load(fullfile('data', dataset);
        load(fullfile('data',strcat(dataset, '.mat')));
        
        Y_train = normc(double(Y_train));
        label_train = double(label_train);
        Y_test = normc(double(Y_test));
        
        Yw_train = 0;
        Yw_test = 0;
        label_w_train = 0;
        label_w_test = 0;
        
    case 'myCIFAR'
        cifar_fn = fullfile('data', 'myCIFAR_Wavelet1.mat'); %Build the file name from parts
        load(cifar_fn);
        Yw_train = normc(Yw_train);
        label_w_train = double(label_train);
        Yw_test = normc(Yw_test);
        label_w_test = double(label_test);
        
        Y_train = 0;
        label_train = 0;
        Y_test = 0;
        label_test = 0;
        
%     case 'myISIC2018_NoVF_crop500x500'
%         [Yw_train, label_w_train, Yw_test, label_w_test] = ...
%                                         pickTrainTest_3(dataset, N_train);
        
    otherwise
        if N_train <= 1
            [Yw_train, label_w_train, Yw_test, label_w_test] = ...
                                        pickTrainTest_3(dataset, N_train);
        else
            [Yw_train, label_w_train, Yw_test, label_w_test] =...
                                        pickTrainTest_2(dataset, N_train);
%           [Y_train, label_train, Y_test, label_test, Yw_train, ...
%label_w_train, Yw_test, label_w_test] = pickTrainTest_2(dataset, N_train);
        end
        
end
fprintf('DONE\n');
end
