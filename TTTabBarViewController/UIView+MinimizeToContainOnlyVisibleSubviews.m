//
//  UIView+MinimizeToContainOnlyVisibleSubviews.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "UIView+MinimizeToContainOnlyVisibleSubviews.h"
#import "UIView+MininumRectContainingAllSubviews.h"
#import "UIView+ShiftSubviewsDeltaXDeltaY.h"

@implementation UIView (MinimizeToContainOnlyVisibleSubviews)


-(void) mininumizeToContainOnlyVisibleSubviews
{
    CGFloat deltaX=0;
    CGFloat deltaY=0;
    CGRect minFrame = [self mininumRectContainingAllSubviews];
    deltaX = - minFrame.origin.x;
    deltaY = - minFrame.origin.y;
    self.frame = minFrame;
    if(deltaX!=0 || deltaY!=0)
        [self shiftSubviewFramesDeltaX:deltaX deltaY:deltaY];
}


@end
