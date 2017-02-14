% Demo of image stretching
img = imread('dark.tif');

p0 = 0; % lower bound
pm = 255; % upper bound 
a = double(min(img(:))); % lower limit
b = double(max(img(:))); % upper limit
imgStretched = img;
imgStretched(img < a) = p0;
imgStretched(img > b) = pm;
imgStretched(img >= a & img <= b) = (pm - p0) / (b - a) * ...
    (img(img >= p0 & img <= pm) - a) + p0;

% Result
subplot(2,2,1), imhist(img);
subplot(2,2,2), imshow(img);
subplot(2,2,3), imhist(imgStretched);
subplot(2,2,4), imshow(imgStretched);