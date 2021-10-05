function [imgMat, imgMat_range] = recurse(myRootDir, mySubDirPattern, myFileExtension)
% Start with a folder and get a list of all subfolders.
% Finds all .bmp images in that folder and all of its subfolders

imgMat=[];
imgMat_range=0;
myFiles = dir(fullfile(myRootDir, myFileExtension));
numFiles = length(myFiles);
%read all files in directory
for k = 1:numFiles
    fileName = myFiles(k).name;
    fullFileName = fullfile(myRootDir, fileName);
    tmp = reshape(rgb2gray(imread(fullFileName)),[],1);
    imgMat(:,k) = tmp;
end

for i = 1:100
    imgMat_range(i+1) = imgMat_range(i) + 26;
end

end