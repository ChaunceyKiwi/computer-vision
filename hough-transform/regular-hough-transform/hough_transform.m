% edge detection
img = rgb2gray(imread('./lines/line1.png'));
img = edge(img, 'canny');
img = imfill(img,'holes');
img = bwmorph(img,'thin',inf);

% get edge points
count = 1;
edgePoint = zeros(sum(img(:) == 1), 2);
for i = 1 : size(img, 1)
    for j = 1 : size(img, 2)
       if (img(i, j) == 1) 
           edgePoint(count, :) = [i, j];
           count = count + 1;
       end
    end
end

% Form an accumulator array and insert data into it
accumulator = zeros(1000, 4000);
for i = 1 : size(edgePoint, 1)
    y = edgePoint(i, 1);
    x = edgePoint(i, 2);
    for m = 1 : size(accumulator, 2)
        slope = (m - 2000) / 200; 
        c = round(-x * slope + y);
        if (c >= 1 && c <= size(accumulator, 1))
            accumulator(c, m) = accumulator(c, m) + 1;
        end
    end
end

% Find maximum and draw plot
[c, m] = find(accumulator == max(accumulator(:)));
m = (m - 2000) / 200;
x_min = min(edgePoint(:,2));
x_max = max(edgePoint(:,2));
x = x_min : 1 : x_max;
y = x * m(1) + c(1);
imshow(img);
line(x, y, 'LineWidth',1);