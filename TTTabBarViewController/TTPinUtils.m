//
//  TTPinUtils.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/8/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "TTPinUtils.h"
#import "TTAppDelegate.h"

static TTPinUtils *sharedPinUtils;

@implementation TTPinUtils


#pragma mark singleton stuff

+(TTPinUtils *) sharedPinUtils
{
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPinUtils = [[TTPinUtils alloc] init];
    });
	return sharedPinUtils;
}


+(id)allocWithZone:(NSZone *)zone
{
	if(!sharedPinUtils)
	{
		sharedPinUtils = [super allocWithZone:zone];
		return sharedPinUtils;
	}
	else
	{
		return nil;
	}
}

-(id) copyWithZone:(NSZone *)zone
{
	return self;
}



@end
