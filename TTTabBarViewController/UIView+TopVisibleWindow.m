//
//  UIView+TopVisibleWindow.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/15/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "UIView+TopVisibleWindow.h"

@implementation UIView (TopVisibleWindow)

+(UIWindow *)topVisibleWindow
{
    NSArray *windows = [[UIApplication sharedApplication].windows sortedArrayUsingComparator:^NSComparisonResult(UIWindow *window1, UIWindow *window2) {
        if(window1.windowLevel>window2.windowLevel)
            return NSOrderedDescending;
        else if(window1.windowLevel==window2.windowLevel)
            return NSOrderedSame;
        else
            return NSOrderedDescending;
    }];
    UIWindow *topWindow = nil;
    for(int i = [windows count]; i>0; i--)
    {
        topWindow = windows[i-1];
        if( ! topWindow.hidden)
            break;
    }
    return topWindow;
}
@end
