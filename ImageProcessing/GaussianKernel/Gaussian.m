%Blur with Gaussian kernel
size = 10; % The size of kernel
img = imread('Lenna.png');
img = rgb2gray(img)/255;
t = 10; %Scale 

imgBlur = zeros(size,size);

%build Gaussian kernel
for x = -size:size
    for y = -size:size
        imgBlur(x+size+1,y+size+1) = 1/(2*pi*t)*(exp((x.^2+y.^2)/(-2*t)));
    end
end

%convolution with image using kernel
imgGaussian = conv2(double(img),double(imgBlur),'same');

%image of Kernel
[X,Y] = meshgrid(-size:size,-size:size);
Z = imgBlur;
figure
surface(X,Y,Z);
view(3)
saveas(figure(1), 'Kernel','bmp');

%image of Lenna after convolution
imgBlur = imshow(imgGaussian);
imwrite(imgGaussian,'imgBlur.bmp');
