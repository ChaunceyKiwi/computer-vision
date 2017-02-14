img_rgb = double(imread('peppers.png'))/255;
% img_rgb = double(imread('flower-glass.tif'))/255;
img_ycbcr = rgb2ycbcr(img_rgb);
imshow(ycbcr2rgb(img_ycbcr));

% filter1 = [0, -1, 0; -1, 5, -1; 0, -1, 0];
filter1 = [-1, -1, -1; -1, 9, -1; -1, -1, -1];

% Sharpening only on luminance
img_ycbcr(:,:,1) = conv2(img_ycbcr(:,:,1), filter1, 'same');
img_sharpened_lumin = ycbcr2rgb(img_ycbcr);

% Sharpening on all RGBs
img_sharpened_RGB = zeros(size(img_rgb,1), size(img_rgb,2), 3);
for i = 1 : 3
    img_sharpened_RGB(:,:,i) = conv2(img_rgb(:,:,i), filter1, 'same');
end

% Result
subplot(2,2,1), imshow(img_rgb),  title('Original Image');
subplot(2,2,3), imshow(img_sharpened_lumin), title('On luminance only');
subplot(2,2,4), imshow(img_sharpened_RGB), title('On all RGBs');