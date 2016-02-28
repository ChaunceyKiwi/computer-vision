%Blur with Gaussian kernel
img = imread('Lenna.png');
img = double(rgb2gray(img))/255;
t = 10; %Scale 
size = 2*t; % The size of kernel
imgBlur = zeros(size,size);

%build Gaussian kernel and check sum
for x = -size:size
    for y = -size:size
        imgBlur(x+size+1,y+size+1) = 1/(2*pi*t)*(exp((x.^2+y.^2)/(-2*t)));
    end
end

if(abs(sum(imgBlur(:)) - 1) > 1e-03)
    disp('Kernel range too small!');
end

%convolution with image using kernel
imgGaussian = conv2(double(img),double(imgBlur),'same');

%image of Kernel
[X,Y] = meshgrid(-size:size,-size:size);
Z = imgBlur;
figure
surface(X,Y,Z);
view(3)
saveas(figure(1), 'Kernel','jpg');

%image of Lenna after convolution
imtool(imgGaussian);
imwrite(imgGaussian,'imgBlur.jpg');