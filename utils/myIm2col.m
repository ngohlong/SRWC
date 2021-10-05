function [blocks,idx] = myIm2col(I, bb, step)
% Transform input image blocks to column vector
idxMat = zeros(size(I(1:end-bb+1, 1:end-bb+1)));
idxMat([1:step:end-1,end], [1:step:end-1,end]) = 1;
idx = find(idxMat);

[rows, cols] = ind2sub(size(idxMat), idx);
blocks = zeros(bb*bb, length(idx));

for ii=1:length(rows)
    row = rows(ii);
    col = cols(ii); 
    blk = I(row:row+bb-1, col:col+bb-1);
    blocks(:,ii) = blk(:);
end
    



