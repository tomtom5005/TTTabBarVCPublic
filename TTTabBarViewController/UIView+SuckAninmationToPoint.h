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

//The direction is the direction from which the sucked view(self) should "enter the point".
//This does not mean that the suked view,self, must be above the point only that the animation
//will make the view appear to enter the point from the designated direction
//try it and see
//
typedef enum{TTSuckFromDirectionAbove, TTSuckFromDirectionBelow,
    TTSuckFromDirectionRight, TTSuckFromDirectionLeft,TTSuckFromDirectionAll }TTSuckFromDirection;

#define kControlPointDeltaX 36

@interface UIView (SuckAninmationToPoint)

//point is a point in the coordinate system of toView
-(void) suckAnimationToPoint:(CGPoint)point
                      inView:(UIView *)toView
               fromDirection:(TTSuckFromDirection)direction
                    hideView:(BOOL)hide
             completionBlock:(void (^)(void))completion;

@end
