//
//  UIView+ShakeView.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "UIView+ShakeView.h"

@implementation UIView (ShakeView)

#define kShakeIncrement 1

-(void) shakeViewNTimes:(NSUInteger)numShakes startLeft:(BOOL)startLeft completion:(void(^)(void))completion
{
    static int i=0;
    CGFloat shakeDelta;
    static CGFloat prevShakeDelta = 0;
    BOOL left = startLeft;
    
    if(numShakes%2>0)
        numShakes ++;
    left = i%2>0 ? startLeft : ! startLeft;
    UIViewAnimationOptions option = i==(numShakes-1) ? UIViewAnimationOptionCurveEaseOut : UIViewAnimationOptionCurveLinear;
    shakeDelta = (numShakes-i)*(kShakeIncrement);
    CGFloat x = left == YES ? self.center.x-(shakeDelta+prevShakeDelta): self.center.x+((shakeDelta+prevShakeDelta));
    prevShakeDelta = shakeDelta;
    [UIView animateWithDuration:0.1
                          delay:0
                        options:option
                     animations:^{
                         CGPoint newCenterPt = CGPointMake(x, self.center.y);
                         self.center = newCenterPt;
                     }
                     completion:^(BOOL finished){
                         if(i==numShakes-1){
                             i=0;
                             prevShakeDelta = 0;
                             completion();
                         }else{
                             i++;
                             [self shakeViewNTimes:numShakes startLeft:startLeft completion:completion
                              ];
                         }
                     }];
}
@end
