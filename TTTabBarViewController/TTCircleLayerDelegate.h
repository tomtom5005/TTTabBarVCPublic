//
//  TTCircleLayerDelegate.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#define kCirclePathWidth 4.0
#define kTouchCircleRadius 40

@class  TTTraceGridTile;

@interface TTCircleLayerDelegate : NSObject

@property (nonatomic, strong) UIBezierPath *touchCircle;
@property (assign) CGFloat touchRadius;
@property (nonatomic, strong) TTTraceGridTile *tile;
@property (assign) CGPoint currentLocation;

-(id) initWithCirclePath:(UIBezierPath *)circle
                  radius:(CGFloat )r
                gridTile:(TTTraceGridTile *)t
           touchLocation:(CGPoint)location;
@end
