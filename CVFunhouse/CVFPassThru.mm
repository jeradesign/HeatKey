//
//  CVFPassThru.mm
//  CVFunhouse
//
//  Created by John Brewer on 7/22/12.
//  Copyright (c) 2012 Jera Design LLC. All rights reserved.
//

#import "CVFPassThru.h"

@implementation CVFPassThru

using namespace cv;

-(void)processMat:(cv::Mat)mat
{
    cv::Mat equalized;
    
    double min, max;
    
    MatIterator_<uint16_t> it, end;
    for( it = mat.begin<uint16_t>(), end = mat.end<uint16_t>(); it != end; ++it) {
        if (*it < 13500) {
            *it = 13500;
        }
    }

    cv::minMaxLoc(mat, &min, &max);
    NSLog(@"min: %f max: %f", min, max);
    normalize(mat, equalized, 0, 65535, cv::NORM_MINMAX);
    equalized.convertTo(equalized, CV_8UC1, 0.015625);
    [self matReady:equalized];
}

@end
