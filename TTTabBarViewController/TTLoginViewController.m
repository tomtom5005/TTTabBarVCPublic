//
//  TTLoginViewController.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/11/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "TTLoginViewController.h"
#import "UIView+MinimizeToContainOnlyVisibleSubviews.h"
#import "UIButton+TTButton.h"

@interface TTLoginViewController ()
{

}
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *invalidLoginLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;


@end

@implementation TTLoginViewController

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
    [self.containerView minimizeToContainOnlyVisibleSubviews];
    
    //create glow image
    CALayer *glowLayer = [CALayer layer];
    glowLayer.backgroundColor = [UIColor clearColor].CGColor;
    CGFloat glowRadius = 2.0*self.containerView.bounds.size.width < self.view.bounds.size.width ? 2.0*self.containerView.bounds.size.width/2.0 : self.view.bounds.size.width/2.0;
    glowLayer.frame = self.view.frame;
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    NSInteger numLocs = 2;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[2] = {0.0,1.0};
    CGFloat components[] = {1.0, 1.0, 1.0, 0.25,
                            1.0, 1.0, 1.0, 0.0};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space,components,locations,numLocs);
    CGColorSpaceRelease(space);    
    CGPoint center = _containerView.center;
    CGContextDrawRadialGradient(ctx,
                                gradient,
                                center,
                                1.0,
                                center,
                                glowRadius,
                                kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradient);
        
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    glowLayer.contents = (__bridge id)[img CGImage];
    [self.view.layer insertSublayer:glowLayer atIndex:0];
    
    CALayer *rectLayer = [CALayer layer];
    rectLayer.frame = CGRectUnion(self.userIdTextField.frame, self.passwordTextField.frame);
    rectLayer.frame = CGRectInset(rectLayer.frame, -10, -10);
    rectLayer.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1].CGColor;
    rectLayer.cornerRadius = 8.0;
    rectLayer.borderWidth = 2.0;
    rectLayer.borderColor = self.view.backgroundColor.CGColor;
    [self.containerView.layer addSublayer:rectLayer];
    
    CALayer *lineLayer = [CALayer layer];
    CGFloat x = rectLayer.frame.origin.x;
    CGFloat y = _userIdTextField.frame.origin.y+_userIdTextField.frame.size.height;
    CGFloat w = rectLayer.frame.size.width;
    CGFloat h = _passwordTextField.frame.origin.y - y;
    lineLayer.frame = CGRectMake(x,y,w,h);
    lineLayer.backgroundColor = self.view.backgroundColor.CGColor;
    [self.containerView.layer insertSublayer:lineLayer above:rectLayer];
    [self.containerView bringSubviewToFront:_userIdTextField];
    [self.containerView bringSubviewToFront:_passwordTextField];

    [self.loginButton TTStyleButton];
    [_loginButton setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0]
                       forState:UIControlStateNormal];
    [_loginButton setTitleShadowColor:[UIColor colorWithWhite:.90 alpha:0.7]
                                         forState:UIControlStateNormal];
    _loginButton.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    [_loginButton setTitleColor: [UIColor colorWithWhite:.25 alpha:1.0]
                         forState: UIControlStateHighlighted];
    [_loginButton setTitleShadowColor:[UIColor colorWithWhite:.75 alpha:0.7]
                             forState:UIControlStateHighlighted];
    CAGradientLayer *gLayer = [CAGradientLayer layer];
    gLayer.geometryFlipped = YES;
    gLayer.frame = _loginButton.layer.bounds;
    gLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:0.60 alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:0.70 alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:0.80 alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:0.90 alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:1.0 alpha:1.0f].CGColor,
                         nil];
    gLayer.locations = @[@0.0, @0.25, @0.5, @0.75, @1];
    [_loginButton.layer insertSublayer:gLayer atIndex:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
