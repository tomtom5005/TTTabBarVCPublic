//
//  TTTraceGridView.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/2/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "UIView+ShakeView.h"
#import "TTTraceGridView.h"
#import "CoreGraphicsFunctions.h"
#import "TTSelectedTiles.h"
#import "TTTraceGridTile.h"

#import "TTTraceGridLayerDelegate.h"
#import "TTTraceLayerDelegate.h"
#import "TTCircleLayerDelegate.h"
#import "TTTraceGridBackgroundDelegate.h"
#import "TTSelectedGridTilesLayerDelegate.h"

@interface TTTraceGridView()
{
@private
    NSInteger _tileWidth;
    NSInteger _tileHeight;
    CGFloat _maxRadius;
    CGRect _tileBounds;
    CALayer *_patternLayer;
    CALayer *_traceLayer;
    CALayer *_circleLayer;
    CALayer *_backgroundLayer;
    CALayer *_selectedTilesLayer;
    NSTimer *animationTimer;
    dispatch_queue_t drawTilesQ;       //serial queue for creating selected tiles
}

-(void)tileEnteredWithTouch:(UITouch *)touch useHotSpot:(BOOL)useHotSpot;
-(void) newTileTouched;
-(void) didFinishTrace;
-(void) didResetTracePath;
-(void) createSublayers;
-(void) createTraceLayer;
-(void) createCircleLayer;
-(void) createPatternLayer;
-(void) createSelectedTilesLayer;
-(void)animateRandomTracePatternsForTiles:(NSTimer *)timer;
-(void) animateTraceToTile:(TTTraceGridTile *)tile;
-(TTTraceGridTile *) nextTileNotInPatternTiles:(NSMutableArray *)pattern fromTile:(TTTraceGridTile *)tile;
-(void) toSelectedTilesAddedTile:(TTTraceGridTile *)tile;
-(TTMoveDirection) directionTravelledFromPoint:(CGPoint)startPt toPoint:(CGPoint)endPt;
-(TTTraceGridTile *) adjacentTileToTile:(TTTraceGridTile*)activeTile inDirection:(TTMoveDirection)direction;
-(CGPoint) nearestPointOnGridToPoint:(CGPoint)pt;
//- (TraceGridTile *) nextTileFromTile:(TraceGridTile *)tile

//accessors
-(dispatch_queue_t) drawTilesQ;
-(void) setDrawTilesQ:(dispatch_queue_t) queue;

@end

@implementation TTTraceGridView

@synthesize tiles;
@synthesize activeTile;
@synthesize delegate;
@synthesize selectedTiles;      //has special getter
@synthesize rows;
@synthesize cols;

#pragma mark - UIView Methods

-(void) dealloc
{
    if(animationTimer)
        [animationTimer invalidate];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithRows:kNumOfRows columns:kNumOfCols frame:frame];
}

#pragma mark - TTTraceGridView Methods

