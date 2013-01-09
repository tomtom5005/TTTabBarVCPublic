//
//  TTCubeViewController.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/16/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import "TTCubeViewController.h"
#import "TTTabBarView.h"

@interface TTCubeViewController ()
{
    BOOL boxClosed;
    BOOL cubeExists;
    CALayer *bottom, *top, *right, *left, *back, *front;
    CALayer *containerLayer;
}

-(void)closeOpenBox;
-(void)makeBox;
-(void)flattenBox;

@end

@implementation TTCubeViewController

-(id) init
{
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
    }
    return self;
}

-(void) dealloc
{
    NSNotificationCenter *ns = [NSNotificationCenter defaultCenter];
    [ns removeObserver:self];
}

-(void) viewWillLayoutSubviews
{
    containerLayer.frame = self.view.bounds;
    CGFloat centerX = CGRectGetMidX(containerLayer.bounds);
    CGFloat centerY = CGRectGetMidY(containerLayer.bounds);
    back.position = CGPointMake(centerX, centerY);
    front.position = CGPointMake(centerX, centerY + kBoxSideWidth/2);
    left.position = CGPointMake(centerX-kBoxSideWidth/2, centerY);
    right.position = CGPointMake(centerX + kBoxSideWidth/2, centerY);
    bottom.position = CGPointMake(centerX, centerY + kBoxSideWidth/2);
    top.position = CGPointMake(centerX, centerY - kBoxSideWidth/2);
}

- (void)setUp
{
    //self.view.autoresizesSubviews = YES;
    
    self.containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
                                            UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:_containerView];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
	[self.containerView addGestureRecognizer:pan];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tap.numberOfTapsRequired = 1;
	[self.containerView addGestureRecognizer:tap];
	
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
	[self.containerView addGestureRecognizer:doubleTap];

    containerLayer = [CALayer layer];
    containerLayer.frame = [self.containerView bounds];
    containerLayer.backgroundColor = [UIColor blackColor].CGColor;
    CATransform3D initialTransform = containerLayer.sublayerTransform;
	initialTransform.m34 = -1.0 /kPerspectiveZ;
	containerLayer.sublayerTransform = initialTransform;
    
    UIColor *borderColor = [UIColor whiteColor];
    CGRect sideBounds = CGRectMake(0,0,
                                   kBoxSideWidth,
                                   kBoxSideWidth);
    back =[CALayer layer];
    back.bounds = sideBounds;
    back.backgroundColor = [UIColor redColor].CGColor;
    back.borderColor = borderColor.CGColor;
    back.borderWidth = 4.0;
    [containerLayer addSublayer:back];
    
    front =[CALayer layer];
    front.bounds = sideBounds;
    front.backgroundColor = [UIColor orangeColor].CGColor;
    front.borderColor = borderColor.CGColor;
    front.borderWidth = 4.0;
    front.anchorPoint = CGPointMake(0.5, 1.0);
    front.zPosition = 1;
    [containerLayer addSublayer:front];
    
    
    left =[CALayer layer];
    left.bounds = sideBounds;
    left.backgroundColor = [UIColor blueColor].CGColor;
    left.borderColor = borderColor.CGColor;
    left.borderWidth = 4.0;
    left.anchorPoint = CGPointMake(1.0, 0.5);
    [containerLayer addSublayer:left];
    
    right =[CALayer layer];
    right.bounds = sideBounds;
    right.backgroundColor = [UIColor greenColor].CGColor;
    right.borderColor = borderColor.CGColor;
    right.borderWidth = 4.0;
    right.anchorPoint = CGPointMake(0.0, 0.5);
    [containerLayer addSublayer:right];
    
    bottom =[CALayer layer];
    bottom.bounds = sideBounds;
    bottom.backgroundColor = [UIColor brownColor].CGColor;
    bottom.borderColor = borderColor.CGColor;
    bottom.borderWidth = 4.0;
    bottom.anchorPoint = CGPointMake(0.5, 0.0);
    [containerLayer addSublayer:bottom];
    
    top =[CALayer layer];
    top.bounds = sideBounds;
    top.backgroundColor = [UIColor purpleColor].CGColor;
    top.borderColor = borderColor.CGColor;
    top.borderWidth = 4.0;
    top.anchorPoint = CGPointMake(0.5, 1.0);
    [containerLayer addSublayer:top];
     
    [self.containerView.layer addSublayer:containerLayer];

    CATransform3D rotationalTransform = CATransform3DRotate(initialTransform,M_PI/4, -1.0, 1.0, 0.0);
    containerLayer.sublayerTransform = rotationalTransform;
    [self performSelector:@selector(makeBox) withObject:nil afterDelay:0.5];
    cubeExists=YES;
    boxClosed = YES;
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(viewWillAppearInTabBarView:)
               name:TTTabBarViewSelectedViewWillChangeToViewNotification
             object:nil];

}

