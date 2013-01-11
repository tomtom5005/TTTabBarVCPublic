//
//  TTTabBarView.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/1/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import "TTTabBarView.h"
#import "TTTabItem.h"
#import "CoreGraphicsFunctions.h"

//NSNotification names
NSString *const TTTabBarViewSelectedTabDidChangeFromTabAtIndexNotification = @"TTTabBarViewSelectedTabDidChangeFromTabAtIndexNotification";
NSString *const TTTabBarViewSelectedViewWillChangeToViewNotification = @"TTTabBarViewSelectedViewWillChangeToViewNotification";
NSString *const TTTabBarViewSelectedViewDidChangeToViewNotification = @"TTTabBarViewSelectedViewDidChangeToViewNotification";

@interface TTTabBarView ()
{
    CGFloat tabY, viewY, slideBarY,tabScrollY;
}

@property (nonatomic, strong) UIScrollView *tabsScrollView;
@property (nonatomic, strong) UIView *tabsView;
@property (strong, nonatomic) UIView *highlight;

-(NSArray *) makeTabViewsForTabsView:(UIView *)tabsView;
-(TTTabView *)centerTabViewForProposedOffset:(CGPoint)scrollOffset;
-(void) didSelectTabView:(TTTabView *)tabView;
-(void) sizeTabBar;
-(void) sizeSelectedViewContainer;
-(void) didSelectTabItem:(TTTabItem *)item;
-(void) makeSubviews;
-(void) makeHighlightWithColor:(UIColor *)color alpha:(CGFloat)a size:(CGSize)size;

@end



@implementation TTTabBarView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame
                     delegate:nil
                   dataSource:nil];
}

- (id)initWithFrame:(CGRect)frame
           delegate:(NSObject<TTTabBarViewDelegate> *)del
         dataSource:(NSObject<TTTabBarViewDataSource> *)source
{
    return [self initWithFrame:frame
                tabBarPosition:TTTabBarPositionBottom
                      delegate:del
                    dataSource:source];
}

- (id)initWithFrame:(CGRect)frame
     tabBarPosition:(TTTabBarPosition)position
           delegate:(NSObject<TTTabBarViewDelegate> *)del
         dataSource:(NSObject<TTTabBarViewDataSource> *)source
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = del;
        self.dataSource = source;
        self.tabBarPosition = position;
        [self makeSubviews];
    }
    return self;
}

