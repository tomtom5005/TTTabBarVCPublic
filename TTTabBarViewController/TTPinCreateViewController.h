//
//  TTPinCreateViewController.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/2/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#define kInstructionsLabelHeight 80
#define kInstructionsLabelWidth 500

#import <UIKit/UIKit.h>

 NSString *const TTTabBarViewSelectedTabDidChangeFromTabAtIndexNotification; //declared in TTTabBarView
 NSString *const TTTabBarViewSelectedViewWillChangeToViewNotification; //declared in TTTabBarView
 NSString *const TTTabBarViewSelectedViewDidChangeToViewNotification; //declared in TTTabBarView

@protocol TTPinCreateViewControllerDelegate;

@class TTTraceGridView;
@class TTRoundedTextView;

@interface TTPinCreateViewController : UIViewController

@property (weak, nonatomic) NSObject<TTPinCreateViewControllerDelegate> *delegate;

-(void) setUp;
-(void) viewWillAppearInTabBarView:(NSNotification *)note;

@end

@protocol TTPinCreateViewControllerDelegate <NSObject>

//optional delegate method
-(void)TTPinCreateViewControllerDidChangePin:(TTPinCreateViewController *)controller;
-(void)TTPinCreateViewControllerFailedToChangePin:(TTPinCreateViewController *)controller;

@end
