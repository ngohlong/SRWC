function [H, W] = check_size_img(myRootDir, mySubDirPattern, myFileExtension)
% Start with a folder and get a list of all subfolders.
% Finds all .pgm images in that folder and all of its subfolders

mySubDirs = dir(fullfile(myRootDir, mySubDirPattern));
mySubDirs = mySubDirs(~ismember({mySubDirs.name},{'.','..'}));
numSubDirs = length(mySubDirs);
h = []; w = [];
%recurse sub-directories
for i = 1:numSubDirs
    if (mySubDirs(i).isdir == 1) %myRootDir might have files as well
        currentSubDir = fullfile(myRootDir, mySubDirs(i).name);
        
        %get all filenames that match myFilePattern
        myFiles = dir(fullfile(currentSubDir, myFileExtension));
        numFiles = length(myFiles);
        
        %read all files in sub directory
        for k = 1:numFiles
            fileName = myFiles(k).name;
            fullFileName = fullfile(currentSubDir, fileName);
            X = imread(fullFileName);
            h = [h size(X,1)]; w = [w size(X,2)];
        end
    end
end
H = min (h); W = min (w);
end