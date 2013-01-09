//
//  UIView+AddTranslucentColoredOverlay.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "UIView+AddTranslucentColoredOverlay.h"

@implementation UIView (AddTranslucentColoredOverlay)

-(CALayer *)addColoredTranslucentOverlayWithColor:(UIColor *)c andAlpha:(CGFloat)a
{
    self.layer.masksToBounds=YES;
    CALayer *subLayer = [CALayer layer];
    subLayer.frame = self.bounds;
    subLayer.opacity = a;
    subLayer.backgroundColor=c.CGColor;
    [self.layer addSublayer:subLayer];
    return subLayer;
}
@end
