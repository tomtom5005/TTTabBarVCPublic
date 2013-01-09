//
//  UIButton+TTButton.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "UIButton+TTButton.h"

@implementation UIButton (TTButton)

-(void) TTStyleButton
{
    [self setTitleColor: [UIColor colorWithWhite:128.0 / 256.0 alpha:1.0]
               forState: UIControlStateNormal];
    [self setTitleShadowColor: [UIColor whiteColor]
                     forState: UIControlStateNormal];
    self.titleLabel.shadowOffset = CGSizeMake(0.0, 2.0);
    [self setTitleColor: [UIColor colorWithWhite:64.0 / 256.0 alpha:1.0]
               forState: UIControlStateHighlighted];
    [self setTitleShadowColor: [UIColor colorWithWhite:192.0 / 256.0 alpha:1.0]
                     forState: UIControlStateHighlighted];
    
    // Add Border
    CALayer *layer = self.layer;
    layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 1.0f;
    layer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.2f].CGColor;
    
    // Add Shine
    CAGradientLayer *shineLayer = [CAGradientLayer layer];
    shineLayer.geometryFlipped = YES;
    shineLayer.frame = layer.bounds;
    shineLayer.colors = [NSArray arrayWithObjects:
                         (id)[UIColor colorWithWhite:0xca / 256.0 alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:0xd0 / 256.0 alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:0xe1 / 256.0 alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:0xf2 / 256.0 alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:0xfb / 256.0 alpha:1.0f].CGColor,
                         (id)[UIColor colorWithWhite:0x7b / 256.0 alpha:1.0f].CGColor,
                         nil];
    shineLayer.locations = [NSArray arrayWithObjects:
                            [NSNumber numberWithFloat:0.0f],
                            [NSNumber numberWithFloat:0.26f],
                            [NSNumber numberWithFloat:0.50f],
                            [NSNumber numberWithFloat:0.75f],
                            [NSNumber numberWithFloat:0.99f],
                            [NSNumber numberWithFloat:1.0f],
                            nil];
    [layer insertSublayer:shineLayer atIndex:0];
}

@end
