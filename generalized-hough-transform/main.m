template = imread('./PA2-testimages/template_Q.png');
testImage = imread('./PA2-testimages/letters.png');
[rTable, bin_count] = build_RTable(template);
pos = matching(testImage, rTable, bin_count);

imshow(testImage);
hold on;
for i = 1 : size(pos, 1)
    plot(pos(i, 2), pos(i, 1),'r.','MarkerSize',20);
end