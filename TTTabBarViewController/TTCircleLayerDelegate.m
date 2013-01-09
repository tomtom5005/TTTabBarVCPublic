//
//  TTCircleLayerDelegate.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "TTCircleLayerDelegate.h"
#import "TTTraceGridTile.h"

@implementation TTCircleLayerDelegate

@synthesize touchCircle = _touchCircle;
@synthesize touchRadius = _touchRadius;
@synthesize tile = _tile;
@synthesize currentLocation = _currentLocation;



-(id) initWithCirclePath:(UIBezierPath *)circle
                  radius:(CGFloat )r
                gridTile:(TTTraceGridTile *)t
           touchLocation:(CGPoint)location
{
    if(self = [super init])
    {
        _tile = t;
        _touchCircle = circle;
        _currentLocation = location;
        _touchRadius = r;
    }
    return self;
}


- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context
{
    if(!_touchCircle)
    {
        _touchCircle = [UIBezierPath bezierPathWithArcCenter:layer.anchorPoint
                                                      radius:_touchRadius
                                                  startAngle:0
                                                    endAngle:2*M_PI
                                                   clockwise:YES];
        
    }
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, kCirclePathWidth);
    CGContextSetStrokeColorWithColor(context,
                                     [UIColor greenColor].CGColor);
    layer.position = _currentLocation;
    CGContextAddPath(context, _touchCircle.CGPath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}
@end