- (id)initWithRows:(NSInteger)r columns:(NSInteger)c frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if(r<3 || r>8 ||c<3 || c>8){
            r = kNumOfRows;
            c = kNumOfCols;
        }
        self.rows = r;
        self.cols=c;
        
        CGFloat centerX = CGRectGetMidX (frame);
        CGFloat minY = CGRectGetMinY (frame);
        CGPoint centerPt = CGPointMake(centerX, minY+160);
        CGRect newFrame = CGRectMake(centerX-160, minY, kTraceGridWidth, kTraceGridHeight);
        self = [super initWithFrame:newFrame];
        self.center = centerPt;
        
        CGFloat w = (NSInteger)self.bounds.size.width/rows;
        CGFloat h = (NSInteger)self.bounds.size.height/cols;
        _tileWidth = (NSInteger)w;
        _tileHeight = (NSInteger)h;
        _maxRadius = _tileWidth>_tileHeight? _tileHeight/2 : _tileWidth/2;
        _tileBounds = CGRectMake(0, 0, w, h);
        
        //adjust frame so it is an exact multiple of tiles
        CGFloat xInset = (self.frame.size.width - rows*_tileWidth);
        CGFloat yInset = (self.frame.size.height - cols*_tileHeight);
        self.frame = CGRectInset (self.frame,xInset,yInset);
        
        //create grid tile objects - like views but lighter weight
        //we could use dispatch apply to get this off main queue - probably not worth it
        NSMutableArray *ma = [[NSMutableArray alloc] initWithCapacity:cols*rows];
        
        for (int i = 0; i<rows; i++)
        {
            for (int j = 0; j<cols; j++)
            {
                CGRect rect = CGRectMake(i*_tileWidth,j*_tileHeight,_tileWidth,_tileHeight);
                NSUInteger number = j*rows + i;
                TTTraceGridTile *tile = [[TTTraceGridTile alloc]
                                       initWithFrame:rect
                                       tileNumber:number];
                [ma addObject:tile];
            }
        }
        self.tiles = [ma sortedArrayUsingComparator:^( id obj1, id obj2) {
            TTTraceGridTile *t1 = (TTTraceGridTile *)obj1;
            TTTraceGridTile *t2 = (TTTraceGridTile *)obj2;
            NSInteger num1 = t1.tileNumber;
            NSInteger num2 = t2.tileNumber;
            if(num1<num2)
                return NSOrderedAscending;
            else if(num1>num2)
                return NSOrderedDescending;
            else    //equal
                return NSOrderedSame;
        }];
        for(TTTraceGridTile*t in tiles){
            t.adjacentTiles = [self adjacentTilesToTile:t];
        }
        self.layer.cornerRadius = kCornerRadius;    //defined in TraceGridLayerDelegate
        self.layer.shadowRadius = 5.0;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.layer.bounds
                                                           cornerRadius:kCornerRadius].CGPath;
        self.layer.shadowOpacity = 0.4;
        self.layer.shadowOffset = CGSizeMake(6.0, 6.0);
        self.layer.backgroundColor = [UIColor blackColor].CGColor;
        //create sublayers for custom drawing of
        //background patterns, tracePath and touch circle
        
        self.activeTile = [self.tiles objectAtIndex:0]; //no particular reason for choosing this tile
        //just want to make sure a tile is chosen
        self.currentLocation = CGPointMake(CGRectGetMidX(activeTile.tileFrame),
                                           CGRectGetMidY(activeTile.tileFrame));
        [self createSublayers];
        [_backgroundLayer setNeedsDisplay];
        [_patternLayer setNeedsDisplay];
        [_circleLayer setNeedsDisplay];
        
    }
    return self;
}


#pragma mark - accessors

-(dispatch_queue_t) drawTilesQ
{
    if(! drawTilesQ)
    {
        drawTilesQ = dispatch_queue_create("com.tsquaredapps.drawTilesQueue", DISPATCH_QUEUE_SERIAL);
    }
    return drawTilesQ;
}

-(void) setDrawTilesQ:(dispatch_queue_t) queue
{
        drawTilesQ = queue;
}




-(TTSelectedTiles *) selectedTiles
{
    if (!selectedTiles) {
        selectedTiles = [[TTSelectedTiles alloc] initWithCapacity:[tiles count]];
    }
    return selectedTiles;
}


#pragma mark - TraceGridView methods

-(void) createSublayers
{
    [self createBackgroundLayer];
    [self createPatternLayer];
    [self createTraceLayer];
    [self createCircleLayer];
    [self createSelectedTilesLayer];
    [self.layer addSublayer:_backgroundLayer];
    [self.layer addSublayer:_traceLayer];
    [self.layer addSublayer:_patternLayer];
    [self.layer addSublayer:_selectedTilesLayer];
    [self.layer addSublayer:_circleLayer];
}

-(void) createBackgroundLayer
{
    //kCornerRadius defined in TraceGridLayerDelegate
    
    self.backgroundLayerDelegate = [[TTTraceGridBackgroundDelegate alloc]
                                    initWithCornerRadius:kCornerRadius];
    _backgroundLayer = [CALayer layer];
    _backgroundLayer.delegate = _backgroundLayerDelegate;
    _backgroundLayer.frame = self.bounds;
    _backgroundLayer.cornerRadius = kCornerRadius;    //defined in TraceGridLayerDelegate
    _backgroundLayer.masksToBounds=YES;
    _backgroundLayer.borderColor = [UIColor blackColor].CGColor;
    _backgroundLayer.borderWidth=5;
    _backgroundLayer.backgroundColor = [UIColor blackColor].CGColor;
    
    
}

