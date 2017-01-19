% Demo of histogram equalization
img = imread('dark.tif');
[height, width] = size(img);
numOfPixels = height * width;
level = 256;

% Calculate frequency histogram and probability histogram
freq = zeros(level, 1);
prob = zeros(level, 1);
for i = 1 : height
    for j = 1 : width
        value = img(i, j);
        freq(value) = freq(value) + 1;
        prob(value) = freq(value) / numOfPixels;
    end
end

% Calculate culmulative probability histogram
prob_cum = zeros(level, 1);
sum = 0;
for i = 1 : level 
    if(i == 1)
        prob_cum(i) = prob(i);
    else
        prob_cum(i) = prob_cum(i - 1) + prob(i);
    end
end
output = ceil(prob_cum * level) - 1;
output(output < 0) = 0;

% Calculate new pixel values
newImg = img;
for i = 1 : height
    for j = 1 : width
        newImg(i, j) = output(newImg(i, j));
    end
end

% Result
subplot(2,2,1), imhist(img);
subplot(2,2,2), imshow(img);
subplot(2,2,3), imhist(newImg);
subplot(2,2,4), imshow(newImg);