-(void) makeSubviews
{
    self.highlight = nil;
    self.containerView =[[UIView alloc] initWithFrame:self.bounds];
    [self.containerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|
                                            UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
    self.containerView.autoresizesSubviews=YES;
    [self addSubview:_containerView];
        
    switch (_tabBarPosition) {
        case TTTabBarPositionBottom:
            tabY = self.bounds.size.height-kTabBarHeight-kTabSlideBarHeight;
            viewY = 0.0;
            slideBarY = 0.0;
            tabScrollY = kTabSlideBarHeight;
            break;
            
        case TTTabBarPositionTop:
            tabY = 0.0;
            viewY = kTabBarHeight+kTabSlideBarHeight;
            slideBarY = kTabBarHeight;
            tabScrollY = 0.0;
            break;
            
        default:
            break;
    }
    self.tabsScrollView = [[UIScrollView alloc]
                           initWithFrame:CGRectMake(0,
                                                    tabScrollY,
                                                    self.bounds.size.width,
                                                    kTabBarHeight)];
    self.tabsScrollView.showsHorizontalScrollIndicator = NO;
    self.tabsScrollView.alwaysBounceHorizontal = YES;
    self.tabsScrollView.backgroundColor = [UIColor blackColor];
    self.tabsScrollView.delegate=self;
    [self.tabsScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin];

    self.tabSlideBar = [[UIView alloc] initWithFrame:CGRectMake(0, slideBarY, self.bounds.size.width, kTabSlideBarHeight)];
    [self.tabSlideBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin];

    self.tabContainerView = [[UIView alloc]
                             initWithFrame:CGRectMake(0,
                                                      tabY,
                                                      self.bounds.size.width,
                                                      kTabBarHeight+kTabSlideBarHeight)];
    [self.tabContainerView addSubview:self.tabSlideBar];
    [self.tabContainerView addSubview:self.tabsScrollView];
    [self.tabContainerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
                            UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
    
    self.selectedViewContainerView.autoresizesSubviews=YES;
    self.selectedViewContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY,
                                                                              self.bounds.size.width,
                                                                              self.bounds.size.height-kTabBarHeight-kTabSlideBarHeight)];
    _selectedViewContainerView.backgroundColor = [UIColor clearColor];
    [self.containerView addSubview:self.tabContainerView];
    [self.containerView addSubview:self.selectedViewContainerView];

}
- (void)reloadData
{
    if([self.dataSource respondsToSelector:@selector(numberOfTabsForTabBarView:)])
    {
        self.tabsView = [[UIView alloc] initWithFrame:CGRectZero];
        self.tabViews = [self makeTabViewsForTabsView:self.tabsView];
        self.selectedTabIndex = self.selectedTabIndex > [self.dataSource numberOfTabsForTabBarView:self]? 0: self.selectedTabIndex;
        self.tabsView.backgroundColor = [UIColor clearColor];
        TTTabView *lastTabView = [self.tabViews lastObject];
        CGFloat w = lastTabView.frame.origin.x + lastTabView.frame.size.width+kInterTabPadding;
        CGFloat x = w >= self.frame.size.width ? kInterTabPadding : (self.frame.size.width -w)/2;
        CGRect tabsFrame = CGRectMake(x,0,w,kTabBarHeight);
        self.tabsView.frame = tabsFrame;
        [self.tabsView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
        self.tabsScrollView.contentSize = tabsFrame.size;
        [self.tabsScrollView addSubview:self.tabsView];
        TTTabItem *tabItem = [self.dataSource tabBarView:self tabItemForIndex:self.selectedTabIndex];
        [self didSelectTabItem:tabItem];
    }
}


-(void) layoutSubviews
{
    if(self.tabsScrollView )   //a check to see if makeSubviews was done could be any ui object
    {
        CGFloat x = (self.bounds.size.width-_containerView.bounds.size.width)/2;
        CGFloat y = (self.bounds.size.height-_containerView.bounds.size.height)/2;
        self.containerView.frame = CGRectMake(x,y,
                                          self.containerView.bounds.size.width,
                                          self.containerView.bounds.size.height);
        [self sizeTabBar];
        [self sizeSelectedViewContainer];
    }
}


#pragma mark - SITabBarViewController methods

-(NSArray *) makeTabViewsForTabsView:(UIView *)tabsView
{
    NSMutableArray *views = nil;
    if([self.dataSource respondsToSelector:@selector(tabBarView:viewForIndex:)])
    {
        CGFloat x = kInterTabPadding;
        NSInteger numberOfTabs = [self.delegate numberOfTabsForTabBarView:self];
        views = [[NSMutableArray alloc]initWithCapacity:numberOfTabs];
        for(int i=0; i<numberOfTabs; i++)
        {
            TTTabItem *tab = [self.dataSource tabBarView:self tabItemForIndex:i];
            CGFloat maxHeight = kTabBarHeight;
            CGFloat tabHeight = tab.tabSize.height>maxHeight ? maxHeight : tab.tabSize.height;
            CGFloat y = self.tabBarPosition == TTTabBarPositionBottom? 0.0: maxHeight-tabHeight;

            TTTabView *tabView = [[TTTabView alloc] initWithFrame:CGRectMake(x,
                                                                             y,
                                                                             tab.tabSize.width,
                                                                             tabHeight)];
            tabView.delegate = self;
            [tabView configureWithTabItem:tab];
            x+=tabView.bounds.size.width+kInterTabPadding;
            [views addObject:tabView ];
            [tabsView addSubview:tabView];
        }
    }
    return (NSArray *)views;
}

-(TTTabView *)centerTabViewForProposedOffset:(CGPoint)scrollOffset
{
    //scroll offset is the point the scroll view intends to use as the
    //content offset when it stops scrolling - we want the view whose
    //center is closest to the center of the content showing in the scroll
    //view
    CGFloat midWay = CGRectGetMidX(self.tabsScrollView.frame);
    CGFloat centerX = scrollOffset.x+midWay;
    CGFloat maxCenterX = self.tabsView.bounds.size.width-midWay;;
    centerX = maxCenterX<centerX ? maxCenterX : centerX;
    
    TTTabView *centerTabView = nil;
    for (TTTabView *tv in self.tabViews)
    {
        if(CGRectGetMaxX(tv.frame) >centerX)
        {
            centerTabView = tv;
            break;
        }
    }
    return centerTabView;
}

-(void) makeHighlightWithColor:(UIColor *)color alpha:(CGFloat)a size:(CGSize)size
{
    // If self is already highlighted were done
    if (! [self highlight])
    {
        // The highlight image is taken from the current view's appearance.
        //essentially we make a mono chromatic image photo copy
        // As a side effect, if the view's content, size or shape changes,
        // the highlight won't change its appearance
        //
        //What we need to do to make this attractive is to fillWith a pattern where pattern
        //is mome sore of on off pixel pattern
        //We are going to go with an underline for now since
        //I am not sure this will ever look good
        //
        UIGraphicsBeginImageContext(size);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        UIBezierPath *path = [UIBezierPath bezierPath];
        [color setFill];
        
        //CGContextSaveGState(ctx);
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 20, color.CGColor);
        CGPoint center = CGPointMake( rint(size.width/2), rint(size.height/2) );
        CGFloat r = size.width>size.height ? size.height/2 : size.width/2;
        int n = 8;
        CGFloat increment = r/n;
        [path addArcWithCenter:center radius:r startAngle:0 endAngle:2*M_PI clockwise:YES];
        [path fillWithBlendMode:kCGBlendModeSoftLight alpha:a/n];
       // CGContextRestoreGState(ctx);
        for(int i = 1; i<n; i++)
        {
            [path addArcWithCenter:center radius:r-(i*increment) startAngle:0 endAngle:2*M_PI clockwise:YES];
            [path fillWithBlendMode:kCGBlendModeSoftLight alpha:a/n];
        }
        //now fill the path with a blend mode that only shows the fill where the there are opaque pixels in the rendered image
        //[path fill];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        // Make the highlight view itself, and position it at the same
        // point as self. Overlay it over self.
        self.highlight = [[UIImageView alloc] initWithImage:img];
       // self.highlight.opaque = YES;
    }
}


