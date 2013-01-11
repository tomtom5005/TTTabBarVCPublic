//
//  TTPinCreateViewController.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/2/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//



#import "TTTraceGridView.h"
#import "TTAppDelegate.h"
#import "TTTraceGridTile.h"
#import "TTRoundedTextView.h"
#import "TTSelectedTiles.h"
#import "TTPinCreateViewController.h"
#import "UIView+AddBottomToTopLinearGradient.h"
#import "UIView+AddTopSheen.h"
#import "UIButton+TTButton.h"
#import "UIView+AddTranslucentColoredOverlay.h"
#import "UIView+MinimizeToContainOnlyVisibleSubviews.h"
#import "Constants.h"
#import "TTPinUtils.h"
#import "TTTabBarView.h"
#import "TTPinConfirmationAlertView.h"

@interface TTPinCreateViewController ()
{
    UIImage *landscapeGradientImg;
    UIImage *portraitGradientImg;
    CALayer *gradientLayer;
}
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (nonatomic, weak) UIImage *blackGradientImage; //special getter


-(void) adjustPINViewForOrientation;
-(void) dismiss:(id)sender;

@end

@implementation TTPinCreateViewController
{
    NSString *firstPIN;
}


-(void) dealloc
{
    NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
    [ns removeObserver:self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    return [self initWithNibName:@"PINCreateViewController" bundle:nil];
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
}

-(void) viewWillAppear:(BOOL)animated
{
    TTPinUtils *pinUtils = [TTPinUtils sharedPinUtils];
    if( ! pinUtils.PIN)
    {
        self.instructionsLabel.text = [NSString stringWithFormat: NSLocalizedString(@"Create desired pattern by tracing over the grid.\nThe Pattern must contain at least %d nodes.  ", @"Create desired pattern by tracing over the grid.\nThe Pattern must contain at least %d nodes.  "),kMinPinLength];
    }
    else
    {
        self.instructionsLabel.text = [NSString stringWithFormat: NSLocalizedString(@"You already have a valid PIN.\nTo change the pattern trace over the grid.\nThe Pattern must contain at least %d nodes.  ", @"You already have a valid PIN.\nTo change the pattern trace over the grid.\nThe Pattern must contain at least %d nodes.  "),kMinPinLength];
        
    }
    firstPIN = @"";
    
    //for reasons having to do with a static variable in the animation routine we need to instantiate
    //the grid view everytime the view is shown.  We probably could get around this if we used a global
    //variable instead but it gets a bit messy since that variable would have to be set in a few places
    //This is tidy, if a bit wasteful of cpu - but we draw it efficiently
    //
    TTTraceGridView *tGrid = [[TTTraceGridView alloc]
                      initWithRows:kPatternGridSize
                      columns:kPatternGridSize
                      frame:CGRectMake(0,0,
                                       300,300)];
    self.traceGrid = tGrid;
    CGFloat x = (self.containerView.bounds.size.width - _traceGrid.bounds.size.width)/2;
    self.traceGrid.frame = CGRectMake(x,0,
                                      _traceGrid.bounds.size.width,
                                      _traceGrid.bounds.size.height);
    self.traceGrid.delegate = self;
    [self.containerView addSubview:self.traceGrid];

    if(self.presentingViewController)
    {
        self.cancelButton.hidden=NO;
    }
}

-(void) viewDidAppear:(BOOL)animated
{
    int len = kMinPatternLength < 6 ? 6 : kMinPatternLength;
    [self.traceGrid animateRandomTracePatternsOfLength:len withDelay:0.3];
}

-(void) setUp
{
    gradientLayer = [CALayer layer];
    gradientLayer.frame = self.view.frame;
    gradientLayer.contents = (__bridge id) self.blackGradientImage.CGImage;
    [self.view.layer addSublayer:gradientLayer];
    
    CGFloat containerW = kInstructionsLabelWidth > kTraceGridWidth ? kInstructionsLabelWidth : kTraceGridWidth;
    CGFloat containerX = (self.view.bounds.size.width - containerW)/2;
    CGFloat containerH = kTraceGridHeight + 40.0 + kInstructionsLabelHeight;
    CGFloat containerY = (self.view.bounds.size.height - containerH)/2;
    UIView *cView = [[UIView alloc] initWithFrame:CGRectMake(containerX,
                                                             containerY,
                                                             containerW,
                                                             containerH)];
    cView.backgroundColor = [UIColor clearColor];
    self.containerView = cView;
    
    
    UILabel *iLabel = [[UILabel alloc]
                       initWithFrame:CGRectMake( (self.containerView.bounds.size.width - kInstructionsLabelWidth)/2,
                                                self.containerView.bounds.size.height - kInstructionsLabelHeight,
                                                kInstructionsLabelWidth,
                                                kInstructionsLabelHeight)];
    
    iLabel.backgroundColor = [UIColor clearColor];
    iLabel.font = [UIFont systemFontOfSize:17.0];
    iLabel.textColor = [UIColor lightGrayColor];
    iLabel.textAlignment = NSTextAlignmentCenter;
    iLabel.numberOfLines = 4;
    iLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Create desired pattern by tracing over the grid.  The pattern must contain at least %d nodes.", @"Create desired pattern by tracing over the grid.  The pattern must contain at least %d nodes."),kMinPatternLength];
    self.instructionsLabel = iLabel;
    [self.containerView addSubview:self.instructionsLabel];
    
    UIButton *canButton = [UIButton buttonWithType:UIButtonTypeCustom];
    canButton.bounds = CGRectMake(0.0,0.0,200.0,46.0);
    canButton.center = CGPointMake(_instructionsLabel.center.x,
                                   _instructionsLabel.frame.origin.y + _instructionsLabel.bounds.size.height +50.0);
    [canButton TTStyleButton];
    
    [canButton addBottomToTopLinearGradientBottomColor:[UIColor colorWithRed:220/255 green:30/255 blue:0 alpha:.85] topColor:[UIColor colorWithRed:255/255 green:50/255 blue:45/255 alpha:.85]];
    [canButton addTopLinearSheen];
    [canButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [canButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    canButton.titleLabel.font = [UIFont boldSystemFontOfSize:23];
    canButton.titleLabel.minimumScaleFactor = 23.0/13.0;
    canButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [canButton setTitle: NSLocalizedString(@"Cancel",@"Cancel") forState:UIControlStateNormal];
    [canButton addTarget:self
                      action:@selector(dismiss:)
            forControlEvents:UIControlEventTouchUpInside];

    self.cancelButton = canButton;
    [self.containerView addSubview:self.cancelButton];

    
    [self.view addSubview:self.containerView];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(viewWillAppearInTabBarView:)
               name:TTTabBarViewSelectedViewWillChangeToViewNotification
             object:nil];
}


-(void) viewWillLayoutSubviews
{
    if(self.containerView)   //if no containerView then viewDidLoad has not completed
    {
        //the self.view bounds are the bounds AFTER the change but the frame is the frame BEFORE
        //the change but with the status bar removed
        [self.containerView mininumizeToContainOnlyVisibleSubviews];
        [self adjustPINViewForOrientation];
        CGFloat x = CGRectGetMidX(self.view.bounds);
        CGFloat y = CGRectGetMidY(self.view.bounds);
        gradientLayer.bounds = self.view.bounds;
        gradientLayer.position = CGPointMake(x,y);
        gradientLayer.contents = (__bridge id) self.blackGradientImage.CGImage;
    }
}

-(void) adjustPINViewForOrientation
{
    CGFloat x = CGRectGetMidX(self.view.bounds) - self.containerView.bounds.size.width/2;
    CGFloat y = CGRectGetMidY(self.view.bounds) - self.containerView.bounds.size.height/2;
    self.containerView.frame= CGRectMake(x,y,
                                    self.containerView.bounds.size.width,
                                    self.containerView.bounds.size.height);
}

-(void) viewDidDisappear:(BOOL)animated
{
    [self.traceGrid removeFromSuperview];
    self.traceGrid = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TTTabBarView Notification Methods

-(void) viewWillAppearInTabBarView:(NSNotification *)note
{
    if(self.view == note.userInfo[@"View"])
    {
        TTTabBarView *tabBarView = (TTTabBarView *)note.object;
        self.view.frame = tabBarView.selectedViewContainerView.bounds;
        self.cancelButton.hidden = YES;
    }
}



#pragma mark - TraceGridView delegate methods


-(void)traceGridViewDidFinishTrace:(TTTraceGridView *)traceView
{
    NSString *pin = @"";
    if([traceView.selectedTiles count] < 79)    //ascii 48 - 126
        //- we can have only 64 tiles 8x8 so this should never be a proplem
        //we cannot deciper integers > 79
    {
        if([traceView.selectedTiles count]>(kMinPinLength-1) )
        {
            @synchronized(traceView.selectedTiles.tiles)
            {
                for (TTTraceGridTile *tile in traceView.selectedTiles.tiles)
                {
                    NSString *charStr = [NSString stringWithFormat:@"%c",(tile.tileNumber+48)];
                    pin = [NSString stringWithFormat:@"%@%@",pin,charStr];
                }
            }
            if([firstPIN length])
            {
                if([firstPIN isEqualToString:pin])
                {
                    //persist pin on server or locally
                    self.instructionsLabel.text = NSLocalizedString(@"PIN sucessfully created.",@"PIN sucessfully created.");
                    TTPinUtils *pu = [TTPinUtils sharedPinUtils];
                    pu.PIN = pin;
                    firstPIN = @"";
                    pin = @"";
                    if(self.presentingViewController){
                        [self dismiss:self.traceGrid];
                    }
                }
                else
                {
                    firstPIN = @"";
                    pin = @"";
                    self.instructionsLabel.text = NSLocalizedString(@"The patterns do not match.  Please try again",@"The patterns do not match.  Please try again");
                    firstPIN=@"";
                    [self.traceGrid shakeView];
                }
            }
            else    //firstPIN is empty so this is the first entry of the pattern
            {
                firstPIN = [NSString stringWithFormat:@"%@",pin];
                pin=@"";
                self.instructionsLabel.text = NSLocalizedString(@"Please confirm your pattern by re-entering it.",@"Please confirm your pattern by re-entering it.");
            }
        }
        else    //pattern contains too few nodes
        {
            self.instructionsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"You must include at least %d nodes in your pattern.",@"You must include at least %d nodes in your pattern."),kMinPatternLength];
            [self.traceGrid shakeView];
            pin=@"";
            firstPIN = @"";
        }
    }
    else //grid >8x8 This will never happen unless the code is broken
    {
        NSLog(@"TraceGrid > 8x8.  This should never happen!  error in PINCreateViewController");
    }
    [traceView resetTracePathWithAnimation:YES];
}

-(void) dismiss:(id)sender
{
    if(self.presentingViewController)
    {
        self.presentingViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self dismissViewControllerAnimated:YES completion:^{
            self.presentingViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;}];
    }
}

