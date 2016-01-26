//
//  ViewController.m
//  ImageProcessing
//
//  Created by Chauncey on 2016-01-23.
//  Copyright © 2016 Chauncey. All rights reserved.
//

#import "ViewController.h"
#include <iostream>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
using namespace std;

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [UIImage imageNamed:@"pic.bmp"];
    UIImage *image_m = [UIImage imageNamed:@"pic_m.bmp"];
    
    cv::Mat imgMat=[self cvMatFromUIImage:image];
    cv::Mat imgMat_m=[self cvMatFromUIImage:image_m];
    cv::Mat imgOutput = [self cvMatFromUIImage:image];

    //Use Matting to get final image
    cv::Mat imgOutputAfterProcess = [self Matting:imgMat input2:imgMat_m];
    
    UIImage *image2 = [self UIImageFromCVMat:imgMat];
    UIImage *image2_m = [self UIImageFromCVMat:imgMat_m];
    UIImage *output = [self UIImageFromCVMat:imgOutputAfterProcess];

    
    [_img setImage:image2];
    [_img_m setImage:image2_m];
    [_output setImage:output];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (cv::Mat)Matting:(cv::Mat)input input2:(cv::Mat)input_m
{
    int win_size = 1;
    int h = 189,w = 235;
    
    cv::Mat temp,chSum,consts_map,consts_vals,finalImage,consts_map_sub;
    
    temp = abs(input - input_m);
    
    cv::Mat ch1, ch2, ch3;
    cv::Mat ch1_f, ch2_f, ch3_f;

    vector<cv::Mat> channels(3),channelsFinal(3);
    split(temp, channels);
    split(input,channelsFinal);
    ch1 = channels[0];
    ch2 = channels[1];
    ch3 = channels[2];
    
    ch1_f = channelsFinal[0];
    ch2_f = channelsFinal[1];
    ch3_f = channelsFinal[2];
    
    //get the position where image is scribbled
    consts_map = (ch1 + ch2 +ch3) > 0.001;
    ch1 = ch1.mul(consts_map); 
    ch2 = ch2.mul(consts_map);
    ch3 = ch3.mul(consts_map);
    consts_map = consts_map/255;
    
/*          Debug Area        */
//    cv::Size s = input.size();
//    int rows = s.height;
//    int cols = s.width;
//    int channel = input.channels() - 1;
//    
//    printf("%d\n",rows);
//    printf("%d\n",cols);
//    printf("%d\n",channel);
/*          Debug Area        */
    
    //Apply alpha to image
    cv::Mat alpha = [self GetAlpha:input values:consts_map];
    ch1_f = ch1_f.mul(alpha);
    ch2_f = ch2_f.mul(alpha);
    ch3_f = ch3_f.mul(alpha);
    
    //combine 3 channels to 1 matrix
    merge(channels,consts_vals);
    merge(channelsFinal,finalImage);
    
    return finalImage;
}

// Funtion used to get alpha of background and foreground
- (cv::Mat) GetAlpha:(cv::Mat)input values:(cv::Mat)consts_map
{
    cv::Mat temp;
    
    cv::Mat A = cv::Mat::eye(189, 235, CV_8UC1);
    
    cv::Mat Laplacian = [self GetLaplacian:input values:consts_map];
    
    temp = A;
    
    return temp;
}

