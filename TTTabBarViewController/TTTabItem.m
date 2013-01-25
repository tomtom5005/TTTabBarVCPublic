//
//  TTTabItem.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/1/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import "TTTabItem.h"
@interface TTTabItem()

@property (assign,readwrite) CGSize tabSize;

@end


@implementation TTTabItem


-(id) initWithTitle:(NSString *)title
           tabColor:(UIColor*)color
          textColor:(UIColor *)txtColor
       tabViewStyle:(TTTabViewStyle) style
tabOrientation:(TTTabViewOrientation)orientation
{
    if(self=[super init])
    {
        _tabViewStyle = style;
        _tabOrientation = orientation;
        CGSize textSize = [title sizeWithFont:[UIFont systemFontOfSize:kTabFontSize]];
        CGFloat height = textSize.height>kMinTabHeight? textSize.height : kMinTabHeight;
        CGFloat width = textSize.width>kMinTabWidth? textSize.width : kMinTabWidth;
        _tabSize = CGSizeMake(width + 2*kWidthPadding, height + 2*kHeightPadding);
        if(style == TTTabViewStyleLargeTab)
            _tabSize = CGSizeMake(_tabSize.width + kLargeTabExtraWidth, _tabSize.height);
        
        _tabImage = nil;
        _tabColor = color;
        if( ! _tabColor)
            _tabColor = [UIColor blueColor];
        _textColor = txtColor ;
        if( ! _textColor)
        {
            CGFloat grayScale;
            CGFloat a;
            BOOL grayConverted = [_tabColor getWhite:&grayScale alpha:&a];
            
            CGFloat r;
            CGFloat g;
            CGFloat b;
            BOOL rgbConverted = [_tabColor getRed:&r green:&g blue:&b alpha:&a];
            if (rgbConverted)
            {
                CGFloat grayValue = 0.21*r + 0.71*g + 0.07*b;
                if(grayValue<.5)
                    _textColor = [UIColor whiteColor];
                else
                    _textColor = [UIColor darkTextColor];
            }
            else if (grayConverted)
            {
                if(grayScale<.5)
                    _textColor = [UIColor whiteColor];
                else
                    _textColor = [UIColor darkTextColor];
            }
            else{
                _textColor = [UIColor darkTextColor];}
            
        }
        _tabTitle=title;
    }
    return self;
}

-(id) initWithTitle:(NSString *)title
           tabColor:(UIColor*)color
          textColor:(UIColor *)txtColor
       tabViewStyle:(TTTabViewStyle) style
{
        return [self initWithTitle:title
                          tabColor:color
                         textColor:txtColor
                      tabViewStyle:style
                    tabOrientation:TTTabViewOrientationDown];
}

-(id) initWithTitle:(NSString *)title
           tabColor:(UIColor*)color
          textColor:(UIColor *)txtColor
{
    return [self initWithTitle:title
                      tabColor:color
                     textColor:txtColor
                  tabViewStyle:TTTabViewStyleSmallTab];
    
    
}


-(id) initWithImage:(UIImage *)img title:(NSString *)title tabOrientation:(TTTabViewOrientation)orientation
{
    if(self=[super init])
    {
        _tabViewStyle = TTTabViewStyleCustom;
        _tabOrientation = orientation;
        _tabSize = img.size;
        _tabImage = img;
        _tabColor=[UIColor clearColor];
        _textColor = [UIColor blackColor];
        _tabTitle=title;
        if([_tabTitle length]==0)
            _tabTitle = NSLocalizedString(@"Unknown",@"Unknown");
        
    }
    return self;
}


-(id) initWithImage:(UIImage *)img title:(NSString *)title
{
    return [self initWithImage:img title:title tabOrientation:TTTabViewOrientationDown];
}

@end
