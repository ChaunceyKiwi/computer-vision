function pos = matching(testImage, rTable, bin_count, rotation)
% Form an accumulator array
img_grey = rgb2gray(testImage);
BW = edge(img_grey,'Canny');
[~,Gdir] = imgradient(img_grey);

% Iterate through all contour points
% For each point get three piece of information
count = 1;
contourPoints = zeros(sum(sum(BW == 1)), 3);
for i = 1 : size(BW, 1)
    for j = 1 : size(BW, 2) 
        if (BW(i,j) == 1) 
           Gdir(i, j) = round ((Gdir(i, j) + rotation) / 2) * 2;
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

accumulator = zeros(size(img_grey));
rotation_rad = degtorad(-rotation);
rotate_matrix = [cos(rotation_rad), -sin(rotation_rad); ...
    sin(rotation_rad), cos(rotation_rad)];
for i = 1 : size(contourPoints,1) 
    binIndex = (contourPoints(i, 3) + 180) / 2 + 1;
    for j = 1 : bin_count(binIndex)
        deltaY = rTable(binIndex, j, 1);
        deltaX = rTable(binIndex, j, 2);
        delta = rotate_matrix * [deltaY; deltaX];
        targetY = round(contourPoints(i, 1) + delta(1));
        targetX = round(contourPoints(i, 2) + delta(2));
        if (targetY >= 1 && targetY <= size(accumulator, 1))
            if (targetX >= 1 && targetX <= size(accumulator, 2))
                accumulator(targetY, targetX) = accumulator(targetY, targetX) + 1;
            end
        end
    end
end

threshold = 25;
accumulator(accumulator < threshold) = 0;
[row,col] = find(accumulator > threshold);
pos = [row, col];