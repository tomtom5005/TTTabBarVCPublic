//
//  TTMainOperationQueue.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/13/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "TTMainOperationQueue.h"

static TTMainOperationQueue *sharedInstance;

@implementation TTMainOperationQueue

#pragma mark singleton stuff

+(TTMainOperationQueue *) sharedInstance
{
	static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TTMainOperationQueue alloc] init];
        sharedInstance.queue = [[NSOperationQueue alloc] init];
    });
	return sharedInstance;
}


+(id)allocWithZone:(NSZone *)zone
{
	if(!sharedInstance)
	{
		sharedInstance = [super allocWithZone:zone];
		return sharedInstance;
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
