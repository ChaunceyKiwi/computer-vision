function output = unweightAvg(input, delta)

output = input;
windowSize = (2 * delta + 1)^2;
for i = 1 + delta : size(input, 1) - delta
    for j = 1 + delta : size(input, 2) - delta
        output(i, j) = 0;
        for yrange = -delta : delta
            for xrange = -delta : delta
                output(i, j) = output(i, j) + ...
                    input(i + yrange , j + xrange) / windowSize;
            end
        end
    end
end