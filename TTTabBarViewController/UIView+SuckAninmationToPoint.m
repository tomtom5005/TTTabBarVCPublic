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
               fromDirection:(TTSuckFromDirection)direction
                    hideView:(BOOL)hide
             completionBlock:(void(^)(void))completion;
{
    CFTimeInterval now = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    CALayer *trashLayer = [CALayer layer];
    [CATransaction setCompletionBlock:^{
        [trashLayer removeFromSuperlayer];
        completion();
    }];

    UIImage *noteImg = [self createLayerImage];
    trashLayer.frame = self.frame;
    trashLayer.contents = (__bridge id)(noteImg.CGImage);

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
    UIBezierPath *path;
    if(p.y > self.center.y) //point below
    {
        CGMutablePathRef mPath = CGPathCreateMutable();
        CGPathMoveToPoint(mPath,NULL,trashLayer.position.x,trashLayer.position.y);
        CGPathAddQuadCurveToPoint(mPath, NULL,
                                  trashLayer.position.x,
                                  trashLayer.position.y,
                                  p.x,
                                  p.y);
        path = [UIBezierPath bezierPathWithCGPath:mPath];
        CGPathRelease(mPath);
    }
    else    //point above
    {
        CGFloat deltaX = (p.x-trashLayer.position.x)/2;
        deltaX = deltaX > kControlPointDeltaX ? kControlPointDeltaX : deltaX;
        CGFloat controlPointX = p.x - deltaX;
        CGFloat controlPointY = p.y - 2*(fabsf(deltaX) * tan(M_PI_4)) - .6 *self.bounds.size.height;
        CGPoint controlPoint = CGPointMake(controlPointX, controlPointY);
        path = [UIBezierPath bezierPath];
        [path moveToPoint:trashLayer.position];
        [path addQuadCurveToPoint:p controlPoint:controlPoint];
    }

    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.path = path.CGPath;
    pathAnimation.duration = 0.7f;
    pathAnimation.beginTime = now;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    [trashLayer addAnimation:pathAnimation forKey:@"position"];
    
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D transform2 = CATransform3DMakeScale(0.05f, 0.05f, 1.0f);
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:transform2];
    scaleAnimation.duration = pathAnimation.duration;
    scaleAnimation.beginTime = now;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.removedOnCompletion = NO;
    [trashLayer addAnimation:scaleAnimation forKey:@"transform"];
    
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue = @0.0f;
    opacityAnimation.duration = pathAnimation.duration;
    opacityAnimation.beginTime = now;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = NO;
    [trashLayer addAnimation:opacityAnimation forKey:@"opacity"];
    
}


@end
