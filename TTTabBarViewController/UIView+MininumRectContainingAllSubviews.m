//
//  UIView+MininumRectContainingAllSubviews.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "UIView+MininumRectContainingAllSubviews.h"

@implementation UIView (MininumRectContainingAllSubviews)

-(CGRect) mininumRectContainingAllSubviews
{
    //often frame.size.width != bounds.size.width - bounds seems
    //to reflect the width after a rotation while freme does not?!!!
    //so we create the true frame here
    /*
     CGRect trueFrame = CGRectMake(self.frame.origin.x,
     self.frame.origin.y,
     self.bounds.size.width,
     self.bounds.size.height);
     */
    CGFloat x = CGRectGetMaxX(self.bounds)+self.frame.origin.x;
    CGFloat y = CGRectGetMaxY(self.bounds)+self.frame.origin.y;
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    for (UIView *view in [self subviews])
    {
        if(view.hidden==NO && view.alpha>0)
        {
            x = view.frame.origin.x < x ? view.frame.origin.x : x;
            y = view.frame.origin.y < y ? view.frame.origin.y : y;
            maxX = CGRectGetMaxX(view.frame) > maxX ? CGRectGetMaxX(view.frame) : maxX;
            maxY = CGRectGetMaxY(view.frame) > maxY ? CGRectGetMaxY(view.frame) : maxY;
        }
    }
    CGFloat w = maxX - x;
    CGFloat h = maxY -y;
    return CGRectMake(x, y, w, h);
}

@end
