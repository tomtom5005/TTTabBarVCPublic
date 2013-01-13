//
//  TTAppDelegate.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/1/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTLoginViewController;

@interface TTAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) TTLoginViewController *viewController;
@property (strong, nonatomic) NSString *PIN;

@end
