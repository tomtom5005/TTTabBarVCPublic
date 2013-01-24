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
    BOOL viewSetupCompleted;
    BOOL sucking;
    CGPoint trashCanDestination;
}

@property (weak, nonatomic) IBOutlet UIView *suckedView;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIView *trashCanView;

-(void) dragTrashCan:(UIPanGestureRecognizer *)pan;
-(void) dragNote:(UIPanGestureRecognizer *)pan;
-(void) resizeNote:(UIPinchGestureRecognizer *)pinch;
-(void) suck:(UITapGestureRecognizer *)doubleTap;
-(void) newNote:(UITapGestureRecognizer *)doubleTap;
-(void) openTrashCanThenPerformCompletionBlock:(void(^)(void))completion;
-(void) closeTrashCanThenPerformCompletionBlock:(void(^)(void))completionHandler;

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


-(void) viewWillLayoutSubviews
{
    
}


- (void) viewDidLayoutSubviews
{
    _suckedView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_suckedView.bounds
                                                              cornerRadius:8].CGPath;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - TTSuckAnimationViewController gesture recognizer methods

-(void) dragTrashCan:(UIPanGestureRecognizer *)pan
{
    static CGPoint originalCenter;
    if( ! sucking)
    {
        if(pan.state == UIGestureRecognizerStateBegan){
            originalCenter = self.trashCanView.center;
        }
        if (pan.state == UIGestureRecognizerStateChanged)
        {
            CGPoint delta = [pan translationInView:self.view];
            self.trashCanView.center = CGPointMake(delta.x + originalCenter.x,
                                                   delta.y + originalCenter.y);
        }
        if(pan.state == UIGestureRecognizerStateEnded)
        {
            if( ! self.suckedView.hidden){
                if([self.suckedView pointInside:[[self.trashCanView superview] convertPoint:self.trashCanView.center toView:self.suckedView] withEvent:nil])
                    self.trashCanView.center = originalCenter;
            }
        }
    }
}


-(void) dragNote:(UIPanGestureRecognizer *)pan
{
    static CGPoint originalCenter;
    if( ! sucking)
    {
        if(pan.state == UIGestureRecognizerStateBegan){
            originalCenter = self.suckedView.center;
        }
        if (pan.state == UIGestureRecognizerStateChanged)
        {
            CGPoint delta = [pan translationInView:self.view];
            self.suckedView.center = CGPointMake(delta.x + originalCenter.x,
                                                 delta.y + originalCenter.y);
        }
        if(pan.state == UIGestureRecognizerStateEnded)
        {
            if([self.suckedView pointInside:[[self.trashCanView superview] convertPoint:self.trashCanView.center toView:self.suckedView] withEvent:nil])
                self.suckedView.center = originalCenter;
        }
    }
}


-(void) resizeNote:(UIPinchGestureRecognizer *)pinch
{
    static CGRect originalFrame;
    if( ! sucking)
    {
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
            //CGFloat fontSize = pinch.scale * self.noteLabel.font.pointSize;
            //self.noteLabel.font = [UIFont systemFontOfSize:fontSize];
        }
        else{};
    }
}



-(void) newNote:(UITapGestureRecognizer *)doubleTap
{
    if(self.suckedView.hidden && ! sucking)
    {
        self.suckedView.center = self.view.center;
        self.suckedView.hidden=NO;
        if([self.suckedView pointInside:[[self.trashCanView superview] convertPoint:self.trashCanView.center toView:self.suckedView] withEvent:nil]){
        _trashCanView.center = CGPointMake(self.view.bounds.size.width - 40 - self.trashCanView.bounds.size.width/2,
                                           self.view.bounds.size.height - 20 - self.trashCanView.bounds.size.height/2);
        }
    }
}



-(void) suck:(UITapGestureRecognizer *)doubleTap
{
    if( ! sucking)
    {
        self.suckedView.hidden=NO;
        sucking = YES;
        CGFloat x;
        if(_trashCanView.center.x > _suckedView.center.x){
            x = _trashCanView.center.x + 0.25*_trashCanView.bounds.size.width;
        }else{
            x = _trashCanView.center.x - 0.25*_trashCanView.bounds.size.width;
        }
        CGPoint trashPoint = CGPointMake(x,_trashCanView.frame.origin.y);
        [self.view bringSubviewToFront:self.trashCanView];
        [self openTrashCanThenPerformCompletionBlock:^{
            [self.suckedView suckAnimationToPoint:trashPoint
                                           inView:self.view
                                    fromDirection:TTSuckFromDirectionAbove
                                         hideView:YES
                                  completionBlock:^{
                                      [self closeTrashCanThenPerformCompletionBlock:^{
                                          sucking = NO;
                                      }];
                                  }];
        }];
    }
}

#pragma mark - TTSuckAnimationViewController Trash Can Animation

