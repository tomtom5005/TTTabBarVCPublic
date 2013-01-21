//
//  TTSuckAnimationViewController.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/19/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "TTSuckAnimationViewController.h"
#import "UIView+CreateLayerImage.h"
#import "TTTabBarView.h"
#import "UIView+SuckAninmationToPoint.h"

@interface TTSuckAnimationViewController ()
{
    CAGradientLayer *gradientLayer;
    CALayer *trashCanLidLayer;
    CALayer *trashCanBaseLayer;
    CALayer *noteLayer;
    CGPoint trashPoint;
    BOOL viewSetupCompleted;
}

@property (weak, nonatomic) IBOutlet UIView *suckedView;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIView *trashCanView;

-(void) dragTrashCan:(UIPanGestureRecognizer *)pan;
-(void) dragNote:(UIPanGestureRecognizer *)pan;
-(void) resizeNote:(UIPinchGestureRecognizer *)pinch;
-(void) suck:(UITapGestureRecognizer *)doubleTap;
-(void) newNote:(UITapGestureRecognizer *)doubleTap;
-(void) openTrashCanCompletionBlock:(void(^)(void))completion;
-(void) closeTrashCan;
@end

@implementation TTSuckAnimationViewController

- (id)init
{
    return [self initWithNibName:@"TTSuckAnimationViewController" bundle:nil];
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
    //add gestures

    UIPanGestureRecognizer *panCan = [[UIPanGestureRecognizer alloc]
                                      initWithTarget:self
                                      action:@selector(dragTrashCan:)];
	[self.trashCanView addGestureRecognizer:panCan];
	
    UIPanGestureRecognizer *panNote = [[UIPanGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(dragNote:)];
	[self.suckedView addGestureRecognizer:panNote];
	
	UIPinchGestureRecognizer *pinchNote = [[UIPinchGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(resizeNote:)];
	[self.suckedView addGestureRecognizer:pinchNote];
	
	UITapGestureRecognizer *doubleTapCan = [[UITapGestureRecognizer alloc]
                                            initWithTarget:self
                                            action:@selector(suck:)];
    doubleTapCan.numberOfTapsRequired = 2;
    [self.suckedView addGestureRecognizer:doubleTapCan];
    
    UITapGestureRecognizer *doubleTapView = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(newNote:)];
    doubleTapView.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapView];

    viewSetupCompleted = NO;
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(viewWillAppearInTabBarView:)
               name:TTTabBarViewSelectedViewWillChangeToViewNotification
             object:nil];
     
}

-(void) viewWillAppear:(BOOL)animated
{

}

-(void) viewWillLayoutSubviews
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TTSuckAnimationViewController

-(void) dragTrashCan:(UIPanGestureRecognizer *)pan
{
    static CGPoint originalCenter;
    if(pan.state == UIGestureRecognizerStateBegan){
        originalCenter = self.trashCanView.center;
    }
    if (pan.state == UIGestureRecognizerStateChanged)
	{
		CGPoint delta = [pan translationInView:self.view];
		self.trashCanView.center = CGPointMake(delta.x + originalCenter.x,
                                             delta.y + originalCenter.y);
    }
}


-(void) dragNote:(UIPanGestureRecognizer *)pan
{
    static CGPoint originalCenter;
    if(pan.state == UIGestureRecognizerStateBegan){
        originalCenter = self.suckedView.center;
    }
    if (pan.state == UIGestureRecognizerStateChanged)
	{
		CGPoint delta = [pan translationInView:self.view];
		self.suckedView.center = CGPointMake(delta.x + originalCenter.x,
                                             delta.y + originalCenter.y);
    }
}


-(void) resizeNote:(UIPinchGestureRecognizer *)pinch
{
    static CGRect originalFrame;
    
    if (pinch.state == UIGestureRecognizerStateBegan){
        originalFrame = self.suckedView.frame;
	}
    else if (pinch.state == UIGestureRecognizerStateChanged)
	{
        CGFloat w = originalFrame.size.width*pinch.scale;
        CGFloat h = originalFrame.size.height*pinch.scale;
        CGFloat x = (self.view.bounds.size.width - w)/2;
        CGFloat y = (self.view.bounds.size.height - w)/2;
        self.suckedView.frame=CGRectMake(x, y, w, h);
	}
    else if (pinch.state == UIGestureRecognizerStateEnded)
    {
        CGFloat fontSize = pinch.scale * self.noteLabel.font.pointSize;
        //self.noteLabel.font = [UIFont systemFontOfSize:fontSize];
    }
    else{};
}


