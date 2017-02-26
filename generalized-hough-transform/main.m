img = imread('./PA2-testimages/block.tif');
BW = edge(img,'Canny');

[Gmag,Gdir] = imgradient(img);
% imshow(img);
% imshow(Gmag);
% imshow(Gdir);

% Use the centroid as the reference point
stat = regionprops(BW,'centroid');
ref = round(stat.Centroid);
% BW(ref(1),ref(2)) = 1;
% imshow(BW);

% Iterate through all contour points
% For each point get three piece of information
count = 1;
contourPoints = zeros(sum(sum(BW == 1)), 3);
contourReference = zeros(sum(sum(BW == 1)), 3);
for i = 1 : size(BW, 1)
    for j = 1 : size(BW, 2) 
        if (BW(i,j) == 1) 
           Gdir(i, j) = round (Gdir(i, j) / 2) * 2;
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

% Form an accumulator array
accumulator = zeros(size(img));
for i = 1 : size(contourPoints,1) 
    binIndex = (contourPoints(i, 3) + 180) / 2 + 1;
    for j = 1 : bin_count(binIndex)
        deltaY = rTable(binIndex, j, 1);
        deltaX = rTable(binIndex, j, 2);
        targetY = round(contourPoints(i, 1) + deltaY);
        targetX = round(contourPoints(i, 2) + deltaX);
        if (targetY >= 1 && targetY <= size(accumulator, 1))
            if (targetX >= 1 && targetX <= size(accumulator, 2))
                accumulator(targetY, targetX) = accumulator(targetY, targetX) + 1;
            end
        end
    end
end

imshow(accumulator/255);

