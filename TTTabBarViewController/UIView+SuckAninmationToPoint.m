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
    
    //create path from trashLayer.position to p
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:trashLayer.position];
    TTCurveType curveType = TTCurveTypeBezier;
    BOOL viewContainsPoint = [self pointInside:[self convertPoint:point fromView:toView] withEvent:nil];
    if(viewContainsPoint){
        [path addLineToPoint:p];
    }
    else
    {
        
        //TODO: directions below, left and right
        switch (direction) {
            case TTSuckFromDirectionAbove:
            {
                //calculate a point above p that we can use to create a nice curve to p
                //First insure that deltaX and deltaY are not zero
                CGFloat deltaX = p.x-trashLayer.position.x;
                if(deltaX == 0.0)
                {
                    p = CGPointMake(p.x+.001, p.y);
                    deltaX = .001;
                }
                CGFloat deltaY = p.y-trashLayer.position.y;
                if(deltaY == 0.0)
                {
                    p = CGPointMake(p.x, p.y +.001);
                    deltaY = .001;
                }
               // CGFloat dist = sqrt( (deltaX*deltaX) +(deltaY*deltaY) );
                CGFloat X = fabs(deltaX/2) > kControlPointDeltaX ? kControlPointDeltaX : deltaX/2;
                X = deltaX<0? -X : X;
                CGFloat Y = (fabsf(X) * tan(M_PI_4));
                CGPoint pointAbove = CGPointMake( (p.x - X), (p.y - Y) );
                CGFloat controlPoint1x;
                CGFloat controlPoint2x;
                CGFloat controlPoint1y;
                CGFloat controlPoint2y;
                CGPoint controlPoint1;
                CGPoint controlPoint2;
                
                if(p.y > self.center.y) //point below self center
                {
                    if(trashLayer.position.y + trashLayer.bounds.size.height/2 >p.y)
                    {
                        //then self is roughly parallel to point
                        if(p.x>trashLayer.position.x)//point is right of self
                        {
                            //make control point 1 upper right corner of self frame
                            controlPoint1x = trashLayer.position.x + trashLayer.bounds.size.width/2;
                            controlPoint1y = trashLayer.position.y - trashLayer.bounds.size.height/2;
                        }
                        else
                        {
                            //make control point 1 upper left corner of self frame
                            controlPoint1x = trashLayer.position.x - trashLayer.bounds.size.width/2;
                            controlPoint1y = trashLayer.position.y - trashLayer.bounds.size.height/2;
                        }
                            controlPoint2x =p.x;
                            controlPoint2y = p.y - deltaY/2;
                    }
                    else
                    {
                        curveType = TTCurveTypeQuad;
                        controlPoint1x = trashLayer.position.x + deltaX/2;
                        controlPoint1y = trashLayer.position.y;
                    }
                }
                else    //point above self
                {
                    controlPoint1x = trashLayer.position.x;
                    controlPoint1y = pointAbove.y;
                    controlPoint2x = p.x;
                    controlPoint2y = pointAbove.y - trashLayer.bounds.size.height/2 ;
                }
                controlPoint1 = CGPointMake(controlPoint1x, controlPoint1y);
                if(curveType == TTCurveTypeBezier)
                {
                    controlPoint2 = CGPointMake(controlPoint2x, controlPoint2y);
                    [path addCurveToPoint:p
                            controlPoint1:controlPoint1
                            controlPoint2:controlPoint2];
                }
                else{
                    [path addQuadCurveToPoint:p controlPoint:controlPoint1];
                }

                break;
            }
            case TTSuckFromDirectionBelow:
                break;
            case TTSuckFromDirectionLeft:
                break;
            case TTSuckFromDirectionRight:
                break;
            default:
                break;
        }
    }
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.path = path.CGPath;
    pathAnimation.duration = 0.7f;
    pathAnimation.beginTime = now;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    [trashLayer addAnimation:pathAnimation forKey:@"position"];
    
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D transform2 = CATransform3DMakeScale(0.01f, 0.01f, 1.0f);
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:transform2];
    scaleAnimation.duration = pathAnimation.duration;
    scaleAnimation.beginTime = now;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.removedOnCompletion = NO;
    [trashLayer addAnimation:scaleAnimation forKey:@"transform"];
    
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue = @0.0f;
    opacityAnimation.duration = pathAnimation.duration +0.2;
    opacityAnimation.beginTime = now;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = NO;
    [trashLayer addAnimation:opacityAnimation forKey:@"opacity"];
}


@end
