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
#import "UIView+TopVisibleWindow.h"
#import "TTTraceGridTile.h"
#import "TTSelectedTiles.h"
#import "UIView+CenterInView.h"
#import "TTMainOperationQueue.h"
#import "TTAppDelegate.h"

@interface TTPinConfirmationAlertView()
{
    BOOL maskExpanded;
    UIButton *dismissButton;
    TTTraceGridView *traceView;
    UIView *containerView;
    CALayer *maskingLayer;
    id orientationChangeObserver;
    UIInterfaceOrientation previousOrientation;
    CGAffineTransform *transform;
    UIView *rootView;
    UIWindow *alertWindow;
   // CAKeyframeAnimation *rotateAnimation;
}

//@property (nonatomic, strong) id orientationChangeObserver;

-(void) createDismissButtonWithTitle:(NSString *)title;
-(void) createContainerView;
-(void) adjustViewOrientation;
-(void) expandMask;
-(void) adjustContainerViewForOrientation;
-(void) dismissButtonTouched:(id)sender;

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
        _pin = p;
        [self createDismissButtonWithTitle:title];
        _attemptsAllowed = attempts;
        _message = m;
        rows=r;
        columns=cols;
        attemptsMade=0;
        
        self.autoresizesSubviews = YES;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        /*
         typedef enum {
         UIDeviceOrientationUnknown,
         UIDeviceOrientationPortrait,
         UIDeviceOrientationPortraitUpsideDown,
         UIDeviceOrientationLandscapeLeft,
         UIDeviceOrientationLandscapeRight,
         UIDeviceOrientationFaceUp,
         UIDeviceOrientationFaceDown
         } UIDeviceOrientation;
         
         typedef enum {
         UIInterfaceOrientationPortrait           = UIDeviceOrientationPortrait,
         UIInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
         UIInterfaceOrientationLandscapeLeft      = UIDeviceOrientationLandscapeRight,
         UIInterfaceOrientationLandscapeRight     = UIDeviceOrientationLandscapeLeft
         } UIInterfaceOrientation;
         */
        //rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        //rotateAnimation.valueFunction = [CAValueFunction functionWithName:kCAValueFunctionRotateZ];

        orientationChangeObserver = [[NSNotificationCenter defaultCenter]
                                     addObserverForName:UIDeviceOrientationDidChangeNotification
                                     object:nil
                                     queue:nil
                                     usingBlock:^(NSNotification *note){
                                         /*
                                          self.layer.transform = rootView.layer.transform;
                                          [self.layer addAnimation:[rootView.layer animationForKey:@"position"] forKey:@"position"];
                                          [self.layer addAnimation:[rootView.layer animationForKey:@"bounds"] forKey:@"bounds"];
                                          [self.layer addAnimation:[rootView.layer animationForKey:@"transform"] forKey:@"transform"];
                                          */
                                         /*
                                         [CATransaction begin];
                                         
                                         [CATransaction setCompletionBlock:^(void) {
                                             [self layoutSubviews];
                                         }];
                                         self.layer.transform = rootView.layer.transform;
                                         [self.layer addAnimation:[rootView.layer animationForKey:@"position"] forKey:@"position"];
                                         [self.layer addAnimation:[rootView.layer animationForKey:@"bounds"] forKey:@"bounds"];
                                         [self.layer addAnimation:[rootView.layer animationForKey:@"transform"] forKey:@"transform"];
                                         
                                         [CATransaction commit];
                                         */
                                         [self setNeedsLayout];
                                     }];
        
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

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:orientationChangeObserver];
}

-(void) layoutSubviews
{
//  [containerView centerInView:self];
  //  if(maskExpanded)
  //      maskingLayer.bounds=self.bounds;
   // containerView.center = CGPointMake(rint(CGRectGetMidX(self.bounds)),
   //                                    rint(CGRectGetMidY(self.bounds)));
    //[self adjustContainerViewForOrientation];
    //[self expandMask];
}

#pragma mark - TTPinAlertView methods

-(void) adjustViewOrientation
{    
    CGFloat windowPortraitWidth = [[UIScreen mainScreen] bounds].size.width;
    CGFloat windowPortraitHeight = [[UIScreen mainScreen] bounds].size.height;
    
    switch ([[UIApplication sharedApplication] statusBarOrientation])
    {
        case UIInterfaceOrientationPortrait:
            self.frame = CGRectMake(0,0,windowPortraitWidth,windowPortraitHeight-20);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
           self.frame = CGRectMake(0,0,windowPortraitWidth,windowPortraitHeight-20);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            self.frame = CGRectMake(0,0,windowPortraitHeight, windowPortraitWidth-20);
            break;
        case UIInterfaceOrientationLandscapeRight:
            self.frame = CGRectMake(0,0,windowPortraitHeight, windowPortraitWidth-20);
            break;

        default:
            break;
    }
}


