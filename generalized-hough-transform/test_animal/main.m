% template = imread('./PA2-testimages/template_bear.png');
template = imread('./PA2-testimages/template_elephant.png');

testImage = imread('./PA2-testimages/animals.jpg');
[rTable1, bin_count1] = build_RTable(template);
[rTable2, bin_count2] = build_RTable2(template);

[h, w, ~] = size(template);
imshow(testImage);
hold on;
% rotate test image with counter-clockwise angle
for scale = 1.0 : -0.3 : 0.4
    for angle = 0 : 4 : 359
        pos = matching(testImage, rTable1, bin_count1, angle, scale);
        for i = 1 : size(pos, 1)
        rectangle('Position', [pos(i, 2) - w / 2, pos(i, 1) - h / 2, w, h],...
            'EdgeColor','r', 'LineWidth', 3, 'Curvature',[1 1]);
        end
        pos = matching(testImage, rTable2, bin_count2, angle, scale);
        for i = 1 : size(pos, 1)
        rectangle('Position', [pos(i, 2) - w / 2, pos(i, 1) - h / 2, w, h],...
            'EdgeColor','r', 'LineWidth', 3, 'Curvature',[1 1]);
        end
    end
end
