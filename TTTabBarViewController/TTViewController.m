//
//  TTViewController.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/1/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import "TTViewController.h"
#import "TTTabItem.h"
#import "TTTabBarView.h"
#import "TTCubeViewController.h"
#import "TTFoldTransitionsViewController.h"
#import "TTPinCreateViewController.h"
#import "TTSuckAnimationViewController.h"
#import "TTAppDelegate.h"
#import "TTColorPatchViewController.h"
#import "TTPinConfirmationAlertView.h"
#import "TTPinUtils.h"
#import "Constants.h"
#import "TTAppDelegate.h"

@interface TTViewController ()
{
    TTTabBarView *tabBarView;
    NSMutableArray * viewControllers;
    NSMutableArray *tabItems;
    UIColor *defaultTabColor;
}

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tabTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButtom;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *lockButton;
@property (strong, nonatomic) UIImage *greyGradientImage;
@property (strong, nonatomic) TTCubeViewController *cubeVC;
@property (strong, nonatomic) TTFoldTransitionsViewController *foldTransitionsVC;
@property (strong, nonatomic) TTPinCreateViewController *PINCreateVC;;
@property (strong, nonatomic) TTSuckAnimationViewController *suckVC;;
@property (strong, nonatomic) TTPinConfirmationAlertView *pinAlert; //special getter

-(void) setUpCubeViewController;
-(void) setUpFoldTransitionsViewController;
-(void) setUpPINCreateViewController;
-(void) setUpSuckAnimationViewController;
-(UIViewController *) makeTestImageTabVC;
-(void) addViewController:(UIViewController *)VC
              withTabText: (NSString *)tabText;
-(void) addViewController:(UIViewController *)VC
              withTabText: (NSString *)tabText
            tabImageNamed:(NSString* )imgName;
@end

@implementation TTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    TTAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSArray *colors = appDelegate.colors;
    NSUInteger cnt = kColorsMultiple *[colors count] + kNumberOfDemoViewControllers;
    defaultTabColor = [UIColor colorWithRed:80.0f/255.0f green:90.0f/255.0f blue:150.0f/255.0f alpha:1.0f];

    tabBarView = [[TTTabBarView alloc] initWithFrame:self.containerView.bounds
                                      tabBarPosition:TTTabBarPositionBottom
                                            delegate:self
                                          dataSource:self];
    
    tabBarView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth |
                                    UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self.containerView addSubview:tabBarView];
    self.toolBar.tintColor = [UIColor colorWithWhite:.4 alpha:1];
    
	//now we will do somthing bogus but it is just to create viewControllers and tabs for the tab view controller
    //obviously this would not ever happen is a real world app
    //
    viewControllers =[[NSMutableArray alloc] initWithCapacity:cnt];
    tabItems =[[NSMutableArray alloc] initWithCapacity:cnt];
    
   
    //create demo view controllers and their tabs
    [self setUpCubeViewController];
    [self setUpFoldTransitionsViewController];
    [self setUpPINCreateViewController];
    [self setUpSuckAnimationViewController];
    for (NSString *tabTitle in @[@"MyRewards", @"Home",@"ShopSearch",@"SearchIcon",@"Chair"])
    {
        [self addViewController:[self makeTestImageTabVC]
                    withTabText: tabTitle
                  tabImageNamed:[NSString stringWithFormat:@"%@.png",tabTitle]];
        
    }

    for (int j = 0; j<kColorsMultiple; j++)
    {
        for (int i = 0; i<[colors count]; i++)
        {
            NSInteger viewNumber = i+(j*[colors count]);
            TTColorPatchViewController *vc = [[TTColorPatchViewController alloc] initWithColor:colors[i]];
            UIView *v = [[UIView alloc] initWithFrame:tabBarView.selectedViewContainerView.bounds];
            vc.view = v;
            [vc setUp];
            vc.label.text = [NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"View #",@"View #"),viewNumber];

            [viewControllers addObject:vc];
            
            
            NSString *title = [NSString stringWithFormat:@"View %d",viewNumber];
            TTTabViewOrientation orientation = tabBarView.tabBarPosition == TTTabBarPositionBottom ? TTTabViewOrientationDown : TTTabViewOrientationUp;
            TTTabItem *tab = [[TTTabItem alloc] initWithTitle:title tabColor:colors[i] textColor:nil tabViewStyle:TTTabViewStyleLargeTab tabOrientation:orientation];
            [tabItems addObject:tab];
        }
    }
    [tabBarView reloadData];
}