-(void) createPatternLayer
{
    self.patternLayerDelegate = [[TTTraceGridLayerDelegate alloc]
                                 initWithRadius:_maxRadius
                                 tileBounds:_tileBounds];
    _patternLayer = [CALayer layer];
    _patternLayer.delegate = self.patternLayerDelegate;
    _patternLayer.frame = self.bounds;
}

-(void) createTraceLayer
{
    if(!_tracePath)
    {
        self.tracePath = [UIBezierPath bezierPath];
    }
    self.traceDelegate = [[TTTraceLayerDelegate alloc]
                          initWithTraceGridView:self ];
    
    _traceLayer = [CALayer layer];
    _traceLayer.delegate = _traceDelegate;
    _traceLayer.backgroundColor = [UIColor clearColor].CGColor;
    _traceLayer.frame = self.bounds;
    
}


-(void) createCircleLayer
{
    if(!_touchCircle)
    {
        CGPoint arcCenter = CGPointMake(kTouchCircleRadius + kCirclePathWidth/2,
                                        kTouchCircleRadius + kCirclePathWidth/2);
        self.touchCircle = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                          radius:kTouchCircleRadius
                                                      startAngle:0
                                                        endAngle:2*M_PI
                                                       clockwise:YES];
        
    }
    self.circleDelegate = [[TTCircleLayerDelegate alloc]
                           initWithCirclePath:_touchCircle
                           radius:kTouchCircleRadius
                           gridTile:activeTile                                                                           touchLocation:_currentLocation];
    
    _circleLayer = [CALayer layer];
    _circleLayer.delegate = _circleDelegate;
    _circleLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    CGFloat radiusPlusStroke = kTouchCircleRadius + kCirclePathWidth/2;
    CGFloat deltaX = (activeTile.tileFrame.size.width - radiusPlusStroke*2)/2;
    CGFloat deltaY = (activeTile.tileFrame.size.height - radiusPlusStroke*2)/2;
    CGFloat x = activeTile.tileFrame.origin.x + deltaX;
    CGFloat y = activeTile.tileFrame.origin.y + deltaY;
    CGRect circleRect = CGRectMake(x,y,radiusPlusStroke*2,radiusPlusStroke*2);
    _circleLayer.frame = circleRect;
    _circleLayer.hidden = YES;    //we set this here since we always want this hidden
    _circleLayer.opacity = 0.0;        //until we get a touch event
}


-(void) createSelectedTilesLayer
{
    
    UIColor *outerColor = [UIColor colorWithRed:0 green:63/255 blue:21/255 alpha:1];
    UIColor *pointColor = [UIColor colorWithRed:159/255 green:1 blue:184/255 alpha:1];
    
    
    self.selectedTilesLayerDelegate = [[TTSelectedGridTilesLayerDelegate alloc]
                                       initWithTraceGridView:self
                                       circleRadius:_maxRadius/2.5
                                       outerColor:outerColor
                                       pointColor:pointColor];
    _selectedTilesLayer = [CALayer layer];
    _selectedTilesLayer.delegate = _selectedTilesLayerDelegate;
    _selectedTilesLayer.backgroundColor = [UIColor clearColor].CGColor;
    _selectedTilesLayer.frame = self.bounds;
}

-(void) resetTracePathWithAnimation:(BOOL)animation
{
    if(animation){
        _traceLayer.opacity = 0.0;
    }
    [_traceLayer removeFromSuperlayer];
    [_selectedTilesLayer removeFromSuperlayer];
    self.tracePath = nil;
    [self createTraceLayer];
    [self.layer insertSublayer:_traceLayer below:_patternLayer];
    [self createSelectedTilesLayer];
    [self.layer insertSublayer:_selectedTilesLayer below:_circleLayer];
    [self.selectedTiles removeAllTiles];
    activeTile=nil;
    [self didResetTracePath];
}

