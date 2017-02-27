template = imread('./PA2-testimages/template_elephant.png');
testImage = imread('./PA2-testimages/animals2.jpg');
[rTable1, bin_count1] = build_RTable(template);
[rTable2, bin_count2] = build_RTable2(template);

imshow(testImage);
hold on;
% rotate test image with counter-clockwise angle
for scale = 0.8 : -0.1 : 0.6
    for j = 0 : 4 : 359
        pos = matching(testImage, rTable1, bin_count1, j, scale);
        for i = 1 : size(pos, 1)
            plot(pos(i, 2), pos(i, 1),'r.','MarkerSize', 20);
        end

        pos = matching(testImage, rTable2, bin_count2, j, scale);
        for i = 1 : size(pos, 1)
            plot(pos(i, 2), pos(i, 1),'r.','MarkerSize', 20);
        end
    end
end
