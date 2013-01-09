//
//  TTSelectedGridTilesLayerDelegate.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class TTTraceGridView;
@class TTTraceGridTile;

@interface TTSelectedGridTilesLayerDelegate : NSObject
{
@private
    CGFloat _radius;
    
}

-(id) initWithTraceGridView:(TTTraceGridView *)gridView
               circleRadius:(CGFloat)radius
                 outerColor:(UIColor *)outerCol
                 pointColor:(UIColor *)pointCol;

//@property (strong, nonatomic) NSArray *tiles;
@property (strong, nonatomic) UIColor *outerColor;
@property (strong, nonatomic) UIColor *pointColor;
@property (weak, nonatomic) TTTraceGridView *gridView;

-(void) colorCenterDotOfTile:(TTTraceGridTile *)tile inLayer:(CALayer *)layer;

@end
