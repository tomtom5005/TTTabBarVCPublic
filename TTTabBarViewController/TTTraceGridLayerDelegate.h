//
//  TTTraceGridLayerDelegate.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#define kCornerRadius 25.0

typedef struct {
    CGRect tileBounds;
    float maxRadius;
} CallBackInfo;

@interface TTTraceGridLayerDelegate : NSObject

void drawGridPatterns (void *info, CGContextRef context);
-(id) initWithRadius:(CGFloat)radius tileBounds:(CGRect)bounds;

@end
