//
//  CALayer+LayerWithImage.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/18/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import "CALayer+LayerWithImage.h"

@implementation CALayer (LayerWithImage)

+ (CALayer *)layerWithImage:(UIImage *)img
{
    CALayer *imgLayer = [CALayer layer];
    imgLayer.frame = CGRectMake(0,0,
                                img.size.width,
                                img.size.height);
    imgLayer.contents = (__bridge id)(img.CGImage);
    return imgLayer;
}

@end
