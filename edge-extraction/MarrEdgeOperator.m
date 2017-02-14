img = double(rgb2gray(imread('lenna.tif')));

size = 10;
h = fspecial('gaussian', size, 1);

% Laplacian of Gaussian
LOG = xcorr2(h,[0,1,0;1,-4,1;0,1,0]);

% image of Kernel
[X,Y] = meshgrid(-size/2-1:size/2,-size/2-1:size/2);
Z = LOG;
figure
surface(X,Y,Z);
view(3)

img_deri = xcorr2(img, LOG);
threshold = 4;
imshow(img_deri < threshold);


