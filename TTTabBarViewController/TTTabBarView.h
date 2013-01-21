//
//  TTTabBarView.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/1/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

//WARNING
//Due to the sequence of events that occur when one uses the nib file to
//init a UIViewController and it's view and Interface Builder's insistance
//that the view controller's view have a frame equal to [[UIScreen mainScreen] applicationFrame],
//any view controller that uses a nib and wants it's view to be one of the views in the TTTabBarView
//that view controller will have  will have to resize it's view and position it's subviews
//using the delegate method :
//  -(void)tabBarView:(TTTabBarView *)tabBarView selectedViewWillChangeToView:(UIView *)view.
//
//So if you set the delegate to be the view controller for the view about to appear
//(due to it's tab being selected) you can do the set up in the delegate.  If you create a BOOL in this
//view controller(the delegate). say viewSetupCompleted, then you can use it to isolate things that
//you only want to do the first time.  Things you would have put in viewDidLoad if you could have.
//
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

extern NSString *const TTTabBarViewSelectedTabDidChangeFromTabAtIndexNotification; //declared in TTTabBarView
extern NSString *const TTTabBarViewSelectedViewWillChangeToViewNotification; //declared in TTTabBarView
extern NSString *const TTTabBarViewSelectedViewDidChangeToViewNotification; //declared in TTTabBarView

@protocol TTTabBarViewDelegate;
@protocol TTTabBarViewDataSource;
@class TTTabItem;

@interface TTTabBarView : UIView <UIScrollViewDelegate, TTTabViewDelegate>

@property (strong, nonatomic) NSDictionary *view;
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

