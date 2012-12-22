//
//  TTFoldTransitionsView.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/17/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
typedef enum {TTFoldTransitionTypeUp, TTFoldTransitionTypeDown} TTFoldTransitionType;


@interface TTFoldTransitionsView : UIView

@property (assign) NSUInteger displayedViewIndex;
@property (nonatomic, strong) UIView *displayedView;
@property (nonatomic, weak) IBOutlet id delegate;
@property (nonatomic, weak) IBOutlet id dataSource;

-(id) initWithFrame:(CGRect)frame dataSource:(id)dataSource;
//-(id) initWithDataSource:(id)dataSource;

@end



@protocol TTFoldTransitionsViewDelegate <NSObject>

@optional

-(void)foldTransitionsView:(TTFoldTransitionsView *)foldTransitionsView
           willChangeToView:(UIView *)toView;

-(void)foldTransitionsView:(TTFoldTransitionsView *)foldTransitionsView
           didChangeToView:(UIView *)toView;

@end



@protocol TTFoldTransitionsViewDataSource <NSObject>

-(NSUInteger) numberOfViews;
-(UIView *) foldTransitionsView:(TTFoldTransitionsView *)foldTransitionView viewForIndex:(NSUInteger)index;

@end

