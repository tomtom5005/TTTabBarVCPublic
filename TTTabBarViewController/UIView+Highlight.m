//
//  UIView+Highlight.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/5/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import "UIView+Highlight.h"

// Used to identify the associated highlight view
static char *HIGHLIGHT_KEY = "HighlightView";

@implementation UIView (Highlight)

// Get the highlight view attached to this one.
- (UIView*) highlightView {
    return objc_getAssociatedObject(self, HIGHLIGHT_KEY);
}

// Attach a view to this one, which we'll use as the glowing view.
- (void) setHighlightView:(UIView*)highlightView {
    objc_setAssociatedObject(self, HIGHLIGHT_KEY, highlightView, OBJC_ASSOCIATION_RETAIN);
}


-(void) showHighlightWithColor:(UIColor *)color alpha:(CGFloat)a
{
    // If self is already highlighted were done
    if (! [self highlightView])
    {
        // The highlight image is taken from the current view's appearance.
        //essentially we make a mono chromatic image photo copy
        // As a side effect, if the view's content, size or shape changes,
        // the highlight won't change its appearance
        //
        UIGraphicsBeginImageContext(self.bounds.size);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGPoint center = CGPointMake( rint(CGRectGetMidX(self.bounds)), rint(CGRectGetMidX(self.bounds)) );
        [path addArcWithCenter:center radius:2.0 startAngle:0 endAngle:2*M_PI clockwise:YES];
        CGContextSetShadowWithColor(ctx, CGSizeMake(self.bounds.size.width/2, self.bounds.size.height/2), 4.0, color.CGColor);
        [color setFill];
        
        //now fill the path with a blend mode that only shows the fill where the there are opaque pixels in the rendered image
        [path fill];
        //[path fillWithBlendMode:kCGBlendModeNormal alpha:a];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();
        
        // Make the highlight view itself, and position it at the same
        // point as self. Overlay it over self.
        UIView* highlightView = [[UIImageView alloc] initWithImage:img];
               /*
        // We don't want to show the image, but rather a shadow created by
        // Core Animation. By setting the shadow to white and the shadow radius to
        // something large, we get a pleasing glow.
        highlightView.alpha = a;
        highlightView.layer.shadowColor = color.CGColor;
        highlightView.layer.shadowOffset = CGSizeZero;
        highlightView.layer.shadowRadius = 10;
        highlightView.layer.shadowOpacity = 1.0;
*/
        [self setHighlightView:highlightView];
    }
    self.highlightView.center = CGPointMake(CGRectGetMidX(self.bounds),CGRectGetMidY(self.bounds)) ;
    [self addSubview:self.highlightView];

}

@end