-(void) openTrashCanThenPerformCompletionBlock:(void(^)(void))completion
{
    [CATransaction setCompletionBlock:^{
        completion();
    }];
    
    CFTimeInterval now = [trashCanLidLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    
    trashCanDestination = CGPointMake(_trashCanView.layer.position.x - kTrashCanBaseDeltaX ,
                                              _trashCanView.layer.position.y - kTrashCanBaseDeltaY);
    
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
    pathAnimation.duration = 0.2;
    pathAnimation.beginTime = now;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [_trashCanView.layer addAnimation:pathAnimation forKey:@"position"];
    
    CAKeyframeAnimation* lidAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    [lidAnimation setValueFunction:[CAValueFunction functionWithName: kCAValueFunctionRotateZ]];
    [lidAnimation setDuration:.4];
    lidAnimation.fillMode = kCAFillModeBoth;
    lidAnimation.beginTime = now+pathAnimation.duration;
    lidAnimation.removedOnCompletion =NO;
    
    CAKeyframeAnimation *baseAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    baseAnimation.valueFunction = [CAValueFunction functionWithName:kCAValueFunctionRotateZ];
    baseAnimation.duration = .2;
    baseAnimation.beginTime = lidAnimation.beginTime;
    baseAnimation.fillMode = kCAFillModeBoth;
    baseAnimation.removedOnCompletion = NO;

    if(_trashCanView.center.x > _suckedView.center.x)
    {
        trashCanLidLayer.anchorPoint = CGPointMake(1,1);
        trashCanLidLayer.position = CGPointMake( (_trashCanView.bounds.size.width/2 + trashCanLidLayer.bounds.size.width/2),
                                                trashCanLidLayer.bounds.size.height);

        [lidAnimation setValues:@[@0.0,[NSNumber numberWithFloat:M_PI_2],[NSNumber numberWithFloat:3*M_PI_4]]];
        baseAnimation.values = @[@0.0,[NSNumber numberWithFloat:M_PI_4/4.0]];
    }
    else//_trashCanView.center.x < _suckedView.center.x i.e. trash can to the left of sucked view
    {
        trashCanLidLayer.anchorPoint = CGPointMake(0,1);
        trashCanLidLayer.position = CGPointMake( (_trashCanView.bounds.size.width/2 - trashCanLidLayer.bounds.size.width/2),
                                                trashCanLidLayer.bounds.size.height);
        [lidAnimation setValues:@[@0.0,[NSNumber numberWithFloat:(-M_PI_2) ],[NSNumber numberWithFloat:(-3*M_PI_4) ]]];
        baseAnimation.values = @[@0.0,[NSNumber numberWithFloat:(-M_PI_4/4.0) ]];
    }
    [trashCanLidLayer addAnimation:lidAnimation forKey:@"transform"];
    [trashCanBaseLayer addAnimation:baseAnimation forKey:@"transform"];

}


-(void) closeTrashCanThenPerformCompletionBlock:(void(^)(void))completionHandler
{
    [CATransaction setCompletionBlock:^{
        completionHandler();
    }];

    CFTimeInterval now = [trashCanLidLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    
    CAKeyframeAnimation *baseAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    baseAnimation.valueFunction = [CAValueFunction functionWithName:kCAValueFunctionRotateZ];
    baseAnimation.duration = .2;
    baseAnimation.beginTime = now;
    baseAnimation.removedOnCompletion = NO;
    
    CAKeyframeAnimation* lidAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    [lidAnimation setValueFunction:[CAValueFunction functionWithName: kCAValueFunctionRotateZ]];
    [lidAnimation setDuration:0.4];
    lidAnimation.beginTime = now;
    
    if(_trashCanView.center.x > _suckedView.center.x)
    {
        baseAnimation.values = @[[NSNumber numberWithFloat:M_PI_4/4.0],@0.0f];
        [lidAnimation setValues:@[[NSNumber numberWithFloat:3*M_PI_4],[NSNumber numberWithFloat:M_PI_2],@0.0]];
    }
    else
    {
        baseAnimation.values = @[[NSNumber numberWithFloat:-M_PI_4/4.0],@0.0f];
        [lidAnimation setValues:@[[NSNumber numberWithFloat:-3*M_PI_4],[NSNumber numberWithFloat:-M_PI_2],@0.0]];
    }
    [trashCanBaseLayer addAnimation:baseAnimation forKey:@"transform"];
    [trashCanLidLayer addAnimation:lidAnimation forKey:@"transform"];

    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGPoint controlPoint2 = CGPointMake(_trashCanView.layer.position.x,
                                        _trashCanView.layer.position.y- 0.5*kTrashCanBaseDeltaY);
    CGPoint controlPoint1 = CGPointMake(trashCanDestination.x + 0.5*kTrashCanBaseDeltaX,
                                        trashCanDestination.y);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:trashCanDestination];
    [path addCurveToPoint:_trashCanView.layer.position
            controlPoint1:controlPoint1
            controlPoint2:controlPoint2];
    pathAnimation.path = path.CGPath;
    pathAnimation.duration = 0.2f;
    pathAnimation.beginTime = baseAnimation.beginTime + baseAnimation.duration;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [_trashCanView.layer addAnimation:pathAnimation forKey:@"position"];
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
            _suckedView.layer.backgroundColor = [UIColor colorWithRed:249.0/255
                                                                green:246.0/255.0
                                                                 blue:144.0/255.0
                                                                alpha:1].CGColor;
            _suckedView.layer.cornerRadius = 8;
            _suckedView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_suckedView.bounds
                                                                      cornerRadius:8].CGPath;
            _suckedView.layer.shadowColor = [UIColor blackColor].CGColor;
            _suckedView.layer.shadowOpacity =  0.4f;
            _suckedView.layer.shadowOffset = CGSizeMake(6.0f,6.0f);
            
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
            trashCanLidLayer.anchorPoint = CGPointMake(1,1);
            trashCanLidLayer.position = CGPointMake( (_trashCanView.bounds.size.width/2 + trashCanLidLayer.bounds.size.width/2),
                                                    trashCanLidLayer.bounds.size.height);
            [_trashCanView.layer addSublayer:trashCanLidLayer];
            trashCanBaseLayer.position = CGPointMake(_trashCanView.bounds.size.width/2,
                                                     _trashCanView.bounds.size.height - trashCanBaseLayer.bounds.size.height/2);
            [_trashCanView.layer addSublayer:trashCanBaseLayer];
            
            viewSetupCompleted = YES;
        }
        [self.view setNeedsLayout];
    }
}




@end