-(void) suck:(UITapGestureRecognizer *)doubleTap
{
    self.suckedView.hidden=NO;
    [self.view bringSubviewToFront:self.trashCanView];
    [self openTrashCanCompletionBlock:^{
        [self.suckedView suckAnimationToPoint:trashPoint
                                       inView:self.view
                                     hideView:YES
                              completionBlock:^{
                                  [self closeTrashCan];
                              }];
    }];
}


-(void) newNote:(UITapGestureRecognizer *)doubleTap
{
    if(self.suckedView.hidden)
    {
        self.suckedView.center = self.view.center;
        self.suckedView.hidden=NO;
    }
}

-(void) openTrashCanCompletionBlock:(void(^)(void))completion
{
    [CATransaction setCompletionBlock:^{
        completion();
    }];
    
    trashCanLidLayer.transform = CATransform3DMakeRotation(-M_PI, 0.0f, 0.0f, 1.0f);
    trashCanBaseLayer.transform = CATransform3DMakeRotation(M_PI_4/4.0, 0.0f, 0.0f, 1.0f);
    CGPoint trashCanDestination = CGPointMake(_trashCanView.layer.position.x - kTrashCanBaseDeltaX ,
                                              _trashCanView.layer.position.y - kTrashCanBaseDeltaY);
    _trashCanView.layer.position = trashCanDestination;
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGPoint controlPoint1 = CGPointMake(_trashCanView.layer.position.x,
                                        _trashCanView.layer.position.y - 0.5*kTrashCanBaseDeltaY);
    CGPoint controlPoint2 = CGPointMake(trashCanDestination.x + 0.5*kTrashCanBaseDeltaX,
                                        trashCanDestination.y);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:_trashCanView.layer.position];
    [path addCurveToPoint:trashCanDestination
            controlPoint1:controlPoint1
            controlPoint2:controlPoint2];
    pathAnimation.path = path.CGPath;
    pathAnimation.duration = .4;
    pathAnimation.beginTime = 0.0;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CAKeyframeAnimation *lidTransformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    lidTransformAnimation.valueFunction = [CAValueFunction functionWithName:kCAValueFunctionRotateX];
    lidTransformAnimation.values = @[@0,[NSNumber numberWithFloat:-M_PI]];
    lidTransformAnimation.duration = 0.4;
    lidTransformAnimation.beginTime = 0.6;
    
    CAKeyframeAnimation *trashCanAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    trashCanAnimation.valueFunction = [CAValueFunction functionWithName:kCAValueFunctionRotateX];
    trashCanAnimation.values = @[@0,[NSNumber numberWithFloat:M_PI_4/4.0]];
    trashCanAnimation.duration = 0.4;
    trashCanAnimation.beginTime = 0.2;
    
    [CATransaction begin];
    [_trashCanView.layer addAnimation:pathAnimation forKey:@"position"];
    [trashCanLidLayer addAnimation:lidTransformAnimation forKey:@"transform"];
    [_trashCanView.layer addAnimation:trashCanAnimation forKey:@"transform"];
    [CATransaction commit];
}


-(void) closeTrashCan
{
    trashCanLidLayer.transform = CATransform3DMakeRotation(15*M_PI/16, 0.0f, 0.0f, 1.0f);
    trashCanBaseLayer.transform = CATransform3DMakeRotation(-M_PI_4/4, 0.0f, 0.0f, 1.0f);
    CGPoint trashCanDestination = CGPointMake(_trashCanView.layer.position.x + kTrashCanBaseDeltaX ,
                                              _trashCanView.layer.position.y + kTrashCanBaseDeltaY);
    _trashCanView.layer.position = trashCanDestination;

    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGPoint controlPoint1 = CGPointMake(trashCanBaseLayer.position.x + 0.5*kTrashCanBaseDeltaX,
                                        trashCanBaseLayer.position.y);
    CGPoint controlPoint2 = CGPointMake(trashCanDestination.x,
                                        trashCanDestination.y - 0.5*kTrashCanBaseDeltaY);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:_trashCanView.layer.position];
    [path addCurveToPoint:trashCanDestination
            controlPoint1:controlPoint1
            controlPoint2:controlPoint2];
    pathAnimation.path = path.CGPath;
    pathAnimation.duration = .4;
    pathAnimation.beginTime = 0.8;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CAKeyframeAnimation *lidTransformAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    lidTransformAnimation.valueFunction = [CAValueFunction functionWithName:kCAValueFunctionRotateX];
    lidTransformAnimation.values = @[@0,[NSNumber numberWithFloat:M_PI]];
    lidTransformAnimation.duration = 0.4;
    lidTransformAnimation.beginTime = 0.0;
    
    CAKeyframeAnimation *trashCanAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    trashCanAnimation.valueFunction = [CAValueFunction functionWithName:kCAValueFunctionRotateX];
    trashCanAnimation.values = @[@0,[NSNumber numberWithFloat:-M_PI_4/4.0]];
    trashCanAnimation.duration = 0.4;
    trashCanAnimation.beginTime = 0.4;
    
    [CATransaction begin];
    [_trashCanView.layer addAnimation:pathAnimation forKey:@"position"];
    [trashCanLidLayer addAnimation:lidTransformAnimation forKey:@"transform"];
    [_trashCanView.layer addAnimation:trashCanAnimation forKey:@"transform"];
    [CATransaction commit];

}

