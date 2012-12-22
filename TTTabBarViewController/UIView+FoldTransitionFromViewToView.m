//
//  UIView+FoldTransitionFromViewToView.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/18/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import "UIView+FoldTransitionFromViewToView.h"
#import "UIView+CreateLayerImage.h"
#import "UIImage+TopAndBottomHalfImages.h"
#import "CALayer+LayerWithImage.h"

@implementation UIView (FoldTransitionFromViewToView)


+ (void)foldTransitionFromView:(UIView *)fromView
                        toView:(UIView*)toView
                     direction:(TTFoldTransitionDirection)direction
                      duration:(NSTimeInterval)duration
                    completion:(void (^)(void))completion
{
    UIView *superView = [fromView superview];
    toView.center = fromView.center;
    CALayer *superLayer = [superView layer];
    CATransformLayer *transformLayer = [CATransformLayer layer];
    transformLayer.frame = superLayer.bounds;
    [superLayer addSublayer:transformLayer];
    CATransform3D initialTransform = transformLayer.sublayerTransform;
	initialTransform.m34 = -1.0 /kPerspectiveZ;
	transformLayer.sublayerTransform = initialTransform;
    
/*
    CGRect superTopRect = CGRectMake(0, 0,
                                superLayer.bounds.size.width,
                                CGRectGetMidY(superLayer.bounds));
    CGRect superBottomRect = CGRectMake(0,superTopRect.size.height,
                                   superLayer.bounds.size.width,
                                   superLayer.bounds.size.height - superTopRect.size.height);
 */
   
    //create image layers
    UIImage *fromImg = [fromView createLayerImage];
    UIImage *toImg = [toView createLayerImage];
    UIImage *fromTopImg = [fromImg topHalfImage];
    UIImage *fromBottomImg = [fromImg bottomHalfImage];
    UIImage *toTopImg = [toImg topHalfImage];
    //UIImageView *iv = [[UIImageView alloc] initWithImage:toTopImg];
    //[fromView addSubview:iv];
    UIImage *toBottomImg = [toImg bottomHalfImage];
    
    CGPoint topAnchorPt = CGPointMake(0.5,0.0);
    CGPoint bottomAnchorPt = CGPointMake(0.5,1.0);
    
    CALayer *fromTopLayer = [CALayer layerWithImage:fromTopImg];
    CALayer *toTopLayer = [CALayer layerWithImage:toTopImg];
    CALayer *toBottomLayer = [CALayer layerWithImage:toBottomImg];
    CALayer *fromBottomLayer = [CALayer layerWithImage:fromBottomImg];
    CATransformLayer *flipLayer = [CATransformLayer layer];
    CGPoint topCenter = CGPointMake(CGRectGetMidX(fromTopLayer.bounds), CGRectGetMidY(fromTopLayer.bounds));
    CGPoint bottomCenter = CGPointMake(topCenter.x, topCenter.y+ fromView.bounds.size.height/2);
    
    CAKeyframeAnimation *foldAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    foldAnimation.duration = duration;
    foldAnimation.valueFunction = [CAValueFunction functionWithName:kCAValueFunctionRotateX];

    if(direction == TTFoldTransitionDirectionUp)
    {
        flipLayer.bounds = fromBottomLayer.bounds;
        flipLayer.anchorPoint = topAnchorPt;
        flipLayer.position = fromView.center;
        toTopLayer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);
        
        [flipLayer addSublayer:toTopLayer];
        [flipLayer addSublayer:fromBottomLayer];
        fromBottomLayer.zPosition =1;
        
        fromTopLayer.position = topCenter;
        toBottomLayer.position = bottomCenter;
        
        [transformLayer addSublayer:fromTopLayer];
        [transformLayer addSublayer:toBottomLayer];
        [transformLayer addSublayer:flipLayer];
        
        
        flipLayer.transform = CATransform3DMakeRotation(M_PI, 1.0f, 0.0f, 0.0f);
        foldAnimation.values = @[@0,[NSNumber numberWithFloat:M_PI]];
    }
    else    //TTFoldTransitionDirectionDown
    {
        flipLayer.bounds = fromTopLayer.bounds;
        flipLayer.anchorPoint = bottomAnchorPt;
        flipLayer.position = fromView.center;
        toBottomLayer.transform = CATransform3DMakeRotation(M_PI, 0.0f, 0.0f, 1.0f);

        [flipLayer addSublayer:toBottomLayer];
        [flipLayer addSublayer:fromTopLayer];
        fromTopLayer.zPosition = 1;
        
        fromBottomLayer.position = bottomCenter;
        toTopLayer.position = topCenter;
        
        [transformLayer addSublayer:fromBottomLayer];
        [transformLayer addSublayer:toTopLayer];
        [transformLayer addSublayer:flipLayer];
        
        flipLayer.transform = CATransform3DMakeRotation(-M_PI, 1.0f, 0.0f, 0.0f);
        foldAnimation.values = @[@0, [NSNumber numberWithFloat:-M_PI]];
    }
    [fromView removeFromSuperview];

    [superLayer addSublayer:transformLayer];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^(void) {
        [transformLayer removeFromSuperlayer];
        [superView addSubview:toView];
        completion();
    }];
    [CATransaction setAnimationDuration:duration];
    [flipLayer addAnimation:foldAnimation forKey:@"transform"];
    [CATransaction commit];
}

@end