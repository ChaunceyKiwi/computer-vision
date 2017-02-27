template = imread('./PA2-testimages/template_Q.png');
testImage = imread('./PA2-testimages/letters.png');
[rTable, bin_count] = build_RTable(template);

imshow(testImage);
hold on;
% rotate test image with counter-clockwise angle
for angle = 1 : 4 : 360
    pos = matching(testImage, rTable, bin_count, -angle);
    for i = 1 : size(pos, 1)
        plot(pos(i, 2), pos(i, 1),'r.','MarkerSize', 20);
    end
end