-(UIImage *) greyGradientImage
{
    if( ! _greyGradientImage)
    {
        CGFloat colors[6] = {138.0/255.0, 1.0,
            162.0/255.0, 1.0,
            206.0/255.0, 1.0};
        CGFloat locations[3] = {0.05,0.45,0.95};
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGGradientRef greyGradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, 3);
        CGColorSpaceRelease(colorSpace);
        
        //create a grey gardient for the views background
        UIGraphicsBeginImageContext(tabBarView.selectedViewContainerView.bounds.size);
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGPoint startPoint = CGPointMake(CGRectGetMidX(tabBarView.selectedViewContainerView.bounds),
                                         CGRectGetMinY(tabBarView.selectedViewContainerView.bounds));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(tabBarView.selectedViewContainerView.bounds),
                                       CGRectGetMaxY(tabBarView.selectedViewContainerView.bounds));
        CGContextDrawLinearGradient(ctx, greyGradient, startPoint, endPoint, 0);
        _greyGradientImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    return _greyGradientImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 -(void) viewWillLayoutSubviews
 {
  
 }
 */


#pragma mark - TTViewController accessor method
-(TTPinConfirmationAlertView *) pinAlert
{
    if( ! _pinAlert)
    {
        TTPinUtils *pu = [TTPinUtils sharedPinUtils];
        _pinAlert = [[TTPinConfirmationAlertView alloc] initWithPIN:pu.PIN
                                                     dismissButtonTitle:NSLocalizedString(@"Logout",@"Logout" )
                                                        allowedAttempts:3
                                                                message:NSLocalizedString(@"Trace your PIN pattern over the matrix to unlock the screen",@"Trace your PIN pattern over the matrix to unlock the screen")
                                                               gridRows:kPatternGridSize
                                                            gridColumns:kPatternGridSize
                                                           delegate:self];
    }
    return _pinAlert;
}

#pragma mark - TTViewController action methods

-(IBAction) addViewToBarButton:(id)sender
{
    // add view to button - suck animation
}

-(IBAction) lockScreen:(id)sender
{
    // lock screen
    TTPinUtils *pu = [TTPinUtils sharedPinUtils];
    if(pu.PIN)
    {
        self.pinAlert.pin = pu.PIN;
        [self.pinAlert show];
    }else if(tabBarView.selectedView != self.PINCreateVC.view)
    {
        [self presentViewController:self.PINCreateVC animated:YES completion:^{
        }];
    }
    else
    {}
}

#pragma mark - more TTViewController methods

-(void) addViewController:(UIViewController *)VC
              withTabText: (NSString *)tabText
{
    
    [viewControllers addObject:VC];
    TTTabViewOrientation orientation = tabBarView.tabBarPosition == TTTabBarPositionBottom ? TTTabViewOrientationDown : TTTabViewOrientationUp;
    
    TTTabItem *VCTab = [[TTTabItem alloc] initWithTitle:tabText
                                               tabColor:defaultTabColor
                                              textColor:nil
                                           tabViewStyle:TTTabViewStyleLargeTab
                                         tabOrientation:orientation];
    [tabItems addObject:VCTab];
}


-(void) addViewController:(UIViewController *)VC
              withTabText: (NSString *)tabText
            tabImageNamed:(NSString* )imgName
{
    
    [viewControllers addObject:VC];
    TTTabViewOrientation orientation = tabBarView.tabBarPosition == TTTabBarPositionBottom ? TTTabViewOrientationDown : TTTabViewOrientationUp;
    
    TTTabItem *VCTab = [[TTTabItem alloc]
                        initWithImage:[UIImage imageNamed:imgName]
                        title:tabText
                        tabOrientation:orientation];

    [tabItems addObject:VCTab];
}

