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
#include "../Eigen/SparseCore"
#include "../Eigen/Core"
#include "../Eigen/SparseCholesky"
#include "../Eigen/Dense"
#include "../Eigen/SparseQR"
#include "../Eigen/IterativeLinearSolvers"



#define epsilon 0.0000001
using namespace std;
typedef Eigen::SparseMatrix<double> SpMat;
typedef Eigen::Triplet<double> T;
std::vector<T> tripletList;

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
    consts_vals = ch1/255;
    
    
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
    
    cv::Mat alpha = [self GetAlpha:input values:consts_map values2:consts_vals];
    ch1_f = ch1_f.mul(alpha);
    ch2_f = ch2_f.mul(alpha);
    ch3_f = ch3_f.mul(alpha);
    
    //combine 3 channels to 1 matrix
    merge(channelsFinal,finalImage);
    
    return finalImage;
}

// Funtion used to get alpha of background and foreground
- (cv::Mat) GetAlpha:(cv::Mat)input values:(cv::Mat)consts_map values2:(cv::Mat)consts_vals
{
    cv::Size s = input.size();
    int h = s.height;
    int w = s.width;
    int img_size = w * h;
    int lambda = 100;
    
    cv::Mat temp = cv::Mat::eye(189, 235, CV_8UC1);

    
    SpMat A = [self GetLaplacian:input values:consts_map];
    
    SpMat D(img_size,img_size);
    for(int i = 0; i < img_size; i++){
        D.coeffRef(i,i) = (int)consts_map.at<char>(0, i);
    }
    
    //x = (A+lambda*D)\(lambda*consts_vals(:));
    
    SpMat left = A + lambda * D;
    
    cv::Mat consts_vals_in_a_col;
    cv::Mat transpo;
    transpo = consts_vals.t();
    consts_vals_in_a_col = transpo.reshape(1,img_size);
    
    Eigen::VectorXd right(img_size);
    for(int i = 0;i < img_size;i++){
            right(i) = lambda * consts_vals_in_a_col.at<char>(i,0);
    }
    
    Eigen::VectorXd x(img_size);
    
    Eigen::SimplicialLDLT  <Eigen::SparseMatrix<double>> cg;
    cg.compute(left);
    x = cg.solve(right);
    Eigen::VectorXd pro = left*x-right;
    
    
    cout<<x<<endl;
    
    return temp;
}