// Funtion used to get the value of matting laplacian
- (cv::Mat) GetLaplacian:(cv::Mat)input values:(cv::Mat)consts_map
{
    int win_size = 1,m,n,i,j,len;
    cv::Mat temp,consts_map_sub,row_inds,col_inds,vals,win_inds,col_sum,winI;
    
    //neb_size as the windows size (win_size is just the distance between center to border)
    double neb_size = (win_size * 2 + 1) * (win_size * 2 + 1);
    
    cv::Size s = input.size();
    int h = s.height;
    int w = s.width;
    int channel = input.channels() - 1;
    
    n = h; m = w;
    double img_size = w * h;
    double tlen;
    
    cv::Mat indsM = cv::Mat::zeros(h + 1, w + 1, CV_32S);
    
    for(i = 1; i <= w ;i++)
        for(j = 1; j <= h; j++){
            indsM.at<int>(j, i) = 189 * (i - 1) + j;
    }
    
    consts_map_sub = consts_map.rowRange(win_size, h - (win_size+1)).colRange(win_size, w - (win_size+1));
    
    tlen = ((h - 2 * win_size) * (w - 2 * win_size) - cv::sum(consts_map_sub)[0]) * neb_size * neb_size;
    
    row_inds = cv::Mat::zeros(tlen, 1, CV_32S);
    col_inds = cv::Mat::zeros(tlen, 1, CV_32S);
    vals     = cv::Mat::zeros(tlen, 1, CV_32S);
    len      = 0;
    
    for (j = win_size + 1;j <= w - win_size;j++)
        for (i = win_size + 1;i <= h - win_size;i++){
            if ((int)consts_map.at<char>(i,j) == 1){
                continue;
            }
            
            
            //all elements in the window whose center is (i,j) and add their index up to a line
            win_inds = indsM.rowRange(i - win_size,i + win_size).colRange(j - win_size, j + win_size);
            

            col_sum  = cv::Mat::zeros(1,9,CV_32S);
            col_sum.at<int>(1,1) = win_inds.at<int>(0,0);
            col_sum.at<int>(1,2) = win_inds.at<int>(1,0);
            col_sum.at<int>(1,3) = win_inds.at<int>(2,0);
            col_sum.at<int>(1,4) = win_inds.at<int>(0,1);
            col_sum.at<int>(1,5) = win_inds.at<int>(1,1);
            col_sum.at<int>(1,6) = win_inds.at<int>(2,1);
            col_sum.at<int>(1,7) = win_inds.at<int>(0,2);
            col_sum.at<int>(1,8) = win_inds.at<int>(1,2);
            col_sum.at<int>(1,9) = win_inds.at<int>(2,2);
            
            win_inds = col_sum;
            //all elements in the window whose center is (i,j) and add their color up to a line
            winI = input.rowRange(i - win_size - 1,i + win_size).colRange(j - win_size - 1, j + win_size);
            
            cv::Mat winI_temp  = cv::Mat::zeros(10,4,CV_8UC1);
            
            vector<cv::Mat> channels(3);
            split(winI, channels);
            cv::Mat ch1 = channels[0];
            cv::Mat ch2 = channels[1];
            cv::Mat ch3 = channels[2];
                        
            for(int i = 0;i <= 8;i++){
                winI_temp.at<char>(i+1,1) = ch1.at<char>(0,i);
                winI_temp.at<char>(i+1,2) = ch2.at<char>(0,i);
                winI_temp.at<char>(i+1,3) = ch3.at<char>(0,i);
            }
            
            //reshape winI. Each colomn as one kind of color depth of winI
            winI = winI_temp;
            
            //get the mean value of matrix
            cv::Mat win_mu = cv::Mat::zeros(4,2,CV_32F);
            
            double sum1 = 0;
            double sum2 = 0;
            double sum3 = 0;
            
            for(int i = 1;i <= 9;i++){
                sum1 += int(winI.at<uchar>(i,1));
                sum2 += int(winI.at<uchar>(i,2));
                sum3 += int(winI.at<uchar>(i,3));
            }
            
            win_mu.at<double>(1,1) = sum1/9;
            win_mu.at<double>(2,1) = sum2/9;
            win_mu.at<double>(3,1) = sum3/9;
            

            
            //get the variance value of matrix
            
            cv::Mat win_mu_squ;
            transpose(win_mu, win_mu_squ);
            
            printf("%lf ",win_mu.at<double>(0,0));
            printf("%lf ",win_mu.at<double>(0,1));
            printf("%lf ",win_mu.at<double>(0,2));
            printf("%lf\n",win_mu.at<double>(0,3));
            printf("%lf ",win_mu.at<double>(1,0));
            printf("%lf ",win_mu.at<double>(1,1));
            printf("%lf ",win_mu.at<double>(1,2));
            printf("%lf\n",win_mu.at<double>(1,3));
            
            
            
//            printf("%lf ",win_mu_squ.at<double>(0,0));
//            printf("%lf ",win_mu_squ.at<double>(0,1));
//            printf("%lf ",win_mu_squ.at<double>(0,2));
//            printf("%lf\n",win_mu_squ.at<double>(0,3));
//
//            
//            printf("%lf ",win_mu_squ.at<double>(1,0));
//            printf("%lf ",win_mu_squ.at<double>(1,1));
//            printf("%lf ",win_mu_squ.at<double>(1,2));
//            printf("%lf\n",win_mu_squ.at<double>(1,3));
            
            
            
                cv::Size s = win_mu_squ.size();
                int rows = s.height;
                int cols = s.width;
                int channel = input.channels() - 1;
            
                printf("%d\n",rows);
                printf("%d\n",cols);
            
            printf("haha");

           



            
            






            


        }
    
    
    
    return indsM;
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

@end