-(void)createDismissButtonWithTitle:(NSString *)title
{
    dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dismissButton.bounds = CGRectMake(0.0,0.0,160.0,30.0);
    
    //TODO: chg color of button and size - maybe just use tintColor
    [dismissButton TTStyleButton];
    [dismissButton addBottomToTopLinearGradientBottomColor:[UIColor colorWithRed:220/255 green:30/255 blue:0 alpha:.85] topColor:[UIColor colorWithRed:255/255 green:50/255 blue:45/255 alpha:.85]];
    [dismissButton addTopLinearSheen];
    dismissButton.titleLabel.text = title;
    dismissButton.titleLabel.font = [UIFont systemFontOfSize:17];
    dismissButton.titleLabel.minimumScaleFactor = 23.0/13.0;
    dismissButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [dismissButton setTitle:title forState:UIControlStateNormal];

    [dismissButton addTarget:self
                       action:@selector(dismissButtonTouched:)
            forControlEvents:UIControlEventTouchUpInside];
}

-(void) createContainerView
{
    containerView = [[UIView alloc]initWithFrame:self.bounds];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    /*

                                    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin |
                                    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
     */
    CGFloat midX = CGRectGetMidX(self.bounds);
    traceView =[[TTTraceGridView alloc]
                initWithRows:rows
                columns:columns
                frame:CGRectMake((midX-160),0.0,320.0,320.0)];
    //traceView.clipsToBounds = YES;  //eliminates shadow
    traceView.center = CGPointMake(midX,containerView.bounds.size.height/2);
    traceView.delegate = self;
    traceView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
                                    UIViewAutoresizingFlexibleBottomMargin;
    
    containerView.alpha = 0.8;
    containerView.backgroundColor = [UIColor clearColor];
    containerView.layer.cornerRadius=25.0;
    
    [containerView addSubview:traceView];
    
    UILabel *messageLabel = [[UILabel alloc]
                             initWithFrame:CGRectMake(CGRectGetMidX(containerView.bounds) - 160,
                                                      CGRectGetMaxY(traceView.frame)+10,
                                                      320, 50)];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.font = [UIFont boldSystemFontOfSize:17];
    messageLabel.numberOfLines = 3;
    messageLabel.minimumScaleFactor = 12.0/17.0;    //so mininum font size = 12
    messageLabel.adjustsFontSizeToFitWidth = YES;
    messageLabel.text = self.message;
    messageLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
                                    UIViewAutoresizingFlexibleBottomMargin;
    [containerView addSubview:messageLabel];
    
    dismissButton.frame = CGRectMake(CGRectGetMidX(containerView.bounds) - dismissButton.bounds.size.width/2,
                                     CGRectGetMaxY(messageLabel.frame)+20,
                                     dismissButton.bounds.size.width,
                                     dismissButton.bounds.size.height);
    dismissButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin |
                                        UIViewAutoresizingFlexibleBottomMargin;
    [containerView addSubview:dismissButton];
    
}

-(void) adjustContainerViewForOrientation
{
    UIApplication *app = [UIApplication sharedApplication];
    CGFloat windowPortraitWidth = [[UIScreen mainScreen  ]bounds].size.width;
    CGFloat windowPortraitHeight = [[UIScreen mainScreen  ]bounds].size.height;
    CGFloat statusBarHeight = windowPortraitHeight - [[UIScreen mainScreen] applicationFrame].size.height;
    /*
    _containerView.center = CGPointMake(CGRectGetMidX([self bounds]),
                                        CGRectGetMidY([self bounds]));
    */
    CGFloat x,y;
    switch ([app statusBarOrientation])
    {
        case UIInterfaceOrientationLandscapeLeft:
            x = (windowPortraitHeight - containerView.bounds.size.width)/2.0;
            y = (windowPortraitWidth-statusBarHeight - containerView.bounds.size.height)/2.0;
            break;
            
        case UIInterfaceOrientationLandscapeRight:
            x = (windowPortraitHeight - containerView.bounds.size.width)/2.0;
            y = (windowPortraitWidth-statusBarHeight - containerView.bounds.size.height)/2.0;
            break;
            
        case UIInterfaceOrientationPortrait:
            x = (windowPortraitWidth - containerView.bounds.size.width)/2.0;
            y = (windowPortraitHeight-statusBarHeight - containerView.bounds.size.height)/2.0;
            break;
            
        case UIInterfaceOrientationPortraitUpsideDown:
            x = (windowPortraitWidth - containerView.bounds.size.width)/2.0;
            y = (windowPortraitHeight-statusBarHeight - containerView.bounds.size.height)/2.0;
            break;
            
        default:
            break;
    }
    containerView.frame = CGRectMake(x,y,
                                      containerView.bounds.size.width,
                                      containerView.bounds.size.height);
}