-(void) shakeView
{
    [self shakeViewNTimes:kShakes startLeft:YES completion:^{
        [self performSelector:@selector(didResetTracePath)
                   withObject:nil
                   afterDelay:0.1];
    }];
}

#pragma mark - animate trace methods


-(void) animateRandomTracePatternsOfLength:(NSInteger)length withDelay:(NSTimeInterval)delay
{
    [self performSelector:@selector(animateRandomTracePatternsOfLength:)
               withObject:[NSNumber numberWithInteger:length]
               afterDelay:delay];
}

-(void) animateRandomTracePatternsOfLength:(NSNumber *)length
{
    //TODO: replace the timer animation system with a CAGroupAnimation
    //with beginTimes - the current system can crash if the animations run a bit long
    //the remove path method can be called prematurely 
    NSInteger len = [length integerValue];
    NSInteger numOfNodes = len>6 ? len : 6;
    int r = arc4random() % [tiles count];
    TTTraceGridTile *tile = [tiles objectAtIndex:r];
    _circleLayer.position = tile.tileCenter;
    _circleLayer.hidden = NO;
    _circleLayer.opacity = 1;
    
    NSMutableArray *patternTiles = [[NSMutableArray alloc] initWithObjects:tile, nil];
    for (NSInteger i = 1;  i < numOfNodes; i++)
    {
        TTTraceGridTile *nextTile = [self nextTileNotInPatternTiles:patternTiles
                                                         fromTile:[patternTiles lastObject]];
        [patternTiles addObject:nextTile];
    }
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                      target:self
                                                    selector:@selector(animateRandomTracePatternsForTiles:)
                                                    userInfo:patternTiles
                                                     repeats:YES];
}

-(void)animateRandomTracePatternsForTiles:(NSTimer *)timer
{
    static int tileIndex = 0;
    NSArray *patternTiles = (NSArray *)[timer userInfo];
    TTTraceGridTile * tile = [patternTiles objectAtIndex:tileIndex];
    [self animateTraceToTile:tile];
    
    tileIndex++;
    if (tileIndex==[patternTiles count])
    {
        [animationTimer invalidate];
        tileIndex = 0;
        patternTiles = nil;
        _circleLayer.opacity = 0.0;
        _circleLayer.hidden = YES;
        [self performSelector:@selector(resetTracePathWithAnimation:)
                   withObject:[NSNumber numberWithBool:YES]
                   afterDelay:0.5];
    }
}


-(void) animateTraceToTile:(TTTraceGridTile *)tile
{
    if(animationTimer)
        [self.selectedTiles addTile:tile];
    activeTile = tile;
    _circleLayer.position = tile.tileCenter;
    _circleLayer.hidden = NO;
    _circleLayer.opacity = 1;
    [_traceLayer setNeedsDisplay];
    [_selectedTilesLayer setNeedsDisplay];
}


-(TTTraceGridTile *) nextTileNotInPatternTiles:(NSMutableArray *)pattern
                                    fromTile:(TTTraceGridTile *)tile
{
    NSMutableArray *usefulTiles = [[NSMutableArray alloc]
                                   initWithCapacity:[tile.adjacentTiles count]];
    for(TTTraceGridTile *t in tile.adjacentTiles)
    {
        if( ! [pattern containsObject:t]){
            [usefulTiles addObject:t];
        }
    }
    TTTraceGridTile *chosenTile;
    if([usefulTiles count] == 0)
    {
        //all adjacent tiles already in pattern
        int r = arc4random() % [tile.adjacentTiles count];
        TTTraceGridTile *recursionTile = [tile.adjacentTiles objectAtIndex:r];
        NSMutableArray *expandedPattern = [NSMutableArray arrayWithArray:pattern];
        [expandedPattern addObject:recursionTile];
        chosenTile = [self nextTileNotInPatternTiles:expandedPattern fromTile:recursionTile];
    }
    else if ([usefulTiles count] == 1)
    {
        chosenTile = [usefulTiles objectAtIndex:0];
    }
    else    //[usefulTiles count]>1;
    {
        int r = arc4random() % [usefulTiles count];
        chosenTile = [usefulTiles objectAtIndex:r];
    }
    return chosenTile ;
}



