% img = imread('./Gaussian_noises/trees_var025.tif');
img = imread('./salt&pepper_noises/trees_salt004.tif');

% Unweighted averaging
% Argument: unweightAvg(input, delta)
img1 = unweightAvg(img, 1);

% K-nearst neighbor averaging
% Argument: K_nearestAvg(input, K, delta)
img2 = K_nearestAvg(img, 5, 1);

% Median filtering
% Argument: MedianFiltling
img3 = MedianFiltering(img, 1);

% Result
subplot(2,2,1), imshow(img),  title('Original Image');
subplot(2,2,2), imshow(img1), title('Unweighted Averaging');
subplot(2,2,3), imshow(img2), title('K-nearst Neighbor Averaging');
subplot(2,2,4), imshow(img3), title('Median Filtering');