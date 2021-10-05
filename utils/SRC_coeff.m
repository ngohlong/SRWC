function [pred, X, residual] = SRC_coeff(file_name, dict, label, opts)
%This function recognize the face image with the first method "Use the whole image for dictionary training".
%Author

%   file_name: the name of test image;
%   dict:      the dictionary you want to use. The size of atom in dictionary should be the same with test image;
%   param:     some parameters used by the function;
%              no_people:   number of people in the dictionary;
%              no_atom:     number of atoms per people in the dictionary.
%              support:     number of the non zero elements in the coefficient;
%              display:     display=1 to show the images;
%              save:        if save=1, the file will be stored.
%              sample:      random sample matrix
%   pred:         the identify of the test image;
%   coeff:     the coefficient for the test image;
%Caution:

%read in the image
img = imread(file_name);
if size(img, 3)>1;
    img=rgb2gray(img);
end

% use the omp for sparse coding
[cA1,~,~,~] = dwt2(img,'db1'); %daubechies transformation
bb = 8; step = 2;
sigma = 25/255;
C = 1.15;
errorGoal = sigma*C;
opts.overlap = 0;
% C = double(cA1 * cA1');
% [V, D] = eig(C);
% D = diag(D); % perform PCA on features matrix
% D = cumsum(D) / sum(D);
% k = find(D >= 1e-3, 1); % ignore 0.01% energy
% V_pca = V(:, k:end); % choose the largest eigenvectors' projection
% cA1_pca = V_pca' * cA1;
% img = normc(cA1_pca);
% img = cA1_pca(:);

%%
if opts.overlap == 1
    [blocks, idx] = myIm2col(cA1, bb, step); %% build  over-lapping patches for each image.
else
    blocks = im2col(cA1, [bb bb], 'distinct'); % build non over-lapping patches for each image.
end
blocks = normc(blocks);
% X = OMP(dict, blocks, opts.L);
for jj=1:10000:size(blocks,2)
    jump_size = min(jj+10000-1, size(blocks, 2));
    %     X = OMPerr(dict, blocks(:, jj:jump_size), errorGoal);
    X(:, jj:jump_size) = OMP(dict, blocks(:,jj:jump_size), opts.L);
%     X = myOMP(blocks(:,jj:jump_size), dict, opts.L);
%     blk(:, jj:jump_size) = dict*X;
end

%% identify the test image
%construct a matrix that select coefficient just like function deta
% m_coeff=zeros(size(dict,2), 2);
% for pred=1:2
%     m_coeff(1 : opts.nb_atom, 1) = X(1 : opts.nb_atom);
%     m_coeff(opts.nb_atom+1 : end-opts.nb_atom, 2) = X(opts.nb_atom+1 : end-opts.nb_atom);
% end
% m_img = img*ones(1, 64);
% residual = zeros(1, 2);
% % tmp = m_img-dict*m_coeff;
%
% for pred = 1:2
%     residual(pred) = norm(tmp(:,pred),2);
% end
% [c, pred] = min(residual);
% c = c/norm(img);
D_range = label_to_range(label);
residual = zeros(2, size(blocks, 2));

for i = 1:2
    Xi = get_block_row(X, i, D_range);
    Di = get_block_col(dict, i, D_range);
    R = blocks - Di*Xi;
    residual(i,:) = sum(R.^2, 1);
end

[c, pred] = min(residual);
c = c/norm(cA1);

if opts.display==1
    colormap(gray);
    bar(full(X));
    title('coefficient');
    if opts.save==1
        saveas(gcf, file_name(1:20), 'jpg');
    end
end
disp(sprintf('reconstruction error normalized by orignal image is: %f .\n', c));