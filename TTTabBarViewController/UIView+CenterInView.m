//
//  UIView+CenterInView.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/9/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//
#import "UIView+CenterInView.h"
#import "UIView+MinimizeToContainOnlyVisibleSubviews.h"
#import "UIView+ShiftSubviewsDeltaXDeltaY.h"

@implementation UIView (CenterInView)


-(void) centerInView:(UIView *)outerView
{
    [self minimizeToContainOnlyVisibleSubviews];
    //we cannot use the center properties of the views here
    //if we are in the midst of a rotation
    //or another view transform so
    CGFloat x = CGRectGetMidX(outerView.bounds) - self.bounds.size.width/2;
    CGFloat y = CGRectGetMidY(outerView.bounds) - self.bounds.size.height/2;
    self.frame = CGRectMake(x,
                            y,
                            self.bounds.size.width,
                            self.bounds.size.height);
}

@end
