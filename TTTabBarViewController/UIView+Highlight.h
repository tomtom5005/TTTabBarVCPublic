//
//  UIView+Highlight.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/5/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

@interface UIView (Highlight)

@property (nonatomic, readonly) CALayer* highlightLayer;

-(void) showHighlightWithRadius:(CGFloat)radius;
-(CALayer *)createHighlightLayerWithRadius:(CGFloat)r;
-(void) hideHighlight;

@end
