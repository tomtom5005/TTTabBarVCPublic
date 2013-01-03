//
//  TTFoldTransitionsView.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/17/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//


#import "TTFoldTransitionsView.h"
#import "UIView+FoldTransitionFromViewToView.h"


@interface TTFoldTransitionsView()
{
    CGRect topRect;
    CGRect bottomRect;
}
-(void) setUp;

@end

@implementation TTFoldTransitionsView

-(id) initWithFrame:(CGRect)frame dataSource:(id)dataSource
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _dataSource = dataSource;
        self.displayedViewIndex = 0;
        [self setUp];

        if([dataSource respondsToSelector:@selector(foldTransitionsView:viewForIndex:)])
        {
            if([dataSource respondsToSelector:@selector(numberOfViews)])
            {
                if ([dataSource numberOfViews] >0)
                {
                    self.displayedView = [dataSource foldTransitionsView:self
                                                            viewForIndex:_displayedViewIndex];
                    _displayedView.frame = self.bounds;
                    [self addSubview:_displayedView];
                    [_displayedView sizeToFit];
                }
            }
        }
    }
    return self;
}


-(id) initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame dataSource:nil];
}

/*
-(id) initWithDataSource:(id)dataSource
{
    CGRect rect = CGRectZero;
    if([dataSource respondsToSelector:@selector(foldTransitionsView:viewForIndex:)])
    {
        if([dataSource respondsToSelector:@selector(numberOfViews)]){
            if ([dataSource numberOfViews] >0){
                UIView *v = [dataSource foldTransitionsView:self
                                               viewForIndex:_displayedViewIndex];
                rect = v.frame;
            }
        }
    }
    return [self initWithFrame:rect dataSource:dataSource];
}
*/

-(void) setUp
{
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
	[self addGestureRecognizer:swipeUp];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
	[self addGestureRecognizer:swipeDown];
}

-(NSUInteger) numberOfViews
{
    NSUInteger num = 0;
    if([self.dataSource respondsToSelector:@selector(numberOfViews)]){
        num = [self.dataSource numberOfViews];
    }
    return num;
}

-(UIView *)viewForIndex:(NSUInteger)i
{
    UIView *v = nil;
    if([self.dataSource respondsToSelector:@selector(foldTransitionsView:viewForIndex:)]){
        i = i > [self numberOfViews] ?  0 : i;
        i = i <= 0 ?  0 : i;
        v = [self.dataSource foldTransitionsView:self viewForIndex:i];
    }
    return v;
}

-(void) swipeUp:(UISwipeGestureRecognizer *)gesture
{
    NSUInteger index = self.displayedViewIndex + 1;
    index = index > [self numberOfViews] ?  0 : index;
    UIView * nextView = [self viewForIndex:index];
    [UIView foldTransitionFromView:self.displayedView
                            toView:nextView
                         direction:TTFoldTransitionDirectionUp
                          duration:1.2
                        completion:^{
                            if([self.delegate
                                respondsToSelector:@selector(foldTransitionsView:willChangeToView:)]){
                                [self.delegate foldTransitionsView:self willChangeToView:nextView];
                            }
                            
                            self.displayedViewIndex = index;
                            self.displayedView=nextView;
                            
                            if([self.delegate
                                respondsToSelector:@selector(foldTransitionsView:didChangeToView:)]){
                                [self.delegate foldTransitionsView:self didChangeToView:nextView];
                            }
                        }];
}



-(void) swipeDown:(UISwipeGestureRecognizer *)gesture
{
    NSUInteger index = self.displayedViewIndex>0 ? self.displayedViewIndex -1 : [self numberOfViews]-1;
    UIView * nextView = [self viewForIndex:index];
    [UIView foldTransitionFromView:self.displayedView
                            toView:nextView
                         direction:TTFoldTransitionDirectionDown
                          duration:1.2
                        completion:^{
                            if([self.delegate
                                respondsToSelector:@selector(foldTransitionsView:willChangeToView:)]){
                                [self.delegate foldTransitionsView:self willChangeToView:nextView];
                            }
                            
                            self.displayedViewIndex = index;
                            self.displayedView=nextView;
                            
                            if([self.delegate
                                respondsToSelector:@selector(foldTransitionsView:didChangeToView:)]){
                                [self.delegate foldTransitionsView:self didChangeToView:nextView];
                            }
                        }];
    
}



@end
