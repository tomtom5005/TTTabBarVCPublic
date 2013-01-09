//
//  TTViewController.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/1/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "TTTabBarView.h"

#define kNumberOfDemoViewControllers 2
#define kColorsMultiple 4

@interface TTViewController : UIViewController<TTTabBarViewDataSource, TTTabBarViewDelegate>


-(IBAction) addViewToBarButton:(id)sender;  //suck
-(IBAction) lockScreen:(id)sender;

@end