-(void) doubleTap:(UITapGestureRecognizer *)gesture
{
    cubeExists = ! cubeExists;
    if(cubeExists)
        [self makeBox];
    else
        [self flattenBox];
}


-(void) tap:(UITapGestureRecognizer *)gesture
{
    if (cubeExists)
        [self closeOpenBox];
}


- (void)pan:(UIPanGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateChanged)
	{
		CGPoint displacement = [gesture translationInView:self.view.superview];
		CATransform3D currentTransform = containerLayer.sublayerTransform;
		
		if (displacement.x!=0 || displacement.y!=0)
        {
            CGFloat totalRotation = sqrt(displacement.x * displacement.x + displacement.y * displacement.y) * M_PI / 180.0;
            CGFloat xRotationFactor = displacement.x/totalRotation;
            CGFloat yRotationFactor = displacement.y/totalRotation;
            /*
            if (cubeExists)
                currentTransform = CATransform3DTranslate(currentTransform, 0, 0, kBoxSideWidth);
            */
            CATransform3D rotationalTransform =
            CATransform3DRotate(currentTransform, totalRotation,
                                (xRotationFactor * currentTransform.m12 - yRotationFactor*currentTransform.m11),
                                (xRotationFactor * currentTransform.m22 - yRotationFactor * currentTransform.m21),
                                (xRotationFactor * currentTransform.m32 - yRotationFactor * currentTransform.m31));
           /*
            if (cubeExists)
                rotationalTransform = CATransform3DTranslate(rotationalTransform, 0, 0, -kBoxSideWidth/2)
            */
            //[CATransaction setAnimationDuration:0]; //shut down implicit animations
            
            containerLayer.sublayerTransform = rotationalTransform;
            [gesture setTranslation:CGPointZero inView:self.containerView];
        }
	}
}

-(void) makeBox
{
    [CATransaction setAnimationDuration:2.0];    
    front.zPosition = 200;
    right.transform = CATransform3DMakeRotation(-M_PI/2, 0.0f, 1.0f, 0.0f);
    left.transform = CATransform3DMakeRotation(M_PI/2, 0.0f, 1.0f, 0.0f);
    bottom.transform = CATransform3DMakeRotation(M_PI/2, 1.0f, 0.0f, 0.0f);
    top.transform = CATransform3DMakeRotation(-M_PI/2, 1.0f, 0.0f, 0.0f);
}

-(void) flattenBox
{
    [CATransaction setAnimationDuration:2.0]; 
    right.transform = CATransform3DMakeRotation(0, 0.0f, 1.0f, 0.0f);
    left.transform = CATransform3DMakeRotation(-0, 0.0f, 1.0f, 0.0f);
    bottom.transform = CATransform3DMakeRotation(-0, 1.0f, 0.0f, 0.0f);
    top.transform = CATransform3DMakeRotation(0, 1.0f, 0.0f, 0.0f);
    front.zPosition = 1.0;
    front.transform = CATransform3DMakeRotation(0, 1.0f, 0.0f, 0.0f);
    /*
    if(! boxClosed)
        [self closeOpenBox];*/
}

-(void) closeOpenBox
{
    boxClosed = ! boxClosed;
    if (boxClosed)
        front.transform = CATransform3DMakeRotation(0, 1.0f, 0.0f, 0.0f);
    else
        front.transform = CATransform3DMakeRotation(-M_PI/3, 1.0f, 0.0f, 0.0f);
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
        [self.view setNeedsLayout];
    }
}

@end
