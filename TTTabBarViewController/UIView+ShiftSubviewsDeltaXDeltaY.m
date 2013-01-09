//
//  UIView+ShiftSubviewsDeltaXDeltaY.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "UIView+ShiftSubviewsDeltaXDeltaY.h"

@implementation UIView (ShiftSubviewsDeltaXDeltaY)

-(void) shiftSubviewFramesDeltaX:(CGFloat)deltaX deltaY:(CGFloat)deltaY
{
    for(UIView *view in [self subviews])
    {
        view.frame = CGRectMake(view.frame.origin.x + deltaX,
                                view.frame.origin.y + deltaY,
                                view.frame.size.width,
                                view.frame.size.height);
    }
}
@end
