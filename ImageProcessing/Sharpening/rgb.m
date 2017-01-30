img = imread('peppers.png');
% img = imread('flower-glass.tif');
imshow(img);

filter1 = [0, -1, 0; -1, 5, -1; 0, -1, 0];
filter2 = [0, -2, 0; -2, 9, -2; 0, -2, 0];
filter3 = [0, -1/2, 0; -1/2, 3, -1/2; 0, -1/2, 0];
filter4 = [-1, -1, -1; -1, 9, -1; -1, -1, -1];
filter5 = [1, -2, 1; -2, 5, -2; 1, -2, 1];

img_sharpened_RGB1 = zeros(size(img,1), size(img,2), 3);
img_sharpened_RGB2 = zeros(size(img,1), size(img,2), 3);
img_sharpened_RGB3 = zeros(size(img,1), size(img,2), 3);
img_sharpened_RGB4 = zeros(size(img,1), size(img,2), 3);
img_sharpened_RGB5 = zeros(size(img,1), size(img,2), 3);

% Sharpening on all RGBs
for i = 1 : 3
    img_sharpened_RGB1(:,:,i) = conv2(double(img(:,:,i)), filter1, 'same') / 255;
    img_sharpened_RGB2(:,:,i) = conv2(double(img(:,:,i)), filter2, 'same') / 255;
    img_sharpened_RGB3(:,:,i) = conv2(double(img(:,:,i)), filter3, 'same') / 255;
    img_sharpened_RGB4(:,:,i) = conv2(double(img(:,:,i)), filter4, 'same') / 255;
    img_sharpened_RGB5(:,:,i) = conv2(double(img(:,:,i)), filter5, 'same') / 255;
end

% Result
subplot(2,3,1), imshow(img),  title('Original Image');
subplot(2,3,2), imshow(img_sharpened_RGB1), title('-1&5 Filter');
subplot(2,3,3), imshow(img_sharpened_RGB2), title('-2&9 Filter');
subplot(2,3,4), imshow(img_sharpened_RGB3), title('-1/2&3 Filter');
subplot(2,3,5), imshow(img_sharpened_RGB4), title('-1&9 Filter');
subplot(2,3,6), imshow(img_sharpened_RGB5), title('1&-2&5 Filter');