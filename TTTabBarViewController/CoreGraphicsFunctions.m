//
//  CoreGraphicsFunctions.m
//  Shareable-Ink
//
//  Created by Thomas Thompson on 10/29/12.
//  Copyright (c) 2012 Shareable Ink. All rights reserved.
//



#import "CoreGraphicsFunctions.h"

CGMutablePathRef roundCornersOfRect(CGRect rect, CGFloat radius) {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect),
                        CGRectGetMaxX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect),
                        CGRectGetMinX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect),
                        CGRectGetMinX(rect), CGRectGetMinY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect),
                        CGRectGetMaxX(rect), CGRectGetMinY(rect), radius);
    CGPathCloseSubpath(path);
    
    return path;
}

void fillRectWithGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor, SIGradientDirection gradientDirection)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = [NSArray arrayWithObjects:(__bridge id)startColor, (__bridge id)endColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGPoint startPoint;
    CGPoint endPoint;
    if (gradientDirection == SIGradientDirectionBottomToTop)
    {
        startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
        endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    }
    else    //left to right gradient (SIGradientDirectionLeftToRight)
    {
        startPoint = CGPointMake(CGRectGetMidY(rect), CGRectGetMinX(rect));
        endPoint = CGPointMake(CGRectGetMidY(rect), CGRectGetMaxX(rect));
    }
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
}


void fillRectWithGradientAndAddSheen(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor, SIGradientDirection gradientDirection, SIRectHalf sheenSide)
{
    fillRectWithGradient(context, rect, startColor, endColor,gradientDirection);
    addSheenToRect(context, rect, sheenSide);
}


void addSheenToRect(CGContextRef context, CGRect rect, SIRectHalf sheenSide)
{
    CGColorRef sheenColor1 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.35].CGColor;
    CGColorRef sheenColor2 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1].CGColor;
    
    CGRect rectHalf;
    SIGradientDirection gradientDirection;
    switch (sheenSide)
    {
        case SIRectHalfLeft:
            rectHalf = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width/2, rect.size.height);
            gradientDirection = SIGradientDirectionLeftToRight;
            break;
            
        case SIRectHalfRight:
        {
            rectHalf = CGRectMake(CGRectGetMidX(rect), rect.origin.y, rect.size.width/2, rect.size.height);
            gradientDirection = SIGradientDirectionLeftToRight;
            //reverse colors
            CGColorRef temp = sheenColor1;
            sheenColor1 = sheenColor2;
            sheenColor2 = temp;
            break;
        }
            
        case SIRectHalfBottom:
        {
            rectHalf = CGRectMake(rect.origin.x, CGRectGetMidY(rect), rect.size.width, rect.size.height/2);
            gradientDirection = SIGradientDirectionBottomToTop;
            //reverse colors
            CGColorRef temp = sheenColor1;
            sheenColor1 = sheenColor2;
            sheenColor2 = temp;
            break;
        }
            
        case SIRectHalfTop:
            rectHalf = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/2);
            gradientDirection = SIGradientDirectionBottomToTop;
            break;
            
        default:
            break;
    }
    
    fillRectWithGradient(context, rectHalf, sheenColor1, sheenColor2, gradientDirection);
    
}


void fillCircleWithRadialGradient (CGContextRef context, CGPoint center, CGFloat radius, UIColor *outerColor, UIColor *pointColor, SIRadialGradientFocalPoint focus)
{
    //CGRect rect = CGRectMake(center.x-radius, center.y-radius, 2*radius, 2*radius);
    CGPoint endPt;
    
    /*
     x = cx + r * cos(a)
     y = cy + r * sin(a)
     */
    switch (focus)
    {
        case SIRadialGradientFocalPointCenterLeft:
            endPt = CGPointMake(center.x-(0.5*radius), center.y);
            break;
            
        case SIRadialGradientFocalPointUpperLeft:
            endPt = CGPointMake(center.x + (0.5*radius)*cos(1.25*M_PI), center.y + (.05*radius*sin(1.25*M_PI)));
            break;
            
        case SIRadialGradientFocalPointUpperCenter:
            endPt = CGPointMake(center.x, center.y+(0.5*radius));
            break;
            
        case SIRadialGradientFocalPointUpperRight:
            endPt = CGPointMake(center.x + (0.5*radius)*cos(1.75*M_PI), center.y + (.05*radius*sin(1.75*M_PI)));
            break;
            
        case SIRadialGradientFocalPointCenterRight:
            endPt = CGPointMake(center.x-(0.5*radius), center.y);
            break;
            
        case SIRadialGradientFocalPointLowerRight:
            endPt = CGPointMake(center.x+(0.5*radius*cos(.25*M_PI)), center.y+(.05*radius*sin(.25*M_PI)));
            break;
            
        case SIRadialGradientFocalPointLowerCenter:
            endPt = CGPointMake(center.x, center.y+(0.5*radius));
            break;
            
        case SIRadialGradientFocalPointLowerLeft:
            CGPointMake(center.x+(0.5*radius*cos(.75*M_PI)), center.y+(.05*radius*sin(.75*M_PI)));
            break;
            
        case SIRadialGradientFocalPointCenter:
            endPt = CGPointMake(center.x, center.y);
            break;
            
        default:
            break;
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = [NSArray arrayWithObjects:(__bridge id)outerColor.CGColor, (__bridge id)pointColor.CGColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGContextSaveGState(context);
    // UIBezierPath *clipPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    // CGContextAddPath(context, clipPath.CGPath);
    //CGContextClipToRect(context, rect);
    CGContextDrawRadialGradient(context, gradient, center, radius, endPt, 0, kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}