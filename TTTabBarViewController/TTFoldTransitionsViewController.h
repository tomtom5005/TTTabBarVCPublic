//
//  TTFoldTransitionsViewController.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 12/18/12.
//  Copyright (c) 2012 Thomas Thompson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTFoldTransitionsView.h"

#define kFoldTransitionsViewWidth 320
#define kFoldTransitionsViewHeight 480


@interface TTFoldTransitionsViewController : UIViewController <TTFoldTransitionsViewDataSource>
-(void) setUp;
@end
