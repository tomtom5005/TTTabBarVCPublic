//
//  UIImage+TopAndBottomHalfImages.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/18/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import "UIImage+TopAndBottomHalfImages.h"

@implementation UIImage (TopAndBottomHalfImages)


-(UIImage *) topHalfImage
{
    CGRect imgRect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGRect topRect = CGRectMake(0, 0,
                                self.size.width,
                                CGRectGetMidY(imgRect));
    CGImageRef topCGImage = CGImageCreateWithImageInRect(self.CGImage, topRect);
    UIImage *topImg = [UIImage imageWithCGImage:topCGImage];
    CGImageRelease(topCGImage);
    return topImg;
}


-(UIImage *) bottomHalfImage
{
    CGRect imgRect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGRect bottomRect = CGRectMake(0, CGRectGetMidY(imgRect),
                                   self.size.width,
                                   self.size.height-CGRectGetMidY(imgRect));
    CGImageRef bottomCGImage = CGImageCreateWithImageInRect(self.CGImage, bottomRect);
    UIImage *bottomImg = [UIImage imageWithCGImage:bottomCGImage];
    CGImageRelease(bottomCGImage);
    return bottomImg;
}


@end