-(void) show
{
    //display alert
    //alert will have a trace grid view in it's center
    //with a button below it to dismiss the alert w/o
    //entering the PIN and a message of the user's chosing
    //
    previousOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    TTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    rootView = appDelegate.window.rootViewController.view;
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    //create a new window to hold the PIN confirmation alert view
    alertWindow  = [[UIWindow alloc] initWithFrame:topWindow.frame];
    [alertWindow setBackgroundColor:[UIColor clearColor]];
    self.frame = [alertWindow bounds];
    self.backgroundColor=[UIColor clearColor];
    [alertWindow addSubview:self];
    [alertWindow makeKeyAndVisible];

    [self createContainerView];
    containerView.alpha = 0;
    [self addSubview:containerView];
    [containerView centerInView:self];
    CGRect destinationFrame = containerView.frame;

    maskingLayer = [CALayer layer];
    maskingLayer.bounds = CGRectMake(0.0, 0.0,
                                     rint(containerView.bounds.size.width/4.0),
                                     rint(containerView.bounds.size.height/4.0));
    CGFloat midX = CGRectGetMidX(self.layer.bounds);
    CGFloat midY = CGRectGetMidY(self.layer.bounds);
    maskingLayer.position = CGPointMake(midX,midY);
    maskingLayer.backgroundColor = [UIColor blackColor].CGColor;
    maskingLayer.opacity = 0.0;
    [self.layer addSublayer:maskingLayer];
    
    //move _containerView above screen
    containerView.frame = CGRectMake(containerView.frame.origin.x,
                                     - containerView.bounds.size.height,
                                     containerView.frame.size.width , containerView.frame.size.height);
    containerView.alpha = 1.0;
    containerView.hidden=NO;
    [self bringSubviewToFront:containerView];
    
    [alertWindow bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         containerView.frame = CGRectOffset(destinationFrame,0,30);
                     } completion:^(BOOL finished){
                         maskingLayer.opacity = 0.8;
                         [UIView animateWithDuration:0.2
                                               delay:0.0
                                             options:UIViewAnimationCurveEaseOut
                                          animations:^{
                                              containerView.frame = destinationFrame;
                                              maskingLayer.frame = self.bounds;
                                          } completion:^(BOOL finished){
                                              maskExpanded = YES;
                                              [self bringSubviewToFront:traceView];
                                          //[self performSelector:@selector(expandMask)withObject:nil afterDelay:0.0];
                                          }];
                     }];
}

-(void) expandMask
{
    maskingLayer.frame = self.frame;
}


-(void) dismiss
{
    if([_delegate respondsToSelector:@selector(pinConfirmationAlertWillDismissView:)]){
        [_delegate pinConfirmationAlertWillDismissView:self];
    }
    [UIView animateWithDuration:0.4
                     animations:^{
                         maskingLayer.opacity = 0.0;
                         containerView.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                        [alertWindow removeFromSuperview];
                         alertWindow = nil;
                         if([_delegate respondsToSelector:@selector(pinConfirmationAlertDidDismissView::)]){
                             [_delegate pinConfirmationAlertDidDismissView:self];
                         }
                     }];
}

-(void) dismissButtonTouched:(id)sender
{
    //typically this is a logout button since the user did not
    //enter the pin correctly but rather hit the dismiss button
    self.dismissalReason = TTPinConfirmationAlertDismissalReasonUserDismissal;
    [self dismiss];
}

#pragma mark - TraceGridView delegate methods

-(void)traceGridViewDidFinishTrace:(TTTraceGridView *)tView
{
    NSString *pinString = @"";
    BOOL validPIN = NO;
    
    if([tView.selectedTiles count] < 79)    //ascii 48 - 126
                                            //- we can have only 64 tiles 8x8
    {           
        @synchronized(traceView.selectedTiles.tiles)
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
        [self dismiss];
    }
    else
    {
        if(attemptsMade <_attemptsAllowed){
            [traceView shakeView];
            attemptsMade ++;
        }
        else    //too many attempts
        {
            self.dismissalReason = TTPinConfirmationAlertDismissalReasonAllowedAttempsExceeded;
            [self dismiss];
        }
    }
    [traceView resetTracePathWithAnimation:YES];
}

@end
