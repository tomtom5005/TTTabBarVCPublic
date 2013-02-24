//
//  TTColorPatchViewController.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/8/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "TTColorPatchViewController.h"
#import "TTColorPatchView.h"
#import "TTTabBarView.h"

@interface TTColorPatchViewController ()
{
    CALayer *gradientLayer;
    UIImage *landscapeGradientImg;
    UIImage *portraitGradientImg;
    TTColorPatchView *colorPatch;
    UIColor *color;
}
@property (nonatomic, weak) UIImage *grayGradientImage; //special getter

@end

@implementation TTColorPatchViewController

- (id)initWithColor:(UIColor *)c
{
    return [self initWithNibName:nil bundle:nil color:c];
}

- (id)init
{
    return [self initWithNibName:nil bundle:nil color:[UIColor blackColor]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil color:(UIColor *)c
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        color = c;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setUp];
}

-(void) dealloc
{
    NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
    [ns removeObserver:self];
}

-(void) setUp
{
    UIImageView *imgView = [[UIImageView alloc] initWithImage:self.grayGradientImage];
    imgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:imgView];
    
    //create a label and a view with rounded corners and a shadow
    //the most efficient way is to draw a path and a shadow
    colorPatch = [[TTColorPatchView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/3,
                                                                    self.view.bounds.size.height/4,
                                                                    self.view.bounds.size.width/3,
                                                                    self.view.bounds.size.height/3)
                                                   color:color];
    colorPatch.backgroundColor = [UIColor clearColor];
    [self.view addSubview:colorPatch];
    CGFloat x = self.view.frame.origin.x;
    CGFloat y = colorPatch.frame.origin.y + colorPatch.bounds.size.height + 60;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x,y,
                                                           self.view.bounds.size.width,
                                                           30)];
   
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:21];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.shadowOffset = CGSizeMake(1,1);
    label.shadowColor = [UIColor colorWithWhite:1 alpha:.5];
    [self.view addSubview:label];
     self.label = label;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(viewWillAppearInTabBarView:)
               name:TTTabBarViewSelectedViewWillChangeToViewNotification
             object:nil];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillLayoutSubviews
{
    CGFloat x = CGRectGetMidX(self.view.bounds);
    CGFloat y = CGRectGetMidY(self.view.bounds);
    gradientLayer.bounds = self.view.bounds;
    gradientLayer.position = CGPointMake(x,y);
    gradientLayer.contents = (__bridge id) self.grayGradientImage.CGImage;
    
    colorPatch.center = CGPointMake(x,y-45);
    self.label.frame = CGRectMake(self.view.frame.origin.x,colorPatch.frame.origin.y + colorPatch.bounds.size.height + 60,
                                                           self.view.bounds.size.width,
                                                           30);
    }



#pragma mark - accessors

-(UIImage *) grayGradientImage
{
    BOOL imageCreated = NO;
    switch (self.interfaceOrientation)
    {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            if (landscapeGradientImg) {
                imageCreated = YES;
                _grayGradientImage = landscapeGradientImg;
            }
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            if (portraitGradientImg) {
                imageCreated = YES;
                _grayGradientImage = portraitGradientImg;
            }
            break;
    }
    if( ! imageCreated)
    {
        CGFloat colors[6] = {138.0/255.0, 1.0,
            162.0/255.0, 1.0,
            206.0/255.0, 1.0};
        CGFloat locations[3] = {0.05,0.45,0.95};        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGGradientRef blackGradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 3);
        CGColorSpaceRelease(colorSpace);
        
        //create a black gradient for the views background
        UIGraphicsBeginImageContext(self.view.bounds.size);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGPoint startPoint = CGPointMake(CGRectGetMidX(self.view.bounds),
                                         CGRectGetMinY(self.view.bounds));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(self.view.bounds),
                                       CGRectGetMaxY(self.view.bounds));
        CGContextDrawLinearGradient(ctx, blackGradient, startPoint, endPoint, 0);
        _grayGradientImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        switch (self.interfaceOrientation)
        {
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
                landscapeGradientImg = _grayGradientImage;
                break;
            case UIInterfaceOrientationPortrait:
            case UIInterfaceOrientationPortraitUpsideDown:
                portraitGradientImg = _grayGradientImage;
                break;
        }
        UIGraphicsEndImageContext();
    }
    return _grayGradientImage;
}

#pragma mark - TTTabBarView Notification Methods

-(void) viewWillAppearInTabBarView:(NSNotification *)note
{
    if(self.view == note.userInfo[@"View"])
    {
        TTTabBarView *tabBarView = (TTTabBarView *)note.object;
        self.view.frame = tabBarView.selectedViewContainerView.bounds;
        [self.view setNeedsLayout];
    }
}


@end
