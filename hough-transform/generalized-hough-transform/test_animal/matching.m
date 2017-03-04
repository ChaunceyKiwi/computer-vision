function pos = matching(testImage, rTable, bin_count, rotation, scale)
deg_div = 2;

% Form an accumulator array
img_hsv = rgb2hsv(testImage);

img_mask = img_hsv(:,:,2);
img_mask(img_mask < 80/255) = 0;
img_mask(img_mask >= 80/255) = 1;
img_mask = 1 - bwareaopen(1-img_mask, 300);

img_gray = rgb2gray(testImage);
img_gray(img_mask == 0) = 0;
BW = edge(img_gray,'Canny');
BW = bwareaopen(BW, 30);

[~,Gdir] = imgradient(img_gray);

% Iterate through all contour points
% For each point get three piece of information
count = 1;
contourPoints = zeros(sum(sum(BW == 1)), 3);
for i = 1 : size(BW, 1)
    for j = 1 : size(BW, 2) 
        if (BW(i,j) == 1) 
           Gdir(i, j) = round ((Gdir(i, j) + rotation) / deg_div) * deg_div;
           if ((Gdir(i ,j)) >= 180) 
               Gdir(i,j) =  Gdir(i,j) - 360;           
           elseif ((Gdir(i ,j)) < -180) 
               Gdir(i,j) =  Gdir(i,j) + 360; 
           end
           contourPoints(count, :) = [i, j, Gdir(i, j)];
           count = count + 1;
        end
    end
end

% vote for possible center
accumulator = zeros(size(img_gray));
rotation_rad = degtorad(-rotation);
rotate_matrix = [cos(rotation_rad), -sin(rotation_rad); ...
    sin(rotation_rad), cos(rotation_rad)];
for i = 1 : size(contourPoints,1) 
    binIndex = (contourPoints(i, 3) + 180) / deg_div + 1;
    for j = 1 : bin_count(binIndex)
        deltaY = rTable(binIndex, j, 1);
        deltaX = rTable(binIndex, j, 2);
        delta = rotate_matrix * [deltaY; deltaX] / scale;
        targetY = round(contourPoints(i, 1) + delta(1));
        targetX = round(contourPoints(i, 2) + delta(2));
        if (targetY >= 1 && targetY <= size(accumulator, 1))
            if (targetX >= 1 && targetX <= size(accumulator, 2))
                accumulator(targetY, targetX) = accumulator(targetY, targetX) + 1;
            end
        end
    end
end

% find largest values in the array as the locations of the objects desired
threshold = 8;
[row,col] = find(accumulator >= threshold);
pos = [row, col];