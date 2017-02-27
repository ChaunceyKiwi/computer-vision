template = imread('./PA2-testimages/template_elephant.png');
testImage = imread('./PA2-testimages/animals.jpg');
[rTable1, bin_count1] = build_RTable(template);
[rTable2, bin_count2] = build_RTable2(template);

imshow(testImage);
hold on;
% rotate test image with counter-clockwise angle
for j = 0 : 4 : 359
    pos = matching(testImage, rTable1, bin_count1, j);
    for i = 1 : size(pos, 1)
        plot(pos(i, 2), pos(i, 1),'r.','MarkerSize', 20);
    end
    pos = matching(testImage, rTable2, bin_count2, j);
    for i = 1 : size(pos, 1)
        plot(pos(i, 2), pos(i, 1),'r.','MarkerSize', 20);
    end
end