- (NSArray *) adjacentTilesToTile:(TTTraceGridTile *)tile
{
    int t = tile.tileNumber;
    int col = t%cols;
    int row = (t-t%cols)/cols;
    NSMutableArray *adjacentTiles = [[NSMutableArray alloc] initWithCapacity:8];
    
    if(col == 0)    //left col
    {
        if(row ==0) //top left
        {
            NSUInteger choices[] = {t+1,t+cols,(t+cols)+1};
            for(int i=0; i<3; i++){
                [adjacentTiles addObject:[tiles objectAtIndex:choices[i]]];
            }
        }
        else if (row == rows-1) //bottom left
        {
            NSUInteger choices[] = {t+1,t-cols,(t-cols)+1};
            for(int i=0; i<3; i++){
                [adjacentTiles addObject:[tiles objectAtIndex:choices[i]]];
            }
        }
        else    //center left tiles
        {
            NSUInteger choices[] = {t+1,t+cols,(t+cols)+1, t-cols, (t-cols)+1};
            for(int i=0; i<5; i++){
                [adjacentTiles addObject:[tiles objectAtIndex:choices[i]]];
            }
        }
    }
    else if (col == (cols-1) )  //right col
    {
        if(row ==0) //top right
        {
            NSUInteger choices[] = {t-1,t+cols,(t+cols)-1};
            for(int i=0; i<3; i++){
                [adjacentTiles addObject:[tiles objectAtIndex:choices[i]]];
            }        }
        else if (row == rows-1) //bottom right
        {
            NSUInteger choices[] = {t-1,t-cols,(t-cols)-1};
            for(int i=0; i<3; i++){
                [adjacentTiles addObject:[tiles objectAtIndex:choices[i]]];
            }        }
        else    //center right tiles
        {
            NSUInteger choices[] = {t-1,t+cols,(t+cols)-1, t-cols, (t-cols)-1};
            for(int i=0; i<5; i++){
                [adjacentTiles addObject:[tiles objectAtIndex:choices[i]]];
            }
        }
    }
    else //central columns
    {
        if(row == 0)    //center cols top row
        {
            NSUInteger choices [] = {t-1, t+1, t+cols, (t+cols)-1, (t+cols) +1};
            for(int i=0; i<5; i++){
                [adjacentTiles addObject:[tiles objectAtIndex:choices[i]]];
            }
        }
        else if(row == (rows-1) )    //center cols bottom row
        {
            NSUInteger choices [] = {t-1, t+1, t-cols, (t-cols)-1, (t-cols) +1};
            for(int i=0; i<5; i++){
                [adjacentTiles addObject:[tiles objectAtIndex:choices[i]]];
            }
        }
        else //central tiles
        {
            NSUInteger choices [] = {t-1, t+1, t-cols, t+cols, (t-cols)-1, (t-cols)+1, (t+cols)-1, (t+cols)+1};
            for(int i=0; i<8; i++){
                [adjacentTiles addObject:[tiles objectAtIndex:choices[i]]];
            }
        }
    }
    return (NSArray *)adjacentTiles;
}

-(void) toSelectedTilesAddedTile:(TTTraceGridTile *)tile
{
    [_selectedTilesLayerDelegate colorCenterDotOfTile:tile inLayer:_selectedTilesLayer];
    [_traceLayer setNeedsDisplay];
    [self newTileTouched];      //notifies delegate
}


#pragma mark - UITouch and related methods

