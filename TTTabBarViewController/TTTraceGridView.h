//
//  TTTraceGridView.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/2/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

/**
 The TraceGridView is presents the user with a matrix of tiles that
 they may trace a pattern through with there finger to select tiles
 or squares in the grid.  The tiles are indexed with  integers
 assigned sequentially from the upper right corner and then as
 you would read them across a page e.g. 2 = second tile in first row
 of the grid
 **/
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

// number of rows and columns are typically the same

#define kNumOfRows  3   //default value
#define kNumOfCols  3   //default value
#define kShakes 8       //s/b an even number
#define kShakeIncrement 1

//diagonal distance
#define kDecisiveDistance sqrt(_tileWidth * _tileWidth  + _tileHeight * _tileHeight)

//the maximum height and width -
//the actual bounds.size.height and width will vary a little depending on
//the number of rows and cols
#define kTraceGridHeight 320
#define kTraceGridWidth 320

@class TTTraceGridTile;
@class TTTraceLayerDelegate;
@class TTCircleLayerDelegate;
@class TTTraceGridLayerDelegate;
@class TTTraceGridBackgroundDelegate;
@class TTSelectedGridTilesLayerDelegate;
@class TTSelectedTiles;

typedef enum{
    TTShakeDirectionLeft,
    TTShakeDirectionright
}TTShakeDirection;

typedef enum{
    TTMoveDirectionLeft,
    TTMoveDirectionRight,
    TTMoveDirectionUp,
    TTMoveDirectionDown,
    TTMoveDirectionLeftUp,
    TTMoveDirectionLeftDown,
    TTMoveDirectionRightUp,
    TTMoveDirectionRightDown
}TTMoveDirection;

@interface TTTraceGridView : UIView

@property (nonatomic, strong) UIBezierPath *touchCircle;
@property (nonatomic, strong) NSArray *tiles;    //all tiles
@property (nonatomic, strong) TTSelectedTiles *selectedTiles;     //we keep this so a delegate does not have
                                                                //to implement traceGridNewTileEntered: if they just
                                                                //just want to wait until the entire pattern has been
                                                                //selected.  Not MVC but so be it
@property (nonatomic, strong) TTTraceGridTile *activeTile;
@property (nonatomic, strong) UIBezierPath *tracePath;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) TTTraceLayerDelegate *traceDelegate;    //these s/b strong since they are created here!
@property (nonatomic, strong) TTCircleLayerDelegate *circleDelegate;
@property (nonatomic, strong) TTTraceGridLayerDelegate *patternLayerDelegate;
@property (nonatomic, strong) TTTraceGridBackgroundDelegate  *backgroundLayerDelegate;
@property (nonatomic, strong) TTSelectedGridTilesLayerDelegate  *selectedTilesLayerDelegate;
@property (assign) CGPoint currentLocation;
@property (assign) NSUInteger rows;
@property (assign) NSUInteger cols;

//designated init
- (id)initWithRows:(NSInteger)rows
           columns:(NSInteger)cols
             frame:(CGRect)frame;
void drawGridPatterns (void *info, CGContextRef context);
//if initialized with initWithFrame then the rows and cols
//default to kNumOfCols and  kNumOfRows


-(void) shakeView;
-(void) resetTracePathWithAnimation:(BOOL)animation;
-(void) animateRandomTracePatternsOfLength:(NSNumber*) length;
-(void) animateRandomTracePatternsOfLength:(NSInteger)length withDelay:(NSTimeInterval)delay;
- (NSArray *) adjacentTilesToTile:(TTTraceGridTile *)tile;

@end


@interface NSObject(TTTraceGridViewDelegate)

//optional delegate method
-(void)traceGridViewDidFinishTrace:(TTTraceGridView *)traceView;
-(void)traceGridViewNewTileEntered:(TTTraceGridView *)traceView;
-(void)didClearTraceGrid:(TTTraceGridView *)traceView;

@end
