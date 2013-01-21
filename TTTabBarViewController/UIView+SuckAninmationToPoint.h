//
//  UIView+SuckAninmationToPoint.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/19/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

//This animation gives the effect that the view (self) is sucked into the point
//self survives and if (hide==YES) is just hidden at the end ot the animation
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (SuckAninmationToPoint)

//point is a point in the coordinate system of toView
-(void) suckAnimationToPoint:(CGPoint)point
                      inView:(UIView *)toView
                    hideView:(BOOL)hide
             completionBlock:(void (^)(void))comletion;

@end
