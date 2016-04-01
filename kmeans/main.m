% read from .txt file to get N*2 data set
data = textread('gauss_data_3.txt', '%s', 'delimiter', ' ');
num = size(data,1);
x = zeros(num/2,2);
for i = 1:num/2
    x(i,1) = str2double(data(2*i-1,1));
    x(i,2) = str2double(data(2*i,1));
end

% initial clustering setting 
k = 10;
% initg = res2;
for i = 1: size(x,1)
    initg(i) = round(rand()*(k-1))+1;
end

% apply kmeans
[idx,C] = kmeans(x,k);