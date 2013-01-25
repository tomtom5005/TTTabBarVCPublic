//
//  TTTabItem.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/1/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//



#import <Foundation/Foundation.h>

@class TTTabView;

#define kTabFontSize 12
#define kHeightPadding 3
#define kWidthPadding 4
#define kDefaultTabBarHeight 60
#define kLargeTabExtraWidth 100   //the amount of extra width required to be able to draw large tabs
#define kMinTabHeight 24
#define kMinTabWidth 40

//height padding is used as top and bottom padding so size.height is increased by 2 * padding
//analogous for width padding

//TABS MUST HAVE TITLES SO THEY CAN BE SORTED
//AND SO TITLE CAN BE USED AS A KEY
//TITLES WILL NOT BE DISPLAYED IF AN IMAGE EXISTS
//SO TITLE TEXT WILL NEED TO BE PART OF IMAGE IF
//YOU WANT TEXT

typedef enum{TTTabViewStyleCustom, TTTabViewStyleSmallTab, TTTabViewStyleLargeTab}TTTabViewStyle;
typedef enum{TTTabViewOrientationUp, TTTabViewOrientationDown}TTTabViewOrientation;

@interface TTTabItem : NSObject

@property (assign,readonly) CGSize tabSize;
@property (nonatomic, strong) UIImage *tabImage;
@property (nonatomic, strong) UIColor *tabColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSString *tabTitle;
@property (nonatomic, weak) TTTabView *tabView;
@property (nonatomic, weak) UIView *view;
@property (assign) TTTabViewStyle tabViewStyle;
@property (assign) TTTabViewOrientation tabOrientation;

//designated initializer;
-(id) initWithTitle:(NSString *)title
           tabColor:(UIColor*)color
          textColor:(UIColor *)txtColor
       tabViewStyle:(TTTabViewStyle) style
     tabOrientation:(TTTabViewOrientation)orientation;

-(id) initWithTitle:(NSString *)title
           tabColor:(UIColor*)color
          textColor:(UIColor *)txtColor
       tabViewStyle:(TTTabViewStyle) style;

-(id) initWithTitle:(NSString *)title
           tabColor:(UIColor*)color
          textColor:(UIColor *)txtColor;

-(id) initWithImage:(UIImage *)img
              title:(NSString *)title;

-(id) initWithImage:(UIImage *)img
              title:(NSString *)title
     tabOrientation:(TTTabViewOrientation)orientation;

@end