// Funtion used to get the value of matting laplacian
- (SpMat) GetLaplacian:(cv::Mat)input values:(cv::Mat)consts_map
{
    int win_size = 1,m,n,i,j,len;
    cv::Mat temp,consts_map_sub,row_inds,col_inds,vals,win_inds,col_sum,winI;
    
    //neb_size as the windows size (win_size is just the distance between center to border)
    int neb_size = (win_size * 2 + 1) * (win_size * 2 + 1);
    
    cv::Size s = input.size();
    int h = s.height;
    int w = s.width;
    int channel = input.channels() - 1;
    
    n = h; m = w;
    int img_size = w * h;
    double tlen;
    
    cv::Mat indsM = cv::Mat::zeros(h, w, CV_32S);
    
    for(i = 0; i <= w -1 ;i++)
        for(j = 0; j <= h - 1; j++){
            indsM.at<int>(j, i) = 189 * i + j + 1;
    }
    
    consts_map_sub = consts_map.rowRange(win_size, h - (win_size+1)).colRange(win_size, w - (win_size+1));
    
    tlen = ((h - 2 * win_size) * (w - 2 * win_size) - cv::sum(consts_map_sub)[0]) * neb_size * neb_size;
    
    row_inds = cv::Mat::zeros(tlen, 1, CV_32S);
    col_inds = cv::Mat::zeros(tlen, 1, CV_32S);
    vals     = cv::Mat::zeros(tlen, 1, CV_64F);
    len      = 0;
    
    for (j = win_size;j <= w - win_size - 1;j++)
        for (i = win_size;i <= h - win_size - 1;i++){
            if ((int)consts_map.at<char>(i,j) == 1){
                continue;
            }
            
            //all elements in the window whose center is (i,j) and add their index up to a line
            win_inds = indsM.rowRange(i - win_size,i + win_size + 1).colRange(j - win_size, j + win_size + 1);
            
            cv::Mat col_sum  = cv::Mat::zeros(1,9,CV_64F);
            
            col_sum.at<double>(0,0) = double(win_inds.at<int>(0,0));
            col_sum.at<double>(0,1) = double(win_inds.at<int>(1,0));
            col_sum.at<double>(0,2) = double(win_inds.at<int>(2,0));
            col_sum.at<double>(0,3) = double(win_inds.at<int>(0,1));
            col_sum.at<double>(0,4) = double(win_inds.at<int>(1,1));
            col_sum.at<double>(0,5) = double(win_inds.at<int>(2,1));
            col_sum.at<double>(0,6) = double(win_inds.at<int>(0,2));
            col_sum.at<double>(0,7) = double(win_inds.at<int>(1,2));
            col_sum.at<double>(0,8) = double(win_inds.at<int>(2,2));
            
            win_inds = col_sum;
//            print(col_sum);
//            printf("\n");


            
            //all elements in the window whose center is (i,j) and add their color up to a line
            winI = input.rowRange(i - win_size,i + win_size + 1).colRange(j - win_size, j + win_size + 1);
            
            cv::Mat winI_temp  = cv::Mat::zeros(9,3,CV_64F);
            
            vector<cv::Mat> channels(3);
            split(winI, channels);
            cv::Mat ch1 = channels[0];
            cv::Mat ch2 = channels[1];
            cv::Mat ch3 = channels[2];
                        
            
            winI_temp.at<double>(0,0) = ch1.at<uchar>(0,0);
            winI_temp.at<double>(1,0) = ch1.at<uchar>(1,0);
            winI_temp.at<double>(2,0) = ch1.at<uchar>(2,0);
            winI_temp.at<double>(3,0) = ch1.at<uchar>(0,1);
            winI_temp.at<double>(4,0) = ch1.at<uchar>(1,1);
            winI_temp.at<double>(5,0) = ch1.at<uchar>(2,1);
            winI_temp.at<double>(6,0) = ch1.at<uchar>(0,2);
            winI_temp.at<double>(7,0) = ch1.at<uchar>(1,2);
            winI_temp.at<double>(8,0) = ch1.at<uchar>(2,2);
            
            winI_temp.at<double>(0,1) = ch2.at<uchar>(0,0);
            winI_temp.at<double>(1,1) = ch2.at<uchar>(1,0);
            winI_temp.at<double>(2,1) = ch2.at<uchar>(2,0);
            winI_temp.at<double>(3,1) = ch2.at<uchar>(0,1);
            winI_temp.at<double>(4,1) = ch2.at<uchar>(1,1);
            winI_temp.at<double>(5,1) = ch2.at<uchar>(2,1);
            winI_temp.at<double>(6,1) = ch2.at<uchar>(0,2);
            winI_temp.at<double>(7,1) = ch2.at<uchar>(1,2);
            winI_temp.at<double>(8,1) = ch2.at<uchar>(2,2);
            
            winI_temp.at<double>(0,2) = ch3.at<uchar>(0,0);
            winI_temp.at<double>(1,2) = ch3.at<uchar>(1,0);
            winI_temp.at<double>(2,2) = ch3.at<uchar>(2,0);
            winI_temp.at<double>(3,2) = ch3.at<uchar>(0,1);
            winI_temp.at<double>(4,2) = ch3.at<uchar>(1,1);
            winI_temp.at<double>(5,2) = ch3.at<uchar>(2,1);
            winI_temp.at<double>(6,2) = ch3.at<uchar>(0,2);
            winI_temp.at<double>(7,2) = ch3.at<uchar>(1,2);
            winI_temp.at<double>(8,2) = ch3.at<uchar>(2,2);
            
            

            
            //reshape winI. Each colomn as one kind of color depth of winI
            winI = winI_temp/255;

            
            //get the mean value of matrix
            cv::Mat win_mu = cv::Mat::zeros(3,1,CV_64F);
            
            double sum1 = 0;
            double sum2 = 0;
            double sum3 = 0;
            
            for(int i = 0;i <= 8;i++){
                sum1 += winI.at<double>(i,0);
                sum2 += winI.at<double>(i,1);
                sum3 += winI.at<double>(i,2);
            }
            
            
            win_mu.at<double>(0,0) = sum1/9;
            win_mu.at<double>(1,0) = sum2/9;
            win_mu.at<double>(2,0) = sum3/9;
            
            //get the variance value of matrix
            cv::Mat win_mu_squ = win_mu.t();
            
            cv::Mat multi = win_mu * win_mu_squ;
            
            
            cv::Mat multi2 = winI.t() * winI / neb_size;
            cv::Mat eye_c = cv::Mat::eye(channel,channel,CV_64F);
            cv::Mat before_inv = multi2 - multi + epsilon/neb_size * eye_c;
            cv::Mat win_var = before_inv.inv();

            winI = winI - repeat(win_mu_squ, neb_size, 1);
            cv::Mat tvals = (1 + winI * win_var * winI.t())/neb_size;
            tvals = tvals.reshape(0,neb_size*neb_size);
            
            cv::Mat repe_col = repeat(win_inds.t(),1,neb_size).reshape(0, neb_size*neb_size);
            cv::Mat repe_row = repeat(win_inds,neb_size,1).reshape(0, neb_size*neb_size);
            cv::Mat putInRow = tvals.reshape(0,neb_size*neb_size);
            //row_inds(1+len:neb_size^2+len)
            
            for(int i = len;i <= neb_size*neb_size + len - 1;i++){
                row_inds.at<int>(i,0) = repe_row.at<double>(i - len,0);
                col_inds.at<int>(i,0) = repe_col.at<double>(i - len,0);
                vals.at<double>(i,0) = tvals.at<double>(i - len,0);
            }
            
            len=len+neb_size*neb_size;
        }
    
//        cv::Mat A = cv::Mat::zeros(img_size, img_size, CV_64F);
    SpMat A(img_size,img_size);
    SpMat matrixOfOne(img_size,1);
    
    for(int i = 0;i < img_size ;i++){
        matrixOfOne.insert(i, 0) = 1;
    }
    
    tripletList.reserve(len);
    for(int i = 0;i < len ;i++){
        tripletList.push_back(T(row_inds.at<int>(i,0)-1,col_inds.at<int>(i,0)-1,vals.at<double>(i,0)));
    }
    
    A.setFromTriplets(tripletList.begin(), tripletList.end());
    
    SpMat sumA = A * matrixOfOne;
    
    SpMat sparse_mat(img_size,img_size);
    
    for(int i = 0; i < img_size; i++){
        sparse_mat.coeffRef(i,i) = sumA.coeffRef(i, 0);
    }
    
    A = sparse_mat - A;
    
    return A;
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
