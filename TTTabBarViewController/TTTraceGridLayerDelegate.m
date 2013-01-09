//
//  TTTraceGridLayerDelegate.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "TTTraceGridLayerDelegate.h"
#import "CoreGraphicsFunctions.h"

@interface TTTraceGridLayerDelegate()
{
@private
    CGFloat _maxRadius;
    CGRect _tileBounds;
}

@end



@implementation TTTraceGridLayerDelegate

-(id) initWithRadius:(CGFloat)radius tileBounds:(CGRect)bounds
{
    if(self=[super init])
    {
        _tileBounds = bounds;
        _maxRadius = radius;
    }
    return self;
}

void drawGridPatterns(void *info, CGContextRef context)
{
    CGColorRef bgColor = [UIColor clearColor].CGColor;
    CallBackInfo *callbackInfo = info;
    CGFloat maxRadius = callbackInfo->maxRadius;
    CGRect tileBounds = callbackInfo->tileBounds;
    
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, bgColor);
    CGContextFillRect(context,tileBounds);
    
    UIColor *outerColor = [UIColor colorWithRed:100/255 green:100/255 blue:100/255 alpha:1];
    UIColor *pointColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    
    fillCircleWithRadialGradient (context,
                                  CGPointMake(CGRectGetMidX(tileBounds),
                                              CGRectGetMidY(tileBounds)),
                                  (maxRadius/2.5),
                                  outerColor,
                                  pointColor,
                                  TTRadialGradientFocalPointUpperLeft);
    CGContextRestoreGState(context);
}




- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    //kCornerRadius is defined in TraceGridLayerDelegate
    CGRect rect = layer.bounds;
    UIBezierPath *clipPath  = [UIBezierPath bezierPathWithRoundedRect:rect
                                                         cornerRadius:kCornerRadius];
    CGContextAddPath(context, clipPath.CGPath);
    CGContextClip(context);
    CGContextFillPath(context);
    
    static const CGPatternCallbacks callbacks = { 0, &drawGridPatterns, NULL };
    
    CGContextSaveGState(context);
    CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
    CGContextSetFillColorSpace(context, patternSpace);
    CGColorSpaceRelease(patternSpace);
    
    NSInteger tileWidth = (NSInteger)_tileBounds.size.width;
    NSInteger tileHeight = (NSInteger)_tileBounds.size.height;
    CallBackInfo callBackInfo = { _tileBounds,_maxRadius};
    CGPatternRef pattern = CGPatternCreate(&callBackInfo,
                                           _tileBounds,
                                           CGAffineTransformIdentity,
                                           tileWidth,
                                           tileHeight,
                                           kCGPatternTilingConstantSpacing,
                                           true,
                                           &callbacks);
    CGFloat alpha = 1.0;
    CGContextSetFillPattern(context, pattern, &alpha);
    CGPatternRelease(pattern);
    CGContextFillRect(context, rect);
    CGContextRestoreGState(context);
}

@end
