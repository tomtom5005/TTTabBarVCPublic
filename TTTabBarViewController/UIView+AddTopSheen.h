//
//  UIView+AddTopSheen.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface UIView (AddTopSheen)

-(void)addTopLinearSheen;   //adds a sheen to the top half of the view's
//above the top layer
//this works on the entire bounds of the view
//if you need the sheen to be clipped then
//use the maskToBounds property of a superLayer
//or the clipsToBounds property of the view

@end
