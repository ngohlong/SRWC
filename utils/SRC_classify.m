function [pred acc X E] = SRC_classify(mode, IMG_PATH, type, D1, D2, D1_label, D2_label, groundTruth, opts)

% Description       : SRC
%     INPUT:
%       dataset: name of the dataset stored in 'data', excluding '.mat'
%       N_trn: number of training images per class
%       lambda : regularization parameter lambda
% -----------------------------------------------
% Author:
% -----------------------------------------------

%%
switch mode
    case 1
        dict = normc(D1);
        label = D1_label;
    case 2
        dict = normc(D2);
        label = D2_label;
end
opts.nb_atom = numel(find(label == 1));
img_dir = dir(fullfile(IMG_PATH, type));
img_num = length(img_dir);
pred = zeros(1,img_num);
%%
for i = 1:img_num
    addpath(IMG_PATH);
    file_name = img_dir(i).name;
    [ind, X, E] = SRC_coeff(file_name, dict, label, opts);
    pred(i) = ind;
end

acc = calc_acc(pred, groundTruth(:, 1));
end
