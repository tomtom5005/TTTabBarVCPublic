//
//  TTLoginViewController.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/11/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "TTLoginViewController.h"
#import "UIView+MinimizeToContainOnlyVisibleSubviews.h"
#import "UIView+AddTranslucentColoredOverlay.h"
#import "UIButton+TTButton.h"
#import "TTMainOperationQueue.h"
#import "TTAppDelegate.h"
#import "TTViewController.h"
#import "Constants.h"

@interface TTLoginViewController ()
{
    NSInteger numberOfLoginAttempts;
    CALayer *overlayLayer, *rectLayer, *glowLayer;
    
}
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginProgressWheel;

-(void) adjustContainerViewForOrientation;

@end

NSString *const TTLoginSucessful = @"Login Sucessful";
NSString *const TTLoginExpired = @"Login Expired";
NSString *const TTMaximumNumberOfLoginAttemptsExceeded = @"Maximum Number Of Login Attempts Exceeded";
NSString *const TTMissingData = @"Missing Data";
NSString *const TTInvalidData = @"Invalid Data";

@implementation TTLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.containerView minimizeToContainOnlyVisibleSubviews];
    _containerView.clipsToBounds = NO;
       
    rectLayer = [CALayer layer];
    rectLayer.frame = CGRectUnion(self.userIdTextField.frame, self.passwordTextField.frame);
    rectLayer.frame = CGRectInset(rectLayer.frame, -10, -10);
    rectLayer.backgroundColor = [UIColor colorWithWhite:0.90 alpha:1].CGColor;
    rectLayer.cornerRadius = 8.0;
    rectLayer.borderWidth = 2.0;
    rectLayer.borderColor = self.view.backgroundColor.CGColor;
    [self.containerView.layer addSublayer:rectLayer];
    
    overlayLayer = [CALayer layer];
    overlayLayer.frame = rectLayer.frame;
    overlayLayer.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:0 blue:0 alpha:0.3].CGColor;
    overlayLayer.cornerRadius = rectLayer.cornerRadius;
    overlayLayer.hidden=YES;
    [self.containerView.layer addSublayer:overlayLayer];
    
    
    CALayer *lineLayer = [CALayer layer];
    CGFloat x = CGRectGetMidX(rectLayer.bounds);
    CGFloat y = CGRectGetMidY(rectLayer.bounds);
    CGFloat w = rectLayer.frame.size.width;
    CGFloat h = _passwordTextField.frame.origin.y - (_userIdTextField.frame.origin.y+_userIdTextField.frame.size.height);
    lineLayer.bounds = CGRectMake(0,0,w,h);
    lineLayer.position = CGPointMake(x,y);
    lineLayer.backgroundColor = self.view.backgroundColor.CGColor;
    [rectLayer addSublayer:lineLayer];
    
    //create glow image
    glowLayer = [CALayer layer];
    glowLayer.backgroundColor = [UIColor clearColor].CGColor;
    CGFloat glowRadius = 2.0*self.containerView.bounds.size.width < self.view.bounds.size.width ? self.containerView.bounds.size.width : self.view.bounds.size.width/2.0;
    glowLayer.bounds = CGRectMake(0.0, 0.0,
                                  2.0 * glowRadius,
                                  2.0 * glowRadius);
    glowLayer.masksToBounds = NO;
    glowLayer.position = _containerView.center;
    
    UIGraphicsBeginImageContext(glowLayer.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    NSInteger numLocs = 2;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[2] = {0.0,1.0};
    CGFloat components[] = {1.0, 1.0, 1.0, 0.25,
        1.0, 1.0, 1.0, 0.0};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space,components,locations,numLocs);
    CGColorSpaceRelease(space);
    CGPoint center = CGPointMake(CGRectGetMidX(glowLayer.bounds),
                                 CGRectGetMidY(glowLayer.bounds));
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
    glowLayer.position = _containerView.center;

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
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(UITextFieldTextDidChange:)
               name:UITextFieldTextDidChangeNotification
             object:nil];

}

-(void) viewWillAppear:(BOOL)animated
{
    numberOfLoginAttempts = 0;
    self.instructionsLabel.text=@"";
    self.passwordTextField.text=@"";
    self.userIdTextField.text=@"";
    overlayLayer.hidden = YES;
    self.instructionsLabel.hidden = YES;
    [self.userIdTextField becomeFirstResponder];
}

-(void) viewWillDisappear:(BOOL)animated
{
    self.instructionsLabel.text=@"";
    self.passwordTextField.text=@"";
    self.userIdTextField.text=@"";
    overlayLayer.hidden = YES;
    self.instructionsLabel.hidden = YES;
}

