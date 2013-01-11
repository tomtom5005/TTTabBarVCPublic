//
//  TTPinConfirmationAlertView.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/9/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "TTPinConfirmationAlertView.h"
#import "TTTraceGridView.h"
#import "UIButton+TTButton.h"
#import "UIView+AddBottomToTopLinearGradient.h"
#import "UIView+AddTopSheen.h"
#import "TTTraceGridTile.h"
#import "TTSelectedTiles.h"
#import "UIView+CenterInView.h"

@interface TTPinConfirmationAlertView()

-(void) createDismissButtonWithTitle:(NSString *)title;
-(void) createContainerView;

@end

@implementation TTPinConfirmationAlertView


- (id)initWithFrame:(CGRect)frame
                PIN:(NSString *)p
 dismissButtonTitle:(NSString *)title
    allowedAttempts:(NSInteger)attempts
            message:(NSString *) m
           gridRows:(NSInteger)r
        girdColumns:(NSInteger)cols
           delegate:(id)delegate
{
    r=r<kDefaultRows?kDefaultRows:r;
    r=r>kMaxGridDimension?kMaxGridDimension:r;
    cols=cols<kDefaultCols?kDefaultCols:cols;
    cols=cols>kMaxGridDimension?kMaxGridDimension:cols;
    
    self = [super initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    if (self) {
        self.pin = p;
        [self createDismissButtonWithTitle:title];
        self.attemptsAllowed = attempts;
        self.message = m;
        rows=r;
        columns=cols;
        attemptsMade=0;
        self.delegate = delegate;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:[[UIScreen mainScreen] applicationFrame]
                           PIN:[NSString string]
            dismissButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss")
               allowedAttempts:kDefaultAttemptsAllowed
                       message:nil
                      gridRows:kDefaultRows
                   girdColumns:kDefaultCols
                      delegate:nil];
}

- (id)init
{
    return [self initWithFrame:[[UIScreen mainScreen] applicationFrame]
                           PIN:[NSString string]
            dismissButtonTitle:NSLocalizedString(@"Dismiss",@"Dismiss")
               allowedAttempts:kDefaultAttemptsAllowed
                       message:nil
                      gridRows:kDefaultRows
                   girdColumns:kDefaultCols
                      delegate:nil];
}


//designated init

-(id) initWithPIN:(NSString *)p
dismissButtonTitle:(NSString *)title
  allowedAttempts:(NSInteger)attempts
          message:(NSString *) message
         gridRows:(NSInteger)r
      gridColumns:(NSInteger)cols
         delegate:(id)delegate
{
    return [self initWithFrame:[[UIScreen mainScreen] applicationFrame]
                           PIN:p
            dismissButtonTitle:title
               allowedAttempts:attempts
                       message:message
                      gridRows:r
                   girdColumns:cols
                      delegate:delegate];
}



-(void)createDismissButtonWithTitle:(NSString *)title
{
    self.dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _dismissButton.bounds = CGRectMake(0.0,0.0,160.0,30.0);
    
    //TODO: chg color of button and size - maybe just use tintColor
    [_dismissButton TTStyleButton];
    [_dismissButton addBottomToTopLinearGradientBottomColor:[UIColor colorWithRed:220/255 green:30/255 blue:0 alpha:.85] topColor:[UIColor colorWithRed:255/255 green:50/255 blue:45/255 alpha:.85]];
    [_dismissButton addTopLinearSheen];
    _dismissButton.titleLabel.text = title;
    _dismissButton.titleLabel.font = [UIFont systemFontOfSize:17];
    _dismissButton.titleLabel.minimumScaleFactor = 23.0/13.0;
    _dismissButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_dismissButton setTitle:title forState:UIControlStateNormal];

    [_dismissButton addTarget:self
                       action:@selector(dismissButtonTouched:)
            forControlEvents:UIControlEventTouchUpInside];
}

-(void) createContainerView
{
    self.containerView = [[UIView alloc]initWithFrame:self.bounds];
    CGFloat midX = CGRectGetMidX(self.bounds);
    self.traceView =[[TTTraceGridView alloc]
                initWithRows:rows
                columns:columns
                frame:CGRectMake((midX-160),0.0,320.0,320.0)];
    _traceView.clipsToBounds = YES;  //eliminates shadow
    _traceView.center = CGPointMake(midX,_containerView.bounds.size.height/2);
    _traceView.delegate = self;
    _containerView.alpha = 0.8;
    _containerView.backgroundColor = [UIColor clearColor];
    _containerView.layer.cornerRadius=25.0;
    
    [_containerView addSubview:_traceView];
    
    UILabel *messageLabel = [[UILabel alloc]
                             initWithFrame:CGRectMake(CGRectGetMidX(_containerView.bounds) - 160,
                                                      CGRectGetMaxY(_traceView.frame)+10,
                                                      320, 50)];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = [UIFont boldSystemFontOfSize:17];
    messageLabel.numberOfLines = 3;
    messageLabel.minimumScaleFactor = 12.0/17.0;    //so mininum font size = 12
    messageLabel.adjustsFontSizeToFitWidth = YES;
    messageLabel.text = self.message;
    [_containerView addSubview:messageLabel];
    
    _dismissButton.frame = CGRectMake(CGRectGetMidX(_containerView.bounds) - _dismissButton.bounds.size.width/2,
                                     CGRectGetMaxY(messageLabel.frame)+20,
                                     _dismissButton.bounds.size.width,
                                     _dismissButton.bounds.size.height);
    [_containerView addSubview:_dismissButton];
    
}


