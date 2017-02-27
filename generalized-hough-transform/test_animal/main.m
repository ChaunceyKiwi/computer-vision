% template = imread('./PA2-testimages/template_bear.png');
template = imread('./PA2-testimages/template_elephant.png');

testImage = imread('./PA2-testimages/animals2.jpg');
[rTable_hsv, bin_count_hsv] = build_RTable_hsv(template);
[rTable_gray, bin_count_gray] = build_RTable_gray(template);

[h, w, ~] = size(template);
imshow(testImage);
hold on;
% rotate test image with counter-clockwise angle
for scale = 1.0 : -0.3 : 0.4
    for angle = 0 : 4 : 359
        pos = matching(testImage, rTable_gray, bin_count_gray, angle, scale);
        for i = 1 : size(pos, 1)
        rectangle('Position', [pos(i, 2) - w / 2, pos(i, 1) - h / 2, w, h],...
            'EdgeColor','r', 'LineWidth', 3, 'Curvature',[1 1]);
        end
        pos = matching(testImage, rTable_hsv, bin_count_hsv, angle, scale);
        for i = 1 : size(pos, 1)
        rectangle('Position', [pos(i, 2) - w / 2, pos(i, 1) - h / 2, w, h],...
            'EdgeColor','r', 'LineWidth', 3, 'Curvature',[1 1]);
        end
    end
end
