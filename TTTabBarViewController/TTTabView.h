//
//  TTTabView.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/1/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@class TTTabItem;

#define kLabelInsetX 6
#define kLabelInsetY 0
#define kMininumFontSize 10
#define kFontSize 16
#define kShadowOffset 2

@interface TTTabView : UIView

-(id) initWithTab:(TTTabItem *)tab;
-(void) configureWithTabItem:(TTTabItem *)tabItem;
@property (nonatomic, strong) TTTabItem *tabItem;
@property (nonatomic, weak) id delegate;

-(void)underline;
-(void)removeUnderline;
-(void)highlight;
-(void)unhighlight;

@end

@protocol TTTabViewDelegate <NSObject>
 
-(void)tabViewDidRecieveTapGesture:(TTTabView *)tabView;

@end
