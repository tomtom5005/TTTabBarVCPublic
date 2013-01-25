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


-(void) showHighlightWithRadius:(CGFloat)radius
{
    // If self is already highlighted were done
    if ([self highlightLayer] == nil)// [self highlightLayer] == nil works but  ! [self highlightLayer] does not!!!
    {
        //create glow image
        CALayer *glowLayer = [self createHighlightLayerWithRadius:radius];
        //[self.layer insertSublayer:glowLayer atIndex:0];
        [self.layer addSublayer:glowLayer];
        [self setHighlightLayer:glowLayer];
    }
    self.highlightLayer.hidden=NO;
}

-(void) hideHighlight
{
    if ([self highlightLayer])
        self.highlightLayer.hidden=YES;
}

-(CALayer *)createHighlightLayerWithRadius:(CGFloat)r
{
    //create glow image
    CALayer *glowLayer = [CALayer layer];
    glowLayer.backgroundColor = [UIColor clearColor].CGColor;
    glowLayer.frame = self.bounds;
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat maxRadius = w > h ? w : h;
    r = maxRadius < r ? maxRadius : r;
    
    UIGraphicsBeginImageContext(glowLayer.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    NSInteger numLocs = 2;
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[2] = {0.0,1.0};
    CGFloat components[] = {1.0, 1.0, 1.0, 0.50,
        1.0, 1.0, 1.0, 0.0};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space,components,locations,numLocs);
    CGColorSpaceRelease(space);
    CGContextDrawRadialGradient(ctx,
                                gradient,
                                glowLayer.position,
                                1.0,
                                glowLayer.position,
                                r,
                                kCGGradientDrawsBeforeStartLocation);
    CGGradientRelease(gradient);
      
    UIBezierPath *oval = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
    CGContextAddPath(ctx,oval.CGPath);
    CGContextClip(ctx);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    glowLayer.contents = (__bridge id)[img CGImage];
    UIGraphicsEndImageContext();

    return glowLayer;
}

@end
