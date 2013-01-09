//
//  TTColorPatchViewController.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/8/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString *const TTTabBarViewSelectedViewWillChangeToViewNotification; //declared in TTTabBarView

@interface TTColorPatchViewController : UIViewController

@property (nonatomic, weak) UILabel *label;

-(void) setUp;
- (id)initWithColor:(UIColor *)c;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil color:(UIColor *)c;

@end
