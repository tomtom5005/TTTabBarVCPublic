//
//  TTFoldTransitionsViewController.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/18/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import "TTFoldTransitionsViewController.h"
#import "TTFoldTransitionsView.h"
#import "TTColorPatchView.h"
#import "TTAppDelegate.h"

@interface TTFoldTransitionsViewController ()
{
    NSMutableDictionary *foldTransitionsViews;
    TTAppDelegate *appDelegate;
}
@property (nonatomic, weak) UIImage *blueGradientImage; //special getter
@property (nonatomic, weak) IBOutlet TTFoldTransitionsView * foldTransitionsView;

-(TTColorPatchView *) colorPatchViewForColor:(UIColor *)color;
-(TTColorPatchView *) colorPatchViewForColorAtIndex:(NSUInteger)index;

@end

@implementation TTFoldTransitionsViewController

- (id)init
{
    return [self initWithNibName:@"TTFoldTransitionsViewController" bundle:nil];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUp];
}

-(void) setUp
{
    appDelegate = [[UIApplication sharedApplication] delegate];
    CALayer *gradientLayer = [CALayer layer];
    gradientLayer.frame = self.view.frame;
    gradientLayer.contents = (__bridge id) self.blueGradientImage.CGImage;
    gradientLayer.backgroundColor = [UIColor blackColor].CGColor;
    [self.view.layer addSublayer:gradientLayer];
    CGRect frame = CGRectMake ((self.view.bounds.size.width-kFoldTransitionsViewWidth)/2,
                               (self.view.bounds.size.height-kFoldTransitionsViewHeight)/2,
                               kFoldTransitionsViewWidth,
                               kFoldTransitionsViewHeight);
    
    TTFoldTransitionsView *tView = [[TTFoldTransitionsView alloc] initWithFrame:frame dataSource:self];
    self.foldTransitionsView = tView;
    self.foldTransitionsView.delegate=self;
    self.foldTransitionsView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.foldTransitionsView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    foldTransitionsViews = nil;
}

#pragma mark - TTFoldTransitionsViewController Methods

#pragma mark - accessors


-(UIImage *) blueGradientImage
{
    if( ! _blueGradientImage)
    {
        CGFloat colors[13] = {20.0/255.0, 33.0/255.0, 104.0/255.0, 0.8,
            33.0/255.0, 47.0/255.0, 114.0/255.0, 1.0,
            48.0/255, 61.0/255, 114.0/255.0, 1.0,};
        CGFloat locations[3] = {0.0,0.5,1.0};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef blueGradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 2);
        CGColorSpaceRelease(colorSpace);
        
        //create a grey gardient for the views background
        UIGraphicsBeginImageContext(self.view.bounds.size);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGPoint startPoint = CGPointMake(CGRectGetMidX(self.view.bounds),
                                         CGRectGetMinY(self.view.bounds));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(self.view.bounds),
                                       CGRectGetMaxY(self.view.bounds));
        CGContextDrawLinearGradient(ctx, blueGradient, startPoint, endPoint, 0);
        _blueGradientImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
    }
    return _blueGradientImage;
}

#pragma mark - other TTFoldTransitionsViewController methods


-(TTColorPatchView *) colorPatchViewForColor:(UIColor *)color
{
    TTColorPatchView *colorPatch = [[TTColorPatchView alloc]
                                    initWithFrame:self.foldTransitionsView.bounds
                                                   color:color];
    colorPatch.backgroundColor = [UIColor clearColor];
    return colorPatch;
}

-(TTColorPatchView *) colorPatchViewForColorAtIndex:(NSUInteger)index
{
    NSNumber *colorNumber = [NSNumber numberWithUnsignedInteger:index];
    TTColorPatchView *colorPatch  = [foldTransitionsViews objectForKey:colorNumber];
    if ( ! colorPatch) {
        UIColor *color = appDelegate.colors[index];
        colorPatch = [self colorPatchViewForColor:color];
        if( ! foldTransitionsViews){
            foldTransitionsViews = [[NSMutableDictionary alloc]
                                    initWithCapacity:[appDelegate.colors count]];
        }
        foldTransitionsViews[colorNumber] = colorPatch;
    }
    return colorPatch;
}


#pragma mark - TTFoldTransitionsView Data Source methods

-(NSUInteger) numberOfViews
{
    return [appDelegate.colors count];
}

-(UIView *) foldTransitionsView:(TTFoldTransitionsView *)foldTransitionView
                   viewForIndex:(NSUInteger)index
{
    return [self colorPatchViewForColorAtIndex:index%[appDelegate.colors count]];
}

#pragma mark - TTFoldTransitionsView Delegate methods


@end