-(void)tileEnteredWithTouch:(UITouch *)touch useHotSpot:(BOOL)useHotSpot
{
    //we should only use hot spots on tile other than the first on
    //this enables diagonal swipes to work without picking up adjacent tiles
    //
    CGPoint point = [touch locationInView:self];
    if( activeTile  && CGRectContainsPoint(activeTile.tileFrame,point))
        return;
    else
    {
        NSArray *possibleTiles;
        if(! activeTile){
            possibleTiles = self.tiles;
        }else{
            possibleTiles = activeTile.adjacentTiles;
        }
        dispatch_sync(self.drawTilesQ, ^{
            //have we travelled far enough that we will force the issue of
            //choosing a new active tile? - ( 2*tile diagonal)
            //if tileWidth==TileHeight then 2*width is decisive width
            CGFloat distanceTravelled=0.0;
            TTTraceGridTile * newTile;
            if (activeTile)
            {
                CGFloat deltaX = point.x-activeTile.tileCenter.x;
                CGFloat deltaY = point.y-activeTile.tileCenter.y;
                distanceTravelled = sqrt(deltaX*deltaX+ deltaY*deltaY);
            }
            if(distanceTravelled < kDecisiveDistance)
            {
                for(TTTraceGridTile*tile in possibleTiles)
                {
                    CGRect r = useHotSpot==NO ? r=tile.tileFrame : tile.hotSpot;
                    if( CGRectContainsPoint(r,point)){
                        newTile = tile;
                        break;
                    }
                }
            }
            else//we have travelled too far not to select a new active tile
                //(distanceTravelled>=kDecisiveDistance)
            {
                TTMoveDirection moveDirection = [self directionTravelledFromPoint:activeTile.tileCenter toPoint:point];
                newTile = [self adjacentTileToTile:activeTile inDirection:moveDirection];
            }
            if(newTile) //if no new tile the we are off the grid
            {
                self.activeTile = newTile;
                if( ! [self.selectedTiles containsTile:activeTile])
                {
                    [self.selectedTiles addTile:activeTile];
                }
                dispatch_async(dispatch_get_main_queue(),^{
                    [self toSelectedTilesAddedTile:activeTile];
                });
            }
        });
    }
}

-(TTTraceGridTile *) adjacentTileToTile:(TTTraceGridTile*)tile inDirection:(TTMoveDirection)direction
{
    TTTraceGridTile *adjacentTile=nil;
    for(TTTraceGridTile*t in tile.adjacentTiles)
    {
        switch (direction)
        {
            case TTMoveDirectionRight:
                if(t.tileCenter.x == (tile.tileCenter.x + _tileWidth) &&
                   t.tileCenter.y == tile.tileCenter.y)
                {
                    adjacentTile =t;
                }
                break;
                
            case TTMoveDirectionLeft:
                if(t.tileCenter.x == (tile.tileCenter.x - _tileWidth) &&
                   t.tileCenter.y == tile.tileCenter.y)
                {
                    adjacentTile =t;
                }
                break;
                
            case TTMoveDirectionDown:
                if(t.tileCenter.y == (tile.tileCenter.y + _tileHeight) &&
                   t.tileCenter.x == tile.tileCenter.x)
                {
                    adjacentTile =t;
                }
                break;
                
            case TTMoveDirectionUp:
                if(t.tileCenter.y == (tile.tileCenter.y - _tileHeight) &&
                   t.tileCenter.x == tile.tileCenter.x)
                {
                    adjacentTile =t;
                }
                break;
                
            case TTMoveDirectionRightUp:
                if(t.tileCenter.x == (tile.tileCenter.x + _tileWidth) &&
                   t.tileCenter.y == tile.tileCenter.y + _tileHeight)
                {
                    adjacentTile =t;
                }
                break;
                
            case TTMoveDirectionRightDown:
                if(t.tileCenter.x == (tile.tileCenter.x + _tileWidth) &&
                   t.tileCenter.y == tile.tileCenter.y - _tileHeight)
                {
                    adjacentTile =t;
                }
                break;
                
            case TTMoveDirectionLeftUp:
                if(t.tileCenter.x == (tile.tileCenter.x - _tileWidth) &&
                   t.tileCenter.y == tile.tileCenter.y + _tileHeight)
                {
                    adjacentTile =t;
                }
                break;
                
            case TTMoveDirectionLeftDown:
                if(t.tileCenter.x == (tile.tileCenter.x - _tileWidth) &&
                   t.tileCenter.y == tile.tileCenter.y - _tileHeight)
                {
                    adjacentTile =t;
                }
                break;
                
            default:
                break;
        }
        if(adjacentTile)
            break;
    }
    return adjacentTile;
}

