img = double(rgb2gray(imread('lenna.tif')));
% imshow(img);

% % Base operator
% img_deri_x = xcorr2(img,[-1,1]);
% img_deri_y = xcorr2(img,[-1;1]);

% Roberts operator
img_deri_x = xcorr2(img,[0,1;-1,0]);
img_deri_y = xcorr2(img,[1,0;0,-1]);

img_output = img;
img_theta = img;
for h = 1 : size(img, 1)
    for w = 1:size(img, 2)
        img_output(h,w) = sqrt(img_deri_x(h,w)^2 + img_deri_y(h,w)^2);
        img_theta(h,w) = atand(img_deri_y(h,w)/img_deri_x(h,w));
    end
end

% Display of magnitude
threshold = 20;
imshow(img_output < threshold);

% Display of direction
[y,x] = meshgrid(1:1:512,1:1:512);
u = img_deri_x(1:512,1:512);
v = img_deri_y(1:512,1:512);
figure
quiver(y,x,v,u)

