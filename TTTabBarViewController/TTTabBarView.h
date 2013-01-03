//
//  TTTabBarView.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/1/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTabView.h"
#import <QuartzCore/QuartzCore.h>

//padding between tabs
#define kInterTabPadding 4
#define kTabBarHeight 36
#define kTabSlideBarHeight 6

typedef enum {TTTabBarPositionTop, TTTabBarPositionBottom} TTTabBarPosition;
typedef enum {TTTabBarTypeStandardTabs, TTTabBarTypeLargeTabs, TTTabBarTypeCustomTabs} TTTabBarType;

@protocol TTTabBarViewDelegate;
@protocol TTTabBarViewDataSource;
@class TTTabItem;

@interface TTTabBarView : UIView <UIScrollViewDelegate, TTTabViewDelegate>

@property (strong, nonatomic) NSDictionary *view;
//@property (strong, nonatomic) NSArray *tabs;    //an array of TTTabItems
@property (strong, nonatomic) NSArray *tabViews;    //an array of TTTabViews
@property (assign) NSUInteger selectedTabIndex;
@property (strong, nonatomic) UIView *selectedViewContainerView;
@property (strong, nonatomic) UIView *selectedView;
@property (strong, nonatomic) UIView *tabSlideBar;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIView *tabContainerView;
@property (weak, nonatomic) id delegate;
@property (weak, nonatomic) id dataSource;
@property (assign) TTTabBarPosition tabBarPosition;
@property (assign) TTTabBarType tabBarType;
@property (strong, nonatomic) TTTabView *tabViewScrollViewDeceleratedTo;

//designated init
- (id)initWithFrame:(CGRect)frame
     tabBarPosition:(TTTabBarPosition)position
           delegate:(id)del
         dataSource:(id)source;

- (id)initWithFrame:(CGRect)frame
           delegate:(id)del
         dataSource:(id)source;

-(void) reloadData;
@end

@protocol TTTabBarViewDelegate <NSObject>

@optional

-(void)tabBarView:(TTTabBarView *)tabBarView
selectedTabDidChangeFromTabAtIndex:(NSUInteger)newTabIndex;

-(void)tabBarView:(TTTabBarView *)tabBarView
selectedViewWillChangeToView:(UIView *)view;

-(void)tabBarView:(TTTabBarView *)tabBarView
selectedViewDidChangeToView:(UIView *)view;

@end

@protocol TTTabBarViewDataSource <NSObject>

-(NSUInteger) numberOfTabsForTabBarView:(TTTabBarView *)tabBarView;
-(UIView *) tabBarView:(TTTabBarView *)tabBarView viewForIndex:(NSUInteger)index;
-(TTTabItem *) tabBarView:(TTTabBarView *)tabBarView tabItemForIndex:(NSUInteger)index;

@end

