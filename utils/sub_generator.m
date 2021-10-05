clear all; close all;
cd '/home/long/Desktop/Long/Recognition and Classification/SRWC_long/data/Cropped_Yale_PhiHat_Large';
listing  = dir('*.png');
numberOfFiels = size(listing,1);
for i=1:1:numberOfFiels
    name = listing(i).name;
    folder = name(1:7);
    if exist(folder,'dir') == 0
        mkdir(folder);
    end
    folder = strcat(folder,'/',name);
    movefile(name,folder);
end

% for i=1:17
%     for j=80*(i-1)+1:80*i
%         name = listing(j).name;
%         folder = strcat('flower_',num2str(i));
%         if exist(folder, 'dir') ==0
%             mkdir(folder);
%         end
%         folder = strcat(folder,'/',name);
%         movefile(name,folder);
%     end
% end

