img = double(rgb2gray(imread('lenna.tif')));
img_deri = xcorr2(img,[0,1,0;1,-4,1;0,1,0]);
threshold = 30;
imshow(img_deri < threshold);