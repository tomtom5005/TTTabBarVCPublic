//
//  TTPinUtils.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/8/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTPinUtils : NSObject

@property (nonatomic, strong) NSString *PIN;

+ (TTPinUtils *)sharedPinUtils;

@end
