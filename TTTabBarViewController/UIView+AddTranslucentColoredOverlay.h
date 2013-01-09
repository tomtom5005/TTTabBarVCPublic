//
//  UIView+AddTranslucentColoredOverlay.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (AddTranslucentColoredOverlay)

-(CALayer *)addColoredTranslucentOverlayWithColor:(UIColor *)c andAlpha:(CGFloat)a;

@end
