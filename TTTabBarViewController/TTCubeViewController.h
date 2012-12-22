//
//  TTCubeViewController.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/16/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//


#define kBoxSideWidth 200

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@interface TTCubeViewController : UIViewController

@property (nonatomic, strong)  UIView *containerView;
- (void)setUp;
@end
