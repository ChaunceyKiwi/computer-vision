template = imread('./PA2-testimages/template_K.png');
threshold = 18; % threshold for template K

% template = imread('./PA2-testimages/template_Q.png');
% threshold = 25; % % threshold for template Q

testImage = imread('./PA2-testimages/letters.png');
[rTable, bin_count] = build_RTable(template);

[h, w, ~] = size(template);
imshow(testImage);
hold on;
% rotate test image with counter-clockwise angle
for angle = 1 : 4 : 359
    pos = matching(testImage, rTable, bin_count, angle, threshold);
    for i = 1 : size(pos, 1)
        rectangle('Position', [pos(i, 2) - w / 2, pos(i, 1) - h / 2, w, h],...
	'EdgeColor','r', 'LineWidth', 3, 'Curvature',[1 1])
    end
end
