f = [0,0,0,0,0;
     0,0,0,0,0;
     0,9,9,9,0;
     0,0,0,0,0;
     0,0,0,0,0];
t = [1,1,1;
     1,1,1;
     1,1,1] / 9;
t2 = [1,0,0;
      0,0,0;
      0,0,0];
 
f_con = convolution(f, t2);
f_cor = cross_correlation(f, t2);

f_con_m = conv2(f, t2);
f_cor_m = xcorr2(f, t2);
