//
//  UIView+AddTopSheen.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "UIView+AddTopSheen.h"

@implementation UIView (AddTopSheen)


-(void)addTopLinearSheen
{
    
    UIColor *topColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.35];
    UIColor *bottomColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1];
    CAGradientLayer *sheenLayer = [CAGradientLayer layer];
    
    CGRect topHalf = CGRectMake(self.bounds.origin.x,
                                self.bounds.origin.y,
                                self.bounds.size.width,
                                self.bounds.size.height/2);
    
    sheenLayer.frame = topHalf;
    
    sheenLayer.colors = [NSArray arrayWithObjects:
                         (__bridge id)topColor.CGColor,
                         (__bridge id)bottomColor.CGColor,
                         nil];
    sheenLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    
    [self.layer addSublayer:sheenLayer];
    
}


@end
