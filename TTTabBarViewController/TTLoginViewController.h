//
//  TTLoginViewController.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/11/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define kLoginUrlString @"http://www.tsquaredapplications.com/TabBarDemo/TTTabBarDemoLogin.php"
@interface TTLoginViewController : UIViewController <UITextFieldDelegate>
- (IBAction)login:(id)sender;

@end
