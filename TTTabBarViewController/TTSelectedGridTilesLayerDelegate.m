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
    for(TTTraceGridTile *tile in _gridView.selectedTiles.tiles){
        [self colorCenterDotOfTile:tile inLayer:layer];
    }
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
