template = imread('./PA2-testimages/template_K.png');
testImage = imread('./PA2-testimages/letters.png');
[rTable, bin_count] = build_RTable(template);

[h, w, ~] = size(template);
imshow(testImage);
hold on;
% rotate test image with counter-clockwise angle
for angle = 1 : 4 : 360
    pos = matching(testImage, rTable, bin_count, angle);
    for i = 1 : size(pos, 1)
        rectangle('Position', [pos(i, 2) - w / 2, pos(i, 1) - h / 2, w, h],...
	'EdgeColor','r', 'LineWidth', 3)
    end
end