#pragma mark - TTTabBarView Notification Methods

-(void) viewWillAppearInTabBarView:(NSNotification *)note
{
    if(self.view == note.userInfo[@"View"])
    {
        TTTabBarView *tabBarView = (TTTabBarView *)note.object;
                
        //due to the sequence of events that occur when one use the nib file to
        //init the view we have to do a bit of setup here.  The reason is :
        //  After initWithNib
        //  viewDidLoad is invoked but the nib will have the VC's view (self.view) as a full screen view
        //  (self.view.frame cannot be changed in Interface Builder)
        //  So since we want our view to reflect the size of the TTTabView.selectedViewContainerView
        //  and we cannot know that in viewDidLoad or anywhere else in this VC
        //  we do the view sizing and positioning here
        //
        if( ! viewSetupCompleted)
        {
            self.view.frame = tabBarView.selectedViewContainerView.bounds;
            self.view.layer.bounds = self.view.bounds;

            //position views
            
            _suckedView.center = self.view.center;
            gradientLayer = [CAGradientLayer layer];
            gradientLayer.frame = self.view.bounds;
            gradientLayer.colors = @[(id)[UIColor colorWithRed:150.0/255.0 green:210/255.0 blue:150.0/255.0 alpha:1.0].CGColor,
            (id)[UIColor colorWithRed:35.0/255.0 green:140  /255.0 blue:70.0/255.0 alpha:1.0].CGColor,
            (id)[UIColor colorWithRed:25.0/255.0 green:100/255.0 blue:50.0/255.0 alpha:1.0].CGColor,];
            gradientLayer.locations = @[@0.0, @0.3, @1.0];
            [self.view.layer insertSublayer:gradientLayer atIndex:0];
            
            trashCanBaseLayer = [CALayer layer];
            UIImage *canBaseImg = [UIImage imageNamed:@"TrashCanBottom.png"];
            trashCanBaseLayer.bounds = CGRectMake(0.0, 0.0,
                                                  canBaseImg.size.width,
                                                  canBaseImg.size.height);
            trashCanBaseLayer.contents = (__bridge id)(canBaseImg.CGImage);
            
            trashCanLidLayer = [CALayer layer];
            UIImage *canLidImg = [UIImage imageNamed:@"TrashCanLid.png"];
            trashCanLidLayer.bounds = CGRectMake(0.0, 0.0,
                                                 canLidImg.size.width,
                                                 canLidImg.size.height);
            trashCanLidLayer.contents = (__bridge id)(canLidImg.CGImage);
            
            CGFloat W = canLidImg.size.width > canBaseImg.size.width ? canLidImg.size.width : canBaseImg.size.width;
            CGFloat H = canLidImg.size.height + canBaseImg.size.height;
            _trashCanView.frame = CGRectMake (self.view.bounds.size.width - 40 - W,
                                              self.view.bounds.size.height - 20 - H,
                                              W,H);
            trashCanLidLayer.anchorPoint=CGPointMake(1,1);
            trashCanLidLayer.position = CGPointMake( (_trashCanView.bounds.size.width/2 + trashCanLidLayer.bounds.size.width/2),
                                                    trashCanLidLayer.bounds.size.height);
            [_trashCanView.layer addSublayer:trashCanLidLayer];
            
            //trashCanBaseLayer.anchorPoint=CGPointMake(0,1);
            trashCanBaseLayer.position = CGPointMake(_trashCanView.bounds.size.width/2,
                                                     _trashCanView.bounds.size.height - trashCanBaseLayer.bounds.size.height/2);
            [_trashCanView.layer addSublayer:trashCanBaseLayer];
            
            trashPoint = CGPointMake(_trashCanView.center.x,
                                     _trashCanView.frame.origin.y + trashCanLidLayer.bounds.size.height +5);
            viewSetupCompleted = YES;
        }
        [self.view setNeedsLayout];
    }
}




@end
