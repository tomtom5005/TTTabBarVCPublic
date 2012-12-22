//
//  UIView+FoldTransitionFromViewToView.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/18/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

typedef enum {TTFoldTransitionDirectionUp, TTFoldTransitionDirectionDown} TTFoldTransitionDirection;

@interface UIView (FoldTransitionFromViewToView)

+ (void)foldTransitionFromView:(UIView *)fromView
                        toView:(UIView*)toView
                     direction:(TTFoldTransitionDirection)direction
                      duration:(NSTimeInterval)duration
                    completion:(void (^)(void))completion;
;
@end
