//
//  UIView+Highlight.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/5/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@interface UIView (Highlight)

@property (nonatomic, readonly) UIView* highlightView;

-(void) showHighlightWithColor:(UIColor *)color alpha:(CGFloat)a;

@end