-(void) viewWillLayoutSubviews
{
    [self.containerView minimizeToContainOnlyVisibleSubviews];
    [self adjustContainerViewForOrientation];
    [self.userIdTextField becomeFirstResponder];
    rectLayer.frame = CGRectUnion(self.userIdTextField.frame, self.passwordTextField.frame);
    rectLayer.frame = CGRectInset(rectLayer.frame, -10, -10);
    overlayLayer.frame = rectLayer.frame;
    glowLayer.position = _containerView.center;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TTLoginView Methods

-(void) adjustContainerViewForOrientation
{
    CGFloat usableHeight;
    usableHeight = self.view.bounds.size.height - kLandscapeKeyboardHeight;
    _containerView.center = CGPointMake(rint(CGRectGetMidX(self.view.bounds)),
                                        rint(usableHeight/2.0));
}


#pragma mark - TTLoginViewController Action Methods

- (IBAction)login:(id)sender
{
    [self.loginProgressWheel startAnimating];
    numberOfLoginAttempts ++;
    NSString *userID = [_userIdTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *password = [_passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *urlString = nil;;
    urlString = kLoginUrlString;
    NSURL *url = [NSURL URLWithString:urlString];
   //NSError *error = [NSError alloc] init];
    //NSURLResponse *response = [[NSURLResponse alloc] init];
   // NSData *data = [[NSData alloc]init];    
    NSMutableURLRequest *URLRequest = [[NSMutableURLRequest alloc]
                                       initWithURL:url
                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                       timeoutInterval:60.0];
    [URLRequest setHTTPMethod:@"POST"];
    NSString *POSTString = [[NSString stringWithFormat:@"userID=%@&password=%@&attempt=%d",
                             userID, password,numberOfLoginAttempts]
                            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *POSTData = [NSData dataWithBytes:[POSTString UTF8String] length:[POSTString length]];
    [URLRequest setHTTPBody:POSTData];
    [URLRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];

    NSOperationQueue *Q = [[TTMainOperationQueue sharedInstance] queue];
    [NSURLConnection sendAsynchronousRequest:URLRequest
                                       queue:Q
                           completionHandler: ^(NSURLResponse*response, NSData*data, NSError*err){
                               /*
                                NSString *dataString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
                                NSLog(@"returnData as string : %@",dataString);
                                */
                               NSError *jsonError = [[NSError alloc]init];
                               NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:NSJSONReadingMutableContainers
                                                                                             error:&jsonError];
                               NSString *message;
                               if ([data length])
                               {
                                   //NSLog(@"json object : %@",dict);
                                   if([dict[@"errorMessage"] isEqualToString:TTLoginSucessful])
                                   {
                                       message = @"Login Sucessful";
                                       dispatch_sync(dispatch_get_main_queue(),^{
                                           [self viewWillDisappear:NO];
                                           TTAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                                           appDelegate.viewController = [[TTViewController alloc] init];
                                       });
                                   }
                                   else if ([dict[@"errorMessage"] isEqualToString:TTLoginExpired])
                                   {
                                       message = @"Your Login Priviledges Have Expired.\nContact ShopSearch: tom@tsquaredapps.com for a renewal.";
                                   }
                                   else if ([dict[@"errorMessage"] isEqualToString:TTMaximumNumberOfLoginAttemptsExceeded])
                                   {
                                       message = @"You have exceeded the max number of login attempts.\nContact Shop Search: tom@tsquaredapps.com.";
                                   }
                                   else if([dict[@"errorMessage"] isEqualToString:TTInvalidData])
                                   {
                                       message = @"Sorry, Either your userID or password was entered incorrectly.";
                                   }
                                   else if([dict[@"errorMessage"] isEqualToString:TTMissingData])
                                   {
                                       message = @"Sorry, You must enter your user ID and password.";
                                   }
                                   else{}
                                   
                               }
                               else
                               {
                                   message = [NSString stringWithFormat:@"Login Failed.\nConnection Error :  %@\nresponse : %@",response.URL, err];
                                   
                                   NSLog(@"Login Failed in login action method in TTLoginViewController.\n  Connection Error = %@\nresponse : %@",response.URL, err);
                               }
                               dispatch_sync(dispatch_get_main_queue(),^{
                                   [self.loginProgressWheel stopAnimating];
                                   self.instructionsLabel.text = message;
                                   self.instructionsLabel.hidden=NO;
                                   overlayLayer.hidden=NO;
                               });
                           }];
}


#pragma mark UITextFieldTextDidChangemoNotification method

-(void) UITextFieldTextDidChange:(NSNotification *)note
{
    overlayLayer.hidden=YES;
}

#pragma mark - UITextField delegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
@end
