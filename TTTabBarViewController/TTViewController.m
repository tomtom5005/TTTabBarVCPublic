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
#import "TTColorPatchView.h"
#import "TTCubeViewController.h"
#import "TTFoldTransitionsViewController.h"
#import "TTAppDelegate.h"


@interface TTViewController ()
{
    TTTabBarView *tabBarView;
    NSMutableArray * viewControllers;
    NSMutableArray *tabItems;
    TTColorPatchView *colorPatch;
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

-(void) setUpCubeViewController;
-(void) setUpFoldTransitionsViewController;
-(void) addViewController:(UIViewController *)VC
              withTabText: (NSString *)tabText;
@end

@implementation TTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    TTAppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSArray *colors = appDelegate.colors;
    NSUInteger cnt = kColorsMultiple *[colors count] + kNumberOfDemoViewControllers;
    defaultTabColor = [UIColor colorWithRed:40.0f/255.0f green:60.0f/255.0f blue:150.0f/255.0f alpha:1.0f];

   tabBarView = [[TTTabBarView alloc] initWithFrame:self.containerView.bounds
                                                          delegate:self
                                                        dataSource:self];
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
    
    for (int j = 0; j<kColorsMultiple; j++)
    {
        for (int i = 0; i<[colors count]; i++)
        {
            UIViewController *vc = [[UIViewController alloc] initWithNibName:nil bundle:nil];
            UIView *v = [[UIView alloc] initWithFrame:tabBarView.selectedViewContainerView.frame];
            UIImageView *imgView = [[UIImageView alloc] initWithImage:self.greyGradientImage];
            [v addSubview:imgView];
            
            //create a label and a view with rounded croners and a shadow
            //the most efficient way is to draw a path and a shadow
            colorPatch = [[TTColorPatchView alloc] initWithFrame:CGRectMake(v.bounds.size.width/3,
                                                                            v.bounds.size.height/4,
                                                                            v.bounds.size.width/3,
                                                                            v.bounds.size.height/3)
                                                           color:colors[i]];
            colorPatch.backgroundColor = [UIColor clearColor];
            [v addSubview:colorPatch];
            CGFloat x = tabBarView.selectedViewContainerView.frame.origin.x;
            CGFloat y = tabBarView.selectedViewContainerView.frame.origin.y + tabBarView.selectedViewContainerView.bounds.size.height - 50;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x,y,
                                                                       tabBarView.selectedViewContainerView.bounds.size.width,
                                                                       30)];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:21];
            label.textColor = [UIColor blackColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.shadowOffset = CGSizeMake(1,1);
            label.shadowColor = [UIColor colorWithWhite:1 alpha:.5];
            NSInteger viewNumber = i+(j*[colors count]);
            label.text = [NSString stringWithFormat:@"%@ %d",NSLocalizedString(@"View #",@"View #"),viewNumber];
            [v addSubview:label];
            vc.view = v;
            
            [viewControllers addObject:vc];
            NSString *title = [NSString stringWithFormat:@"View %d",viewNumber];
            TTTabItem *tab = [[TTTabItem alloc] initWithTitle:title tabColor:colors[i] textColor:nil tabViewStyle:TTTabViewStyleLargeTab];
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
 boxContainerLayer.frame = boxContainerLayer.frame = CGRectMake( (modalView.layer.bounds.size.width - 3*kBoxSideWidth)/2,
 (modalView.layer.bounds.size.height - 3*kBoxSideWidth)/2,
 3*kBoxSideWidth,
 3*kBoxSideWidth);
 
 }
 */


#pragma mark - TTViewController methods

-(IBAction) addViewToBarButton:(id)sender
{
    // add view to button
}

-(IBAction) lockScreen:(id)sender
{
    // lock screen
}

/*
-(UIBarButtonItem *)doneBarButtonItem
{
    static dispatch_once_t onceToken;
    __block UIBarButtonItem * doneButton;
    dispatch_once(&onceToken, ^{
        doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:nil action:nil];
    });
    return doneButton;
}
*/


-(void) addViewController:(UIViewController *)VC
              withTabText: (NSString *)tabText
{
    [viewControllers addObject:VC];
    TTTabItem *VCTab = [[TTTabItem alloc] initWithTitle:tabText
                                               tabColor:defaultTabColor
                                              textColor:nil
                                           tabViewStyle:TTTabViewStyleLargeTab];
    [tabItems addObject:VCTab];
}

-(void) setUpCubeViewController
{
    if(!_cubeVC){
        TTCubeViewController *vc = [[TTCubeViewController alloc] init];
        UIView *v = [[UIView alloc] initWithFrame:tabBarView.selectedViewContainerView.frame];
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
        
        UIView *v = [[UIView alloc] initWithFrame:tabBarView.selectedViewContainerView.frame];
        self.foldTransitionsVC.view = v;
        [_foldTransitionsVC setUp];
        [self addViewController:self.foldTransitionsVC
                    withTabText:title];
    }
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





@end
