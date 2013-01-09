//
//  TTRoundedTextView.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/2/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface TTRoundedTextView : UIView

#define kInset 6.0
@property (nonatomic, strong) UITextField *textField;

-(id)initWithTextField:(UITextField *)field;

//designated init
-(id)initWithTextField:(UITextField *)field inset:(CGFloat)inset;

@end
