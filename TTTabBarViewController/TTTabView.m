//
//  TTTabView.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/1/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import "TTTabView.h"
#import "TTTabItem.h"
#import "UIView+Highlight.h"

@interface TTTabView()
{
    CALayer *underlineLayer;
}
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation TTTabView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect labelRect = CGRectMake(kLabelInsetX,
                                      kLabelInsetY,
                                      frame.size.width-2*kLabelInsetX,
                                      frame.size.height- 2*kLabelInsetY);
        _label = [[UILabel alloc]
                  initWithFrame:labelRect];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.backgroundColor = [UIColor clearColor];
        _label.minimumScaleFactor = kMininumFontSize/kFontSize;
        _label.adjustsFontSizeToFitWidth = YES;
        _label.font = [UIFont boldSystemFontOfSize:kFontSize];
        [self addSubview:_label];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tapGesture];
        self.clipsToBounds=NO;
    }
    return self;
}


-(id) initWithTab:(TTTabItem *)tab
{
    CGRect frame = CGRectMake(0, 0,
                              tab.tabSize.width + kShadowOffset,
                              tab.tabSize.height + kShadowOffset);
    self = [self initWithFrame:frame];
    if(self)
    {
        [self configureWithTabItem:tab];
    }
    return self;
}

-(void) configureWithTabItem:(TTTabItem *)tabItem
{
    self.tabItem = tabItem;
    
    //adjust label position for short text labels
    if( (tabItem.tabSize.width==kMinTabWidth) || (tabItem.tabSize.height==kMinTabHeight) )
    {
        CGSize titleSize = [self.tabItem.tabTitle sizeWithFont:[UIFont systemFontOfSize:kTabFontSize]];
        CGFloat xInset = (self.bounds.size.width-titleSize.width)/2;
        CGFloat yInset = (self.bounds.size.height-titleSize.height)/2;
        self.label.frame = CGRectMake(xInset, yInset,tabItem.tabSize.width,tabItem.tabSize.height);
    }
    
    if(!tabItem.tabImage)
    {
        _label.text=tabItem.tabTitle;
        _label.textColor = tabItem.textColor;
        _label.text = tabItem.tabTitle;
        _label.hidden = NO;
        _imageView = nil;
    }
    else    //tabImage exists
    {
        _label.hidden=YES;
        _imageView = [[UIImageView alloc] initWithFrame:_label.frame];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = [UIColor clearColor];
        [_imageView setImage:tabItem.tabImage];
        [self addSubview:_imageView];
    }
}


-(void) drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    if(self.tabItem.tabViewStyle != TTTabViewStyleCustom)
    {        
        UIBezierPath *path;
        CGFloat height;
        CGFloat width;

        switch (self.tabItem.tabViewStyle)
        {
            case TTTabViewStyleSmallTab:
                height = self.bounds.size.height;
                width = self.bounds.size.width;
                path=[UIBezierPath bezierPathWithRoundedRect:self.bounds
                                           byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                 cornerRadii:CGSizeMake(8,8)];
                
                CGContextSetShadowWithColor(context, CGSizeMake(2,2), 2.0, [UIColor colorWithRed:105.0/255.0
                                                                                           green:105.0/255.0
                                                                                            blue:141.0/255.0
                                                                                           alpha:7].CGColor);
                break;
            case TTTabViewStyleLargeTab:
            {
                height = self.bounds.size.height - kShadowOffset;
                width = self.bounds.size.width - kShadowOffset;
                path = [UIBezierPath bezierPath];
                [path moveToPoint:self.bounds.origin];
                [path addCurveToPoint:CGPointMake(kLargeTabExtraWidth/4, height/2)
                        controlPoint1:CGPointMake(-kLargeTabExtraWidth/5, self.bounds.origin.y)
                        controlPoint2:CGPointMake(kLargeTabExtraWidth/4, self.bounds.origin.y)];
                [path addLineToPoint:CGPointMake(kLargeTabExtraWidth/4 , height-8)];
                [path addArcWithCenter:CGPointMake( (kLargeTabExtraWidth/4)+8, height-8) radius:8 startAngle:M_PI endAngle:M_PI_2 clockwise:NO];
                                [path addLineToPoint:CGPointMake(width-(kLargeTabExtraWidth/4)-8, height)];
                [path addArcWithCenter:CGPointMake(width-(kLargeTabExtraWidth/4)-8, height-8) radius:8 startAngle:3*M_PI_2 endAngle:2*M_PI clockwise:NO];
                [path addLineToPoint:CGPointMake(width- kLargeTabExtraWidth/4,height/2)];
                [path addCurveToPoint:CGPointMake(width, self.bounds.origin.y)
                        controlPoint1:CGPointMake(width-kLargeTabExtraWidth/4, self.bounds.origin.y)
                        controlPoint2:CGPointMake(width+kLargeTabExtraWidth/5, self.bounds.origin.y)];

                [path addLineToPoint:self.bounds.origin];
                [path closePath];
                
                CGContextSetShadowWithColor(context, CGSizeMake(2,2), 2.0, [UIColor colorWithRed:105.0/255.0
                                                                                           green:105.0/255.0
                                                                                            blue:141.0/255.0
                                                                                           alpha:7].CGColor);
                break;
            }
            default:
                break;
        }
        if (_tabItem.tabOrientation == TTTabViewOrientationUp) {
            //transform
            CGContextTranslateCTM (context, width,height+kShadowOffset);
            CGContextRotateCTM(context, M_PI);
        }
                [self.tabItem.tabColor setFill];
        [path fill];

    }//custom view
}

-(void)underline
{
    if(! underlineLayer)
    {
        CGSize textSize = [_tabItem.tabTitle sizeWithFont:_label.font];
        CALayer *layer = [CALayer layer];
        layer.bounds = CGRectMake(0,0,textSize.width,2);
        layer.position = CGPointMake(CGRectGetMidX(_label.bounds), (CGRectGetMaxY(_label.bounds) - 5.0f) );
        layer.backgroundColor = _tabItem.textColor.CGColor;
        underlineLayer = layer;
    }
    [self.label.layer addSublayer:underlineLayer];
}

-(void)removeUnderline
{
    [underlineLayer removeFromSuperlayer];
}

-(void) highlight
{
    [self showHighlightWithRadius:self.bounds.size.width/4];
}

-(void) unhighlight
{
    [self hideHighlight];
}

-(void) handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        if([_delegate respondsToSelector:@selector(tabViewDidRecieveTapGesture:)])
        {
            [_delegate tabViewDidRecieveTapGesture:self];
        }
    }
}




@end
