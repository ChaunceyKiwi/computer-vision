img = imread('Lenna.png');
img = rgb2gray(img);

imtool(img);

filter = [0,1,0;1,-4,1;0,1,0];
filter2 = [1,0,1;0,-4,0;1,0,1];

img1 = conv2(double(img),filter);
img2 = conv2(double(img),filter2);

imshow(img1);
imtool(img2);