-(void) setUpCubeViewController
{
    if(!_cubeVC){
        TTCubeViewController *vc = [[TTCubeViewController alloc] init];
        UIView *v = [[UIView alloc] initWithFrame:tabBarView.selectedViewContainerView.bounds];
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
                                UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        vc.view = v;
        [vc setUp];
        self.cubeVC = vc;
        [self addViewController:self.cubeVC
                    withTabText: NSLocalizedString(@"Animate Cube",@"Animate Cube")];
    }
}

-(void) setUpFoldTransitionsViewController
{
    if(!_foldTransitionsVC)
    {
        self.foldTransitionsVC = [[TTFoldTransitionsViewController alloc] init];
        NSString *title = NSLocalizedString(@"Fold Transitions",@"Fold Transitions");
        
        UIView *v = [[UIView alloc] initWithFrame:tabBarView.selectedViewContainerView.bounds];
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
                                UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.foldTransitionsVC.view = v;
        [_foldTransitionsVC setUp];
        [self addViewController:self.foldTransitionsVC
                    withTabText:title];
    }
}

-(void) setUpPINCreateViewController
{
    self.PINCreateVC = [[TTPinCreateViewController alloc] init];
    NSString *title = NSLocalizedString(@"Update PIN",@"Update PIN");
    UIView *v = [[UIView alloc] initWithFrame:tabBarView.selectedViewContainerView.bounds];
    self.PINCreateVC.view = v;
    [_PINCreateVC setUp];
    [self addViewController:self.PINCreateVC
                withTabText:title];
}

-(void) setUpSuckAnimationViewController
{
    self.suckVC = [[TTSuckAnimationViewController alloc] init];
    NSString *title = NSLocalizedString(@"Suck Animation",@"Suck Animation");
    _suckVC.view.frame = tabBarView.selectedViewContainerView.bounds;
   // UIView *v = [[UIView alloc] initWithFrame:tabBarView.selectedViewContainerView.bounds];
    //self.suckVC.view = v;
    //[_suckVC setUp];
    [self addViewController:self.suckVC
                withTabText:title];
}

-(UIViewController *) makeTestImageTabVC
{
    UIViewController *vc = [[UIViewController alloc] init];
    UIView *v = [[UIView alloc] initWithFrame:tabBarView.selectedViewContainerView.bounds];
    v.backgroundColor = [UIColor lightGrayColor];
    UILabel *label = [[UILabel alloc]
                      initWithFrame:CGRectInset(v.bounds, 0.25*v.bounds.size.width, 0.4*v.bounds.size.height)];
    label.numberOfLines = 6;
    label.text = @"Tab Image Test\nThe purpose of this view is show a custom tab.  The tab is any image the developer choses.  If the tab is selected then a highlight is added to the tab.";
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor lightGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:21];
    label.center = CGPointMake(CGRectGetMidX(v.bounds), CGRectGetMidX(v.bounds));
    [v addSubview:label];

    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HomeImprovement.png"]];
    imgView.center = CGPointMake(label.center.x, (label.center.y + label.bounds.size.height/2 + imgView.bounds.size.height/2) );
    [v addSubview:imgView];
    
    vc.view = v;
    return vc;
}


#pragma mark - TTTabBarView data source methods


-(NSUInteger) numberOfTabsForTabBarView:(TTTabBarView *)tabBarView
{
    return [tabItems count];
}

-(UIView *) tabBarView:(TTTabBarView *)tabBarView viewForIndex:(NSUInteger)index
{
    return [viewControllers[index] view];
}

-(TTTabItem *) tabBarView:(TTTabBarView *)tabBarView tabItemForIndex:(NSUInteger)index
{
    return tabItems[index];
}

#pragma mark - TTPinConfirmationAlertView delegate method

-(void)pinConfirmationAlertWillDismissView:(TTPinConfirmationAlertView *)pinAlert;
{
    switch (_pinAlert.dismissalReason) {
        case TTPinConfirmationAlertDismissalReasonPinMatch:
            
            break;
            
        case TTPinConfirmationAlertDismissalReasonAllowedAttempsExceeded:
        case TTPinConfirmationAlertDismissalReasonUserDismissal:{
            //we should log out
            TTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate logout:self];
            break;
        }
            default:
            break;
    }
}



@end
