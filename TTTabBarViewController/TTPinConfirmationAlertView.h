//
//  TTPinConfirmationAlertView.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/9/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class TTTraceGridView;

#define kDefaultAttemptsAllowed 3
#define kDefaultRows 3
#define kDefaultCols 3
#define kMaxGridDimension 8
#define kBounce 30.0f

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

@property (assign) NSInteger attemptsAllowed;
@property (nonatomic, strong) NSString *message;
@property (assign) TTPinConfirmationAlertDismissalReason dismissalReason;
@property (nonatomic, weak) id <TTPinConfirmationAlertDelegate> delegate;
@property (nonatomic, strong) NSString *pin;

-(id) initWithPIN:(NSString *)p
dismissButtonTitle:(NSString *)title
  allowedAttempts:(NSInteger)attempts
          message:(NSString *)m
         gridRows:(NSInteger) r
      gridColumns:(NSInteger) cols
         delegate:(id)delegate; 

-(void) show;
-(void) dismiss;

@end

@protocol TTPinConfirmationAlertDelegate <NSObject>
@optional
-(void)pinConfirmationAlertWillDismissView:(TTPinConfirmationAlertView *)pinAlert;
-(void)pinConfirmationAlertDidDismissView:(TTPinConfirmationAlertView *)pinAlert;

@end
