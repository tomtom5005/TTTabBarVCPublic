//
//  TTRoundedTextView.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/2/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "TTRoundedTextView.h"


@implementation TTRoundedTextView

@synthesize textField=_textField;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        if(!_textField){
            _textField = [[UITextField alloc]initWithFrame:CGRectMake(kInset,0,
                                                                      frame.size.width - 2*kInset,
                                                                      frame.size.height)];
        }
        else
        {
            _textField.frame = CGRectMake(kInset,0,
                                          _textField.frame.size.width,
                                          _textField.frame.size.height);
        }
        self.backgroundColor = [UIColor whiteColor];
        CALayer *layer = self.layer;
        layer.cornerRadius = 8.0f;
        layer.masksToBounds = YES;
        layer.borderWidth = 1.0f;
        layer.borderColor = [UIColor colorWithWhite:0.5f alpha:0.2f].CGColor;
        _textField.backgroundColor = [UIColor clearColor];
        
        UIView *superView = [_textField superview];
        [self addSubview:_textField];
        if(superView)
            [superView addSubview:self];
    }
    return self;
}


-(id)initWithTextField:(UITextField *)field
{
    
    return [self initWithTextField:field inset:kInset];
}

-(id)initWithTextField:(UITextField *)field inset:(CGFloat)inset
{
    _textField = field;
    return [self initWithFrame:CGRectMake(field.frame.origin.x-inset,
                                          field.frame.origin.y,
                                          field.frame.size.width +2*inset,
                                          field.frame.size.height)];
}


@end