-(TTMoveDirection) directionTravelledFromPoint:(CGPoint)startPt toPoint:(CGPoint)endPt
{
    //is start or end point off the grid
    startPt = [self nearestPointOnGridToPoint:startPt];
    endPt = [self nearestPointOnGridToPoint:endPt];
    TTMoveDirection direction;
    CGFloat deltaX = endPt.x-startPt.x;
    CGFloat deltaY = endPt.y-startPt.y;
    if(fabs(deltaX) > 2*(fabs(deltaY))) //horizontal
    {
        if(deltaX > 0)
            direction = TTMoveDirectionRight;
        else//deltaX<=0
            direction = TTMoveDirectionLeft;
    }
    else if(fabs(deltaY) > 2*(fabs(deltaX))) //vertical
    {
        if(deltaY > 0)
            direction = TTMoveDirectionDown;
        else//deltaY<=0
            direction = TTMoveDirectionUp;
    }
    else //diagonal
    {
        if(deltaX > 0)
        {
            if(deltaY>0)
                direction = TTMoveDirectionRightUp;
            else//deltaY <= 0
                direction = TTMoveDirectionRightDown;
        }
        else //deltaX <=0
        {
            if(deltaY>0)
                direction = TTMoveDirectionLeftUp;
            else//deltaY <= 0
                direction = TTMoveDirectionLeftDown;
        }
    }
    
    return direction;
}

-(CGPoint) nearestPointOnGridToPoint:(CGPoint)pt
{
    CGRect r = self.bounds;
    if( ! CGRectContainsPoint(self.bounds, pt))
    {
        pt.x = pt.x<CGRectGetMinX(r) ? CGRectGetMinX(r) : pt.x;
        pt.x = pt.x>CGRectGetMaxX(r) ? CGRectGetMaxX(r) : pt.x;
        pt.y = pt.y<CGRectGetMinY(r) ? CGRectGetMinY(r) : pt.y;
        pt.y = pt.y>CGRectGetMaxY(r) ? CGRectGetMaxY(r) : pt.y;
    }
    return pt;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(animationTimer)
        [animationTimer invalidate];
    [self resetTracePathWithAnimation:NO];
    
    NSSet *ourTouches = [event touchesForView:self];
    if([ourTouches count])
    {
        UITouch *touch = [ourTouches anyObject];
        _currentLocation = [touch locationInView:self];
        if(selectedTiles)
            [selectedTiles removeAllTiles];
        activeTile=nil;
        
        //find the tile rect we are in
        [self tileEnteredWithTouch:touch useHotSpot:NO];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _circleLayer.position = _currentLocation;
        _circleLayer.hidden = NO;
        _circleLayer.opacity = 1;
        [CATransaction commit];
    }
    else{
        [super touchesBegan:touches withEvent:event];
    }
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    _currentLocation = [touch locationInView:self];\
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self tileEnteredWithTouch:touch useHotSpot:YES];
    _circleLayer.position = _currentLocation;
    [CATransaction commit];
    
}



- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *ourTouches = [event touchesForView:self];
    if([ourTouches count]){
        _circleLayer.opacity = 0.0;
        [self didFinishTrace];
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}



#pragma mark - call delegate methods

-(void) newTileTouched
{
    if([delegate respondsToSelector:@selector(traceGridViewNewTileEntered:)])
    {
        [delegate traceGridViewNewTileEntered:self];
    }
}

-(void) didFinishTrace
{
    if([delegate respondsToSelector:@selector(traceGridViewDidFinishTrace:)]){
        [delegate traceGridViewDidFinishTrace:self];
    }
}

-(void)didResetTracePath
{
    if([delegate respondsToSelector:@selector(traceGridViewDidClearTraceGrid:)])
    {
        [delegate didClearTraceGrid:self];
    }
}


@end