-(IBAction)dismissButtonTouched:(id)sender event:(UIEvent *)event
{
    self.dismissalReason = TTPinConfirmationAlertDismissalReasonUserDismissal;
    if([_delegate respondsToSelector:@selector(pinConfirmationAlertWasDismissed:)]){
        [_delegate pinConfirmationAlertWasDismissed:self];
    }
}

-(void) show
{
    //display alert
    //alert will have a trace grid view in it's center
    //with a button below it to dismiss the alert w/o
    //entering the PIN and a message of the user's chosing
    //
    self.backgroundColor=[UIColor clearColor];
    [self createContainerView];
    _containerView.alpha = 0;
    [self addSubview:_containerView];
    [_containerView centerInView:self];
   
    self.maskingLayer = [CALayer layer];
    _maskingLayer.bounds = CGRectMake(0.0, 0.0,
                                     _containerView.bounds.size.width/4,
                                     _containerView.bounds.size.height/4);
    CGFloat midX = CGRectGetMidX(self.layer.bounds);
    CGFloat midY = CGRectGetMidY(self.layer.bounds);
    _maskingLayer.position = CGPointMake(midX,midY);
    _maskingLayer.backgroundColor = [UIColor blackColor].CGColor;
    _maskingLayer.opacity = 0.0;
    [self.layer addSublayer:_maskingLayer];
    
    UIWindow *topWindow = [[[UIApplication sharedApplication].windows sortedArrayUsingComparator:^NSComparisonResult(UIWindow *window1, UIWindow *window2) {
        return window1.windowLevel - window2.windowLevel;
    }] lastObject];
    UIView *topView = [[topWindow subviews] lastObject];
    CGRect destinationFrame = _containerView.frame;
    _containerView.frame = CGRectMake(_containerView.frame.origin.x,
                                     - _containerView.bounds.size.height,
                                     _containerView.frame.size.width , _containerView.frame.size.height);
    _containerView.alpha = 1.0;
    _containerView.hidden=NO;
    [topView addSubview:self];
    [self bringSubviewToFront:self.containerView];
    [UIView animateWithDuration:0.4
                     animations:^{
                         _containerView.frame = CGRectOffset(destinationFrame,0,30);
                     } completion:^(BOOL finished){
                         _maskingLayer.opacity = 0.8;
                         [UIView animateWithDuration:0.2
                                               delay:0.0
                                             options:UIViewAnimationCurveEaseOut
                                          animations:^{
                                              _containerView.frame = destinationFrame;
                                              self.maskingLayer.frame = self.frame;
                                          } completion:^(BOOL finished){
                                          //[self performSelector:@selector(expandMask)withObject:nil afterDelay:0.0];
                                          }];
                     }];
}

-(void) expandMask
{
    self.maskingLayer.frame = self.frame;
}


-(void) dismiss
{
    [UIView animateWithDuration:0.4
                     animations:^{
                         _maskingLayer.opacity = 0.0;
                         _containerView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                     }];
}

-(void) dismissButtonTouched:(id)sender
{
    //typically this is a logout button since the user did not
    //enter the pin correctly but rather hit the dismiss button
    self.dismissalReason = TTPinConfirmationAlertDismissalReasonUserDismissal;
    if([_delegate respondsToSelector:@selector(pinConfirmationAlertWasDismissed:)])
    {
        [_delegate pinConfirmationAlertWasDismissed:self];
    }
}

#pragma mark TraceGridView delegate methods

-(void)traceGridViewDidFinishTrace:(TTTraceGridView *)tView
{
    NSString *pinString = @"";
    BOOL validPIN = NO;
    
    if([tView.selectedTiles count] < 79)    //ascii 48 - 126
                                            //- we can have only 64 tiles 8x8
    {           
        @synchronized(_traceView.selectedTiles.tiles)
        {
            int i = 0;
            for (TTTraceGridTile *tile in tView.selectedTiles.tiles)
            {
                NSString *charStr = [NSString stringWithFormat:@"%c",(tile.tileNumber+48)];
                pinString = [NSString stringWithFormat:@"%@%@",pinString,charStr];
                i++;
                if(i>=[self.pin length])
                {
                    if ([pinString isEqualToString:self.pin]){
                        validPIN  = YES;
                        break;}
                }
            }
        }
    }
    if(validPIN)
    {
        self.dismissalReason = TTPinConfirmationAlertDismissalReasonPinMatch;
        if([_delegate respondsToSelector:@selector(pinConfirmationAlertWasDismissed:)]){
            [_delegate pinConfirmationAlertWasDismissed:self];
        }
    }
    else
    {
        if(attemptsMade <_attemptsAllowed){
            [_traceView shakeView];
            attemptsMade ++;
        }
        else    //too many attempts
        {
            self.dismissalReason = TTPinConfirmationAlertDismissalReasonAllowedAttempsExceeded;
            if([_delegate respondsToSelector:@selector(pinConfirmationAlertWasDismissed:)]){
                [_delegate pinConfirmationAlertWasDismissed:self];
            }
            
        }
    }
    [_traceView resetTracePathWithAnimation:YES];
}

@end
