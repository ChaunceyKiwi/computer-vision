function output = MedianFiltering(input, delta)

output = input;
windowSize = (2 * delta + 1)^2;
for i = 1 + delta : size(input, 1) - delta
    for j = 1 + delta : size(input, 2) - delta
        output(i, j) = 0;
        neighbors = zeros(1, windowSize);
        index = 1;
        
        for yrange = -delta : delta
            for xrange = -delta : delta
                neighbors(index) = input(i + yrange , j + xrange);
                index = index + 1;
            end
        end
        
        output(i,j) = median(neighbors);
    end
end