//
//  UIView+SuckAninmationToPoint.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/19/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "UIView+SuckAninmationToPoint.h"
#import "UIView+CreateLayerImage.h"

@implementation UIView (SuckAninmationToPoint)

//point is a point in the coordinate system of toView

-(void) suckAnimationToPoint:(CGPoint)point
                      inView:(UIView *)toView
                    hideView:(BOOL)hide
             completionBlock:(void(^)(void))completion;
{
    
    __block CALayer *trashLayer = [CALayer layer];
    UIImage *noteImg = [self createLayerImage];
    trashLayer.frame = self.frame;
    trashLayer.contents = (__bridge id)(noteImg.CGImage);
    //UIView *trashView = [[UIView alloc] initWithFrame:self.bounds];
    // trashView.backgroundColor = [UIColor clearColor];
    // trashView.hidden=YES;
    // trashView.userInteractionEnabled=NO;
    //[trashView.layer addSublayer:layer];
    
    //make sure self super view exists
    if(! [self superview])
    {
        UIView *containerView = [[UIView alloc] initWithFrame:self.bounds];
        containerView.backgroundColor = [UIColor clearColor];
        [containerView addSubview:self];
    }
    [[[self superview] layer] addSublayer:trashLayer];
    self.hidden=hide;
        //get point in self super view coordinates
    CGPoint p = [toView convertPoint:point toView:[self superview]];
    //trashLayer.transform = CATransform3DMakeScale(0.05, 0.05, 1.0);
    //trashLayer.opacity = 0.0f;
    //trashLayer.position = p;

    CGFloat animationEndX = p.x;
    CGFloat animationEndY = p.y;;
    [CATransaction setCompletionBlock:^{
        [trashLayer removeFromSuperlayer];
        trashLayer = nil;
        completion();
    }];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path,NULL,trashLayer.position.x,trashLayer.position.y);
    CGPathAddQuadCurveToPoint(path, NULL,
                              trashLayer.position.x,
                              trashLayer.position.y,
                              animationEndX,
                              animationEndY);
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.path = path;
    pathAnimation.duration = .6;
    pathAnimation.beginTime = 0.0;
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D transform2 = CATransform3DMakeScale(0.05, 0.05, 1.0);
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:transform2];
    scaleAnimation.duration = pathAnimation.duration;
    scaleAnimation.beginTime = pathAnimation.beginTime;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue = @0.0;
    opacityAnimation.duration = pathAnimation.duration;
    opacityAnimation.beginTime = pathAnimation.beginTime;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[pathAnimation, scaleAnimation, opacityAnimation];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationGroup.duration=pathAnimation.duration;
    
    //[CATransaction begin];
    [trashLayer addAnimation:animationGroup forKey:@"suckAnimation"];
    //[CATransaction commit];
}


@end
