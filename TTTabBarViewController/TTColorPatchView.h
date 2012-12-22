//
//  TTColorPatchView.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/9/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTColorPatchView : UIView

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIView *colorPatch;

//designated init
- (id)initWithFrame:(CGRect)frame color:(UIColor*)c;

@end
