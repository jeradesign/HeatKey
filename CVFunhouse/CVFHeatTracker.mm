//
//  CVFHeatTracker.m
//  HeatKey
//
//  Created by John Brewer on 12/14/14.
//  Copyright (c) 2014 Jera Design LLC. All rights reserved.
//

#import "CVFHeatTracker.h"
#import "CVFGalileoHandler.h"

const float minDeltaX = 0.05;
const float minDeltaY = 0.05;

@interface CVFHeatTracker() {
    CVFGalileoHandler *_galileo;
}

@end

@implementation CVFHeatTracker

using namespace cv;

-(instancetype)init
{
    self = [super init];
    if (self != nil) {
        _galileo = [[CVFGalileoHandler alloc] init];
    }
    return self;
}

-(void)processMat1:(cv::Mat)mat1 mat2:(cv::Mat)ycbcr
{
#pragma unused(ycbcr)
    cv::Mat equalized;
    
    double min, max;
    
    MatIterator_<uint16_t> it, end;
    for( it = mat1.begin<uint16_t>(), end = mat1.end<uint16_t>(); it != end; ++it) {
        if (*it < 13500) {
            *it = 13500;
        }
    }
    
    cv::minMaxLoc(mat1, &min, &max);
    NSLog(@"min: %f max: %f", min, max);
    normalize(mat1, equalized, 0, 16384, cv::NORM_MINMAX);
    equalized.convertTo(equalized, CV_8UC1, 0.015625);
    
    Mat ycrcb(ycbcr.rows, ycbcr.cols, CV_8UC3);
    
    int from_to[] = { 0,0, 1,2, 2,1 };
    cv::mixChannels(&ycbcr, 1, &ycrcb, 1, from_to, 3);
    Mat rgbMat;
    cvtColor(ycrcb, rgbMat, CV_YCrCb2RGB);
    
    Mat mask;
    resize(equalized, mask, rgbMat.size());
    
    threshold(mask, mask, 32, 255, THRESH_BINARY);
    
    vector<vector<cv::Point> > contours;
    findContours(mask, contours, CV_RETR_LIST, CV_CHAIN_APPROX_NONE);
    vector<cv::Point> biggestContour;
    int biggestArea = 0;
    for (const auto& contour : contours) {
        int currentArea = contourArea(contour);
        if (currentArea > biggestArea) {
            biggestArea = currentArea;
            biggestContour = contour;
        }
    }
    NSLog(@"Biggest area %d", biggestArea);
    if (biggestArea > 0) {
        Moments mu = moments(biggestContour);
        int x = mu.m10/mu.m00;
        int y = mu.m01/mu.m00;
        Scalar green(0, 255, 0);
        drawContours(rgbMat, vector<vector<cv::Point> >{biggestContour}, -1, green);
        Scalar blue(0, 0, 255);
        int right = rgbMat.cols;
        int bottom = rgbMat.rows;
        cv::line(rgbMat, cv::Point(0,y), cv::Point(right,y), cv::Scalar(0, 0 , 255));
        cv::line(rgbMat, cv::Point(x,0), cv::Point(x,bottom), cv::Scalar(0, 0 , 255));
        int matX = rgbMat.cols / 2;
        int matY = rgbMat.rows / 2;
        
        float deltaX = (float)(x - matX) / rgbMat.cols;
        float deltaY = -(float)(y - matY) / rgbMat.rows;
        
        if (fabs(deltaX) < minDeltaX) {
            deltaX = 0;
        }
        if (fabs(deltaY) < minDeltaY) {
            deltaY = 0;
        }
        
        NSLog(@"%f, %f", deltaX, deltaY);
        [_galileo panBy:deltaY * 180];
        [_galileo tiltBy:deltaX * 180];
    } else {
        [_galileo panBy:0];
        [_galileo tiltBy:0];
    }
    
    [self matReady:rgbMat];
}

@end
