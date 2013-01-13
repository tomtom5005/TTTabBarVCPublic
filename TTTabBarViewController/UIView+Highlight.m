//
//  UIView+Highlight.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/5/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import "UIView+Highlight.h"

// Used to identify the associated highlight view
static char *kHighlightKey = "HighlightLayer";

@interface UIView (HighlightPrivateMethod)
-(CALayer *)createHighlightLayerWithRadius:(CGFloat)r;
@end

@implementation UIView (Highlight)

// Get the highlight view attached to this one.
- (CALayer*) highlightLayer {
    return objc_getAssociatedObject(self, kHighlightKey);
}

// Attach a view to this one, which we'll use as the glowing view.
- (void) setHighlightLayer:(CALayer *)highlightLayer {
    objc_setAssociatedObject(self, kHighlightKey, highlightLayer, OBJC_ASSOCIATION_RETAIN);
}


-(void) showHighlightWithColor:(UIColor *)color alpha:(CGFloat)a radius:(CGFloat)radius
{
    // If self is already highlighted were done
    if (! [self highlightLayer])
    {
        //create glow image
        CALayer *glowLayer = [self createHighlightLayerWithRadius:radius];
        [self.layer insertSublayer:glowLayer atIndex:0];
        [self setHighlightLayer:glowLayer];
    }
    self.highlightLayer.hidden=NO;
}

-(void) hideHighlightWithColor:(UIColor *)color alpha:(CGFloat)a radius:(CGFloat)radius
{
    if ([self highlightLayer])
        self.highlightLayer.hidden=YES;
}

-(CALayer *)createHighlightLayerWithRadius:(CGFloat)r
{
    //create glow image
    CALayer *glowLayer = [CALayer layer];
    glowLayer.backgroundColor = [UIColor clearColor].CGColor;
    glowLayer.frame = self.frame;
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.width;
    CGFloat maxRadius = w > h ? w : h;
    r = maxRadius < r ? maxRadius : r;
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *oval = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    CGContextAddPath(ctx,oval.CGPath);
    CGContextClip(ctx);
    CGPoint center = CGPointMake( rint(CGRectGetMidX(self.bounds)), rint(CGRectGetMidX(self.bounds)) );
    NSInteger numLocs = 2;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[2] = {0.0,1.0};
    CGFloat components[] = {1.0, 1.0, 1.0, 0.2,
        1.0, 1.0, 1.0, 0.0};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space,components,locations,numLocs);
    CGColorSpaceRelease(space);
    CGContextDrawRadialGradient(ctx,
                                gradient,
                                center,
                                1.0,
                                center,
                                r,
                                kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradient);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    glowLayer.contents = (__bridge id)[img CGImage];
    return glowLayer;
}

@end
