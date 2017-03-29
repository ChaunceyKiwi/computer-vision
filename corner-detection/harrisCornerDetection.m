% input
img = imread('test.jpg');
I = rgb2gray(img);

% variable
k = 0.04; % empirically determined constant (0.04 ~ 0.06)
threshold = 500;
sigma = 1;
halfwid = sigma * 3;
padding = 2 * halfwid;
[xx, yy] = meshgrid(-halfwid:halfwid, -halfwid:halfwid);

% Gx and Gy are Gaussian's first derivative
Gxy = exp(-1 / (2 * sigma^2) * (xx.^2 + yy.^2)) / (2 * pi * sigma^2);
Gx = Gxy .* -xx ./ sigma^2;
Gy = Gxy .* -yy ./ sigma^2;

% Compute x and y derivatives of image
Ix = conv2(double(Gx), double(I));
Iy = conv2(double(Gy), double(I));

% Compute products of derivatives at every pixel
Ixx = Ix .* Ix;
Iyy = Iy .* Iy;
Ixy = Ix .* Iy;

% Compute the sum of the products of derivatives at each pixel
Sxx = conv2(Gxy, Ixx);
Syy = conv2(Gxy, Iyy);
Sxy = conv2(Gxy, Ixy);

% Define H on each pixel 
% Get corner response by R = det(H) - k(trace(M))^2
% det(H) = lambda1 * lambda2
% trance(M) = lambda1 + lambda2
im = zeros(size(Syy,1), size(Sxx,1));
for x = 1 : size(Sxx)
    for y = 1 : size(Syy) 
        H = [Sxx(x, y), Sxy(x, y); Sxy(x, y), Syy(x, y)];
        R = det(H) - k * (trace(H) ^ 2); 
        
        % minimum theshold on value R
        if(R > threshold)
            im(x, y) = R; 
        end
    end
end

% apply non-maximum suppresion
res = im > imdilate(im, [1 1 1; 1 0 1; 1 1 1]);
res = res(1 + padding : end - padding, 1 + padding : end - padding);
[row, col] = find(res);
imshow(img);
hold on
plot(col, row, 'r.', 'MarkerSize', 10);