#pragma mark - accessors

-(UIImage *) blackGradientImage
{
    BOOL imageCreated = NO;
    switch (self.interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            if (landscapeGradientImg) {
                imageCreated = YES;
                _blackGradientImage = landscapeGradientImg;
            }
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            if (portraitGradientImg) {
                imageCreated = YES;
                _blackGradientImage = portraitGradientImg;
            }
            break;
    }
    if( ! imageCreated)
    {
        CGFloat colors[6] = {60.0/255.0, 1.0,
            80.0/255.0, 1.0,
            100.0/255.0, 1.0};
        CGFloat locations[3] = {0.05,0.45,0.95};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGGradientRef blackGradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 3);
        CGColorSpaceRelease(colorSpace);
        
        //create a black gradient for the view's background
        UIGraphicsBeginImageContext(self.view.bounds.size);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGPoint startPoint = CGPointMake(CGRectGetMidX(self.view.bounds),
                                         CGRectGetMinY(self.view.bounds));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(self.view.bounds),
                                       CGRectGetMaxY(self.view.bounds));
        CGContextDrawLinearGradient(ctx, blackGradient, startPoint, endPoint, 0);
        _blackGradientImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        switch (self.interfaceOrientation)
        {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                landscapeGradientImg = _blackGradientImage;
                break;
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
                portraitGradientImg = _blackGradientImage;
                break;
        }
        UIGraphicsEndImageContext();
    }
    return _blackGradientImage;
}


@end
