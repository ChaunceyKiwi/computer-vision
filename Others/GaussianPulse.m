% Code from https://www.mathworks.com/help/matlab/ref/fft.html

Fs = 100;           % Sampling frequency
t = -3:1/Fs:3;  % Time vector
L = length(t);      % Signal length

X = normpdf(t, 0, 0.1);
subplot(2,1,1)
plot(t,X)
title('Gaussian Pulse in Time Domain')
xlabel('Time (t)')
ylabel('X(t)')

n = 2^nextpow2(L);
Y = fft(X,n);
f = Fs*(0:(n/2))/n;
P = abs(Y/n);

subplot(2,1,2)
plot(f,P(1:n/2+1))
title('Gaussian Pulse in Frequency Domain')
xlabel('Frequency (f)')
ylabel('|P(f)|')