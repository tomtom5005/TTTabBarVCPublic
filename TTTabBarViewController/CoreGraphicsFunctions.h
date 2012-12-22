//
//  CoreGraphicsFunctions.h
//  Shareable-Ink
//
//  Created by Thomas Thompson on 10/29/12.
//  Copyright (c) 2012 Shareable Ink. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum {SIGradientDirectionLeftToRight,
    SIGradientDirectionBottomToTop} SIGradientDirection;

typedef enum {SIRectHalfLeft,
    SIRectHalfRight,
    SIRectHalfBottom,
    SIRectHalfTop} SIRectHalf;

typedef enum {SIRadialGradientFocalPointCenterLeft,
    SIRadialGradientFocalPointUpperLeft,
    SIRadialGradientFocalPointUpperCenter,
    SIRadialGradientFocalPointUpperRight,
    SIRadialGradientFocalPointCenterRight,
    SIRadialGradientFocalPointLowerRight,
    SIRadialGradientFocalPointLowerCenter,
    SIRadialGradientFocalPointLowerLeft,
    SIRadialGradientFocalPointCenter} SIRadialGradientFocalPoint;

//round the  corners of rectangle using radius expressed in radians
CGMutablePathRef roundCornersOfRect(CGRect rect, CGFloat radius);

//fill rect with linear gradient even shading from start Color to endColor in the specified direction

void fillRectWithGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor, SIGradientDirection gradientDirection);

//Add a sheen on the half of the rect specified (SIRectHalf)

void addSheenToRect(CGContextRef context, CGRect rect, SIRectHalf sheenSide);

//fill rect with linear gradient even shading from start Color to endColor in the specified direction
//and add a sheen on the half of the rect specified (SIRectHalf)

void fillRectWithGradientAndAddSheen(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor, SIGradientDirection gradientDirection, SIRectHalf sheenSide);

//fill the circle  with a radial gradient
//from the perimeter color to the point color
//the point is the focal point defined by the SIRadialGradientFocalPoint value
//
void fillCircleWithRadialGradient (CGContextRef context, CGPoint center, CGFloat radius, UIColor *outerColor, UIColor *pointColor, SIRadialGradientFocalPoint focus);

static inline double radians (double degrees) { return degrees * M_PI/180; }