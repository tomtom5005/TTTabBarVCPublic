//
//  TTPinConfirmationAlertView.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/9/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTTraceGridView;

#define kDefaultAttemptsAllowed 3
#define kDefaultRows 3
#define kDefaultCols 3
#define kMaxGridDimension 8

typedef enum{
    TTPinConfirmationAlertDismissalReasonPinMatch,
    TTPinConfirmationAlertDismissalReasonAllowedAttempsExceeded,
    TTPinConfirmationAlertDismissalReasonUserDismissal
}TTPinConfirmationAlertDismissalReason;

@protocol TTPinConfirmationAlertDelegate;

@interface TTPinConfirmationAlertView : UIView
{
@private
    NSInteger attemptsMade;
    NSInteger rows, columns;
}

@property (nonatomic, strong) UIButton *dismissButton;
@property (nonatomic, strong) TTTraceGridView *traceView;
@property (nonatomic, strong) NSString *pin;
@property (assign) NSInteger attemptsAllowed;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) CALayer *maskingLayer;
@property (assign) TTPinConfirmationAlertDismissalReason dismissalReason;
@property (nonatomic, weak) id delegate;

-(id) initWithPIN:(NSString *)p
dismissButtonTitle:(NSString *)title
  allowedAttempts:(NSInteger)attempts
          message:(NSString *)m
         gridRows:(NSInteger) r
      gridColumns:(NSInteger) cols
         delegate:(id)delegate;

-(void) show;
-(IBAction)dismissButtonTouched:(id)sender event:(UIEvent *)event;
-(void) dismiss;
@end

@protocol TTPinConfirmationAlertDelegate <NSObject>

-(void)pinConfirmationAlertWasDismissed:(TTPinConfirmationAlertView *)pinAlert;

@end