-(void) didSelectTabView:(TTTabView *)tabView
{    
    if( ! self.tabsScrollView.decelerating)
    {
        //then the tabView was selected with a tap gesture not by the end of a horizontol scroll
        CGFloat newOffsetX = tabView.center.x - self.tabsScrollView.center.x;
        CGPoint newOffset = CGPointMake(newOffsetX, self.tabsScrollView.contentOffset.y);
        [self.tabsScrollView setContentOffset:newOffset animated:YES];
    }
    NSUInteger tabIndexSelected = [self.tabViews indexOfObject:tabView];
/*
    if( ! self.highlight){
        [self makeHighlightWithColor:[UIColor whiteColor] alpha:0.5 size:CGSizeMake(2*kMinTabWidth, 2*kMinTabHeight)];
    }
 */   
    if (tabIndexSelected != self.selectedTabIndex )
    {
        //CGFloat x = rint((tabView.bounds.size.width - self.highlight.bounds.size.width)/2);
        //CGFloat y = rint((tabView.bounds.size.height - self.highlight.bounds.size.height)/2);
        //self.highlight.frame = CGRectMake(x, y,
        //                                  self.highlight.bounds.size.width,
       //                                   self.highlight.bounds.size.height);
       // [tabView addSubview:self.highlight];
        
        TTTabView *oldTabView = [self.tabViews objectAtIndex:self.selectedTabIndex];
        [oldTabView removeUnderline];
        [tabView underline];
        self.selectedTabIndex = tabIndexSelected;
        [self didSelectTabItem:tabView.tabItem];
    }
}


