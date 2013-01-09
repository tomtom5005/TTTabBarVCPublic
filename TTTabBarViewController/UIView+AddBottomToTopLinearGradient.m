//
//  UIView+AddBottomToTopLinearGradient.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "UIView+AddBottomToTopLinearGradient.h"
#import "UIView+AddTopSheen.h"

@implementation UIView (AddBottomToTopLinearGradient)



-(void)addBottomToTopLinearGradientBottomColor:(UIColor *)bottomColor topColor:(UIColor *)topColor
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    
    gradientLayer.frame = self.layer.bounds;
    
    gradientLayer.colors = [NSArray arrayWithObjects:
                            (__bridge id)topColor.CGColor,
                            (__bridge id)bottomColor.CGColor,
                            nil];
    
    gradientLayer.locations = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0f],
                               [NSNumber numberWithFloat:1.0f],
                               nil];
    
    [self.layer insertSublayer:gradientLayer atIndex:0];
}


@end
