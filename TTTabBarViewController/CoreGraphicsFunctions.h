//
//  CoreGraphicsFunctions.h
//
//  Created by Thomas Thompson on 10/29/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {TTGradientDirectionLeftToRight,
    TTGradientDirectionBottomToTop} TTGradientDirection;

typedef enum {TTRectHalfLeft,
    TTRectHalfRight,
    TTRectHalfBottom,
    TTRectHalfTop} TTRectHalf;

typedef enum {TTRadialGradientFocalPointCenterLeft,
    TTRadialGradientFocalPointUpperLeft,
    TTRadialGradientFocalPointUpperCenter,
    TTRadialGradientFocalPointUpperRight,
    TTRadialGradientFocalPointCenterRight,
    TTRadialGradientFocalPointLowerRight,
    TTRadialGradientFocalPointLowerCenter,
    TTRadialGradientFocalPointLowerLeft,
    TTRadialGradientFocalPointCenter} TTRadialGradientFocalPoint;

//round the  corners of rectangle using radius expressed in radians
CGMutablePathRef roundCornersOfRect(CGRect rect, CGFloat radius);

//fill rect with linear gradient even shading from start Color to endColor in the specified direction

void fillRectWithGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor, TTGradientDirection gradientDirection);

//Add a sheen on the half of the rect specified (TTRectHalf)

void addSheenToRect(CGContextRef context, CGRect rect, TTRectHalf sheenSide);

//fill rect with linear gradient even shading from start Color to endColor in the specified direction
//and add a sheen on the half of the rect specified (TTRectHalf)

void fillRectWithGradientAndAddSheen(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor, TTGradientDirection gradientDirection, TTRectHalf sheenSide);

//fill the circle  with a radial gradient
//from the perimeter color to the point color
//the point is the focal point defined by the TTRadialGradientFocalPoint value
//
void fillCircleWithRadialGradient (CGContextRef context, CGPoint center, CGFloat radius, UIColor *outerColor, UIColor *pointColor, TTRadialGradientFocalPoint focus);

static inline double radians (double degrees) { return degrees * M_PI/180; }