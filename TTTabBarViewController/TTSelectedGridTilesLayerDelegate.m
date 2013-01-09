//
//  TTSelectedGridTilesLayerDelegate.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "TTSelectedGridTilesLayerDelegate.h"
#import "TTTraceGridTile.h"
#import "CoreGraphicsFunctions.m"
#import "TTTraceGridView.h"
#import "TTSelectedTiles.h"

@interface TTSelectedGridTilesLayerDelegate()
{
    dispatch_queue_t drawTilesQ;       //serial queue for drawing selected tiles
    UIImage *dotImage;
}
-(void) displayImage:(UIImage*) image inLayer:(CALayer *)layer;
-(UIImage *) makeDotImage;

@end

@implementation TTSelectedGridTilesLayerDelegate



-(id) initWithTraceGridView:(TTTraceGridView *)gridView
               circleRadius:(CGFloat)radius
                 outerColor:(UIColor *)outerCol
                 pointColor:(UIColor *)pointCol
{
    if(self = [super init])
    {
        _gridView = gridView;
        // _tiles = gridView.selectedTiles;
        _outerColor = outerCol;
        _pointColor = pointCol;
        _radius = radius;
        dotImage = [self makeDotImage];
    }
    return self;
}


#pragma mark - accessors

-(dispatch_queue_t) drawTilesQ
{
    if(! drawTilesQ)
    {
        drawTilesQ = dispatch_queue_create("com.tsquaredapps.drawTilesDelegateQueue", DISPATCH_QUEUE_SERIAL);
    }
    return drawTilesQ;
}

-(void) setDrawTilesQ:(dispatch_queue_t) queue
{
        drawTilesQ = queue;
}

-(UIImage *) makeDotImage
{
    UIGraphicsBeginImageContext(CGSizeMake(2*_radius, 2*_radius));
    CGContextRef context = UIGraphicsGetCurrentContext();
    fillCircleWithRadialGradient (context,
                                  CGPointMake(_radius,_radius),
                                  _radius,
                                  _outerColor,
                                  _pointColor,
                                  TTRadialGradientFocalPointUpperLeft);
    return UIGraphicsGetImageFromCurrentImageContext();
}


- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    CGContextSaveGState(context);
    
    dispatch_async(self.drawTilesQ,^{
        UIGraphicsBeginImageContext(_gridView.bounds.size);
        @synchronized(_gridView.selectedTiles.tiles)
        {
            for(TTTraceGridTile *tile in _gridView.selectedTiles.tiles)
            {
                fillCircleWithRadialGradient (UIGraphicsGetCurrentContext(),
                                              [tile tileCenter],
                                              _radius,
                                              _outerColor,
                                              _pointColor,
                                              TTRadialGradientFocalPointUpperLeft);
            }
        }
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        dispatch_async(dispatch_get_main_queue(),^{
            [self displayImage:img inLayer:layer];      //displays the image
        });
        
        UIGraphicsEndImageContext();
    });
    CGContextRestoreGState(context);
    
    [CATransaction commit];
}


-(void) colorCenterDotOfTile:(TTTraceGridTile *)tile inLayer:(CALayer *)layer
{
    CALayer *dotLayer = [CALayer layer];
    dotLayer.frame = CGRectMake(tile.tileCenter.x -_radius,
                                tile.tileCenter.y - _radius,
                                2*_radius,
                                2*_radius);
    [self displayImage:dotImage inLayer:dotLayer];
    [layer addSublayer:dotLayer];
}

-(void) displayImage:(UIImage*) image inLayer:(CALayer *)layer
{
    layer.contents = (__bridge id)[image CGImage];
}

@end
