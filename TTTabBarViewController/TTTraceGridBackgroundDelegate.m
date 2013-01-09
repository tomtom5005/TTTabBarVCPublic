//
//  TTTraceGridBackgroundDelegate.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//
#import "TTTraceGridBackgroundDelegate.h"
#import "CoreGraphicsFunctions.h"

void MyDrawColoredPattern (void *info, CGContextRef context);

@implementation TTTraceGridBackgroundDelegate

@synthesize cornerRadius;

-(id) initWithCornerRadius:(CGFloat)r
{
    if(self =[super init])
    {
        self.cornerRadius = r;
    }
    return self;
}

#pragma mark - CGPatternCreate callback function

void MyDrawColoredPattern (void *info, CGContextRef context) {
    UIColor *dotColor = [UIColor colorWithHue:0 saturation:0 brightness:0.07 alpha:1.0];
    UIColor *shadowColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
    
    CGContextSetFillColorWithColor(context, dotColor.CGColor);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 1, shadowColor.CGColor);
    
    CGContextAddArc(context, 3, 3, 4, 0, radians(360), 0);
    CGContextFillPath(context);
    
    CGContextAddArc(context, 16, 16, 4, 0, radians(360), 0);
    CGContextFillPath(context);
}


- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    UIColor *bgColor = [UIColor colorWithHue:0 saturation:0 brightness:0.15 alpha:1.0];
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextFillRect(context, layer.bounds);
    
    static const CGPatternCallbacks callbacks = { 0, &MyDrawColoredPattern, NULL };
    
    CGContextSaveGState(context);
    CGColorSpaceRef patternSpace = CGColorSpaceCreatePattern(NULL);
    CGContextSetFillColorSpace(context, patternSpace);
    CGColorSpaceRelease(patternSpace);
    
    CGPatternRef pattern = CGPatternCreate(NULL,
                                           layer.bounds,
                                           CGAffineTransformIdentity,
                                           24,
                                           24,
                                           kCGPatternTilingConstantSpacing,
                                           true,
                                           &callbacks);
    CGFloat alpha = 1.0;
    CGContextSetFillPattern(context, pattern, &alpha);
    CGPatternRelease(pattern);
    CGContextFillRect(context, layer.bounds);
    CGContextRestoreGState(context);
}
@end
