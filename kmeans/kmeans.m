function [idx,C] = kmeans(x, k, initg)
% x: N*2 data
% k: the number of clusters
% initg: initial clustering setting
% idx: clustering index of data 
% C: centroid of each cluster

    % initial variable need
    C = zeros(k,2); 
    idx = ones(size(x,1),1); 
    temp = zeros(k,2);
    num = zeros(k,1);
    dist = zeros(k,1);

    % if initial clustering is given, then apply it
    if(exist('initg','var') == 1)             
       for i = 1: size(x,1)
           idx(i) = initg(i);
       end
    else
        % select initial centroids from data points
        randIndex = randperm(size(x,1),k);
        for i = 1 : k
          C(i,1) = x(randIndex(i),1);
          C(i,2) = x(randIndex(i),2);
        end
        
        % Each point is reassigned to a group whose center is closest
        for i = 1: size(x,1)
            for k = 1: k
               dist(k) = (C(k,1)-x(i,1))^2+(C(k,2)-x(i,2))^2; 
            end
            [~,index] = min(dist);
            idx(i) = index;
        end
    end
    
    % keep looping until no data point needs to be re-assigned
    while(1)
        % initial data
        for i = 1: k
             temp(i,:) = [0,0];
             num(i) = 0;
        end
        flag = 0;

        % compute the group centroids
        for i = 1: size(x,1)
            for j = 1 : k
                if(idx(i) == j)
                    temp(j,:) = temp(j,:) + x(i,:);
                    num(j) = num(j)+1;
                    break;
                end
            end 
        end
        for i = 1 : k
             C(i,:) = temp(i,:) / num(i);
        end
        
        % Each point is reassigned to a group whose center is closest
        for i = 1: size(x,1)
            for k = 1: k
               dist(k) = (C(k,1)-x(i,1))^2+(C(k,2)-x(i,2))^2; 
            end
            [~,index] = min(dist);
            if(idx(i) ~= index)
                flag = 1;
            end
            idx(i) = index;
        end
        
        if(flag == 0 ) 
            break; 
        end       
    end
     
    % draw graph
    figure;
    title('K-means: Cluster Assignments and Centroids')
    hold on        
    for i = 1:k
        scatter(x(idx==i,1),x(idx==i,2),'filled');
        plot(C(i,1),C(i,2),'kx','MarkerSize',15,'LineWidth',3)        
    end 
    hold off 
end

