//
//  UIView+AddBottomToTopLinearGradient.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (AddBottomToTopLinearGradient)

//adds a gradient to the view below all the other sublayers
//this works on the entire bounds of the view
//if you need the gradient to be clipped then
//use the maskToBounds property of self.layer
//or the clipsToBounds property of the view

-(void)addBottomToTopLinearGradientBottomColor:(UIColor *)bottomColor
                                      topColor:(UIColor *)topColor;

@end
