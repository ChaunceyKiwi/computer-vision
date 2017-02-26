function [rTable, bin_count] = build_RTable(img)
img_grey = rgb2gray(img);
BW = edge(img_grey,'Canny');

[~, Gdir] = imgradient(img_grey);
% imshow(img);
% imshow(Gmag);
% imshow(Gdir);

% Use the centroid as the reference point
ref = round([size(img_grey, 1)/2, size(img_grey, 2)/2]);
% BW(ref(1),ref(2)) = 1;
imshow(BW);

% Iterate through all contour points
% For each point get three piece of information
count = 1;
contourPoints = zeros(sum(sum(BW == 1)), 3);
contourReference = zeros(sum(sum(BW == 1)), 3);
for i = 1 : size(BW, 1)
    for j = 1 : size(BW, 2) 
        if (BW(i,j) == 1) 
           Gdir(i, j) = round (Gdir(i, j) / 2) * 2;
           if ((Gdir(i ,j)) == 180) 
               Gdir(i,j) = -180; 
           end
           contourPoints(count, :) = [i, j, Gdir(i, j)];
           contourReference(count, :) = [ref(1) - i, ref(2) - j, Gdir(i, j)];
           count = count + 1;
        end
    end
end

% Build R-table, assume the vertors in each row is no more than 100 
bin_size = 180;
bin_value = zeros(bin_size, 1);
bin_count = zeros(bin_size, 1);
rTable = zeros(bin_size, 100, 3);
for i =  1 : bin_size
    bin_value(i) = -180 + (i - 1) * 2;
end

for i = 1 : size(contourReference,1) 
    binIndex = (contourReference(i, 3) + 180) / 2 + 1;
    bin_count(binIndex) = bin_count(binIndex) + 1;
    rTable(binIndex, bin_count(binIndex), :) = contourReference(i, :);
end