-(void) didSelectTabItem:(TTTabItem *)item
{
    if([_delegate respondsToSelector:@selector(tabBarView:selectedTabDidChangeFromTabAtIndex:)])
        [_delegate tabBarView:self selectedTabDidChangeFromTabAtIndex:self.selectedTabIndex];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:TTTabBarViewSelectedTabDidChangeFromTabAtIndexNotification
                  object:self
                    userInfo:@{@"Index" : [NSNumber numberWithInteger:self.selectedTabIndex]}];
    
    UIView * newView = [self.dataSource tabBarView:self viewForIndex:self.selectedTabIndex];
    [newView setAlpha: 0];
    NSInteger oldViewIndex = [[self.selectedViewContainerView subviews] count]-1;//will be -1 if no subviews
    [self.selectedViewContainerView addSubview:newView];
    
    if([self.delegate respondsToSelector:@selector(tabBarView:selectedViewWillChangeToView:)])
        [self.delegate tabBarView:self selectedViewWillChangeToView:newView];
    [nc postNotificationName:TTTabBarViewSelectedViewWillChangeToViewNotification
                  object:self
                userInfo:@{@"View" : newView}];

    //TODO: In the animation block,or before it,we should add a highlight glow like on pivotal
    //tracker start tracking button for the selected tab. We would just leaving glowing as long
    //as tab is selected tab Also we will need to change
    //the color of the "sliding bar" to match the tab
        
    UIView __block *oldView = oldViewIndex > -1?[[self.selectedViewContainerView subviews] objectAtIndex:oldViewIndex]:nil;
    if(oldView)
    {
        [UIView animateWithDuration:0.3 animations:^{
            oldView.alpha = 0;
            newView.alpha = 1;
        }
                         completion:^(BOOL finished){
                             self.tabSlideBar.backgroundColor=item.tabColor;
                             [oldView removeFromSuperview];
                         }];
    }
    else    //no oldView so this is the first time TTTabBarView is shown
    {
        newView.alpha=1;
        self.tabSlideBar.backgroundColor=item.tabColor;
        [[self.tabViews objectAtIndex:0] underline];
    }
    self.selectedView = newView;
    
    if([_delegate respondsToSelector:@selector(tabBarView:selectedViewDidChangeToView:)])
        [_delegate tabBarView:self selectedViewDidChangeToView:newView];
    [nc postNotificationName:TTTabBarViewSelectedViewDidChangeToViewNotification
                      object:self
                    userInfo:@{@"View" : newView}];
}

    

-(void) sizeTabBar
{
    self.tabsScrollView.contentSize = self.tabsView.bounds.size;
    
}
    
    
-(void) sizeSelectedViewContainer
{
    self.selectedViewContainerView.frame = CGRectMake(0,viewY,
                                       self.containerView.bounds.size.width,
                                       self.containerView.bounds.size.height -self.tabContainerView.bounds.size.height);
    self.selectedView.frame = self.selectedViewContainerView.bounds;
    
    self.selectedViewContainerView.autoresizesSubviews=YES;
}

    
#pragma mark - UIScrollViewDelegate Methods

-(void) scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat adjustment = 0;
    CGPoint scrollOffset = *targetContentOffset;
    TTTabView *centerTabView = [self centerTabViewForProposedOffset:scrollOffset];
    //centerTabView contains the scrollViewCenter+scrollOffset
    if(centerTabView){
        adjustment = centerTabView.center.x-CGRectGetMidX(self.tabsScrollView.frame)- scrollOffset.x;
        *targetContentOffset = CGPointMake(scrollOffset.x+adjustment,
                                           scrollOffset.y);
        [self didSelectTabView:centerTabView];
        self.tabViewScrollViewDeceleratedTo = centerTabView;
    }
}
/*
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self didSelectTabView:self.tabViewScrollViewDeceleratedTo];
}
*/
#pragma mark - SITabView delegate method

-(void) tabViewDidRecieveTapGesture:(TTTabView *)tabView
{
    [self didSelectTabView:tabView];
}
@end