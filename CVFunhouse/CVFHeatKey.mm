//
//  CVFHeatKey.mm
//  HeatKey
//
//  Created by John Brewer on 12/14/14.
//  Copyright (c) 2014 Jera Design LLC. All rights reserved.
//

#import "CVFHeatKey.h"

@implementation CVFHeatKey

using namespace cv;

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
    
    std::vector<Mat> channels;
    split(rgbMat, channels);
    channels.push_back(mask);
    merge(channels, rgbMat);
    
    [self matReady:rgbMat];
}
@end
