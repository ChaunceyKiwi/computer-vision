function output = convolution(input, t) 
height = size(input, 1);
width = size(input, 2);
N = (size(t, 1) - 1) / 2;
M = (size(t, 2) - 1) / 2;

output = input;
for h = 1 : height
    for w = 1 : width
        output(h, w) = 0;
        for y = -N : N
            for x = -M : M
                if ((h - y >= 1 && h - y <= height && w - x >= 1 && w - x <= width)) 
                    output(h, w) = output(h, w) + ...
                        input(h - y, w - x) * t(y + N + 1, x + M + 1);
                end
            end
        end
    end
end