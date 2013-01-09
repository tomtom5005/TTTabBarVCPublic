//
//  TTTraceLayerDelegate.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//


#import "TTTraceLayerDelegate.h"
#import "TTTraceGridView.h"
#import "TTTraceGridTile.h"
#import "TTSelectedTiles.h"

@interface TTTraceLayerDelegate()
{
    dispatch_queue_t drawingQ;       //serial queue for drawing trace pattern
}
-(void) addImageLayer:(CALayer *)imgLayer toLayer:(CALayer *)layer;
@end

@implementation TTTraceLayerDelegate


-(id) initWithTraceGridView:(TTTraceGridView*)view
{
    if(self = [super init])
    {
        _traceView = view;
    }
    return self;
}

#pragma mark - accessors

-(dispatch_queue_t) drawingQ
{
    if(! drawingQ)
    {
        drawingQ = dispatch_queue_create("com.tsquaredapps.traceDrawingDelegateQueue", DISPATCH_QUEUE_SERIAL);
    }
    return drawingQ;
}

-(void) setDrawingQ:(dispatch_queue_t) queue
{
       drawingQ = queue;
}

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    //this should only be called if the tile has just been entered
    if([_traceView.selectedTiles count] > 0)
    {
        CALayer __block *imgLayer = [CALayer layer];
        dispatch_sync(self.drawingQ,^{
            CGContextSaveGState(context);
            
            UIGraphicsBeginImageContext(_traceView.bounds.size);
            
            if(!_traceView.tracePath)
            {
                _traceView.tracePath = [UIBezierPath bezierPath];
            }
            CGContextSetLineWidth(context, kTracePathWidth);
            CGContextSetStrokeColorWithColor(context,
                                             [UIColor lightGrayColor].CGColor);
            if([_traceView.selectedTiles count] ==1)
            {
                TTTraceGridTile *tile = [_traceView.selectedTiles tileAtIndex:0];
                [_traceView.tracePath moveToPoint:tile.tileCenter];
            }
            else
            {
                TTTraceGridTile *tile = _traceView.activeTile;
                [_traceView.tracePath addLineToPoint:tile.tileCenter];
            }
            CGContextAddPath(context, _traceView.tracePath.CGPath);
            CGContextStrokePath(context);
            UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
            imgLayer.contents = (__bridge id)([img CGImage]);
            dispatch_async(dispatch_get_main_queue(),^{
                [self addImageLayer:imgLayer toLayer:layer];      //displays the image
            });
            UIGraphicsEndImageContext();
            
            CGContextRestoreGState(context);
        });
    }
    [CATransaction commit];
}

-(void) addImageLayer:(CALayer *)imgLayer toLayer:(CALayer *)layer
{
    //layer id the traceView's traceLayer
    if([[layer sublayers]count]>0){
        CALayer *oldLayer = [[layer sublayers] objectAtIndex:([[layer sublayers]count]-1)];
        [layer replaceSublayer:oldLayer with:imgLayer];
    }
    else{
        [layer addSublayer:imgLayer];
    }
}
@end

