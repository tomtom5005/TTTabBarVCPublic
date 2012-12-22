//
//  TTColorPatchView.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/9/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import "TTColorPatchView.h"

@implementation TTColorPatchView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame color:nil];
}


- (id)initWithFrame:(CGRect)frame color:(UIColor*)c
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _fillColor = c;
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
   
    CGContextSaveGState(context);
  
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 8.0, 8.0)
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(18,18)];

    CGContextSetShadowWithColor(context, CGSizeMake(4,4), 4.0, [UIColor colorWithWhite:0 alpha:.5].CGColor);
    [_fillColor setFill];
    [path fill];

        
    CGContextRestoreGState(context);
}


@end
