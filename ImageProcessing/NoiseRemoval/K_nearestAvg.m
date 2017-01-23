function output = K_nearestAvg(input, K, delta)

output = input;
windowSize = (2 * delta + 1)^2 - 1;
for i = 1 + delta : size(input, 1) - delta
    for j = 1 + delta : size(input, 2) - delta
        output(i, j) = 0;
        neighbors = zeros(1, windowSize);
        index = 1;
        
        % get the value of neighbors
        for yrange = -delta : delta
            for xrange = -delta : delta
                if (yrange ~= 0 || xrange ~= 0)
                    neighbors(index) = input(i + yrange , j + xrange);
                    index = index + 1;
                end
            end
        end
        
        target = int16(input(i, j));
        % calculate K_nearstAvg
        for k = 2 : size(neighbors,2)
            x = neighbors(k);
            l = k;
            while(l > 1 && abs(neighbors(l-1)-target) > abs(x-target)) 
                neighbors(l) = neighbors(l-1);
                l = l - 1;
            end
            neighbors(l) = x;
        end
        
        sum = 0;
        for k = 1 : K 
            sum = sum + neighbors(k);
        end
        sum = sum + target;
        output(i,j) = sum / (K + 1); 
    end
end