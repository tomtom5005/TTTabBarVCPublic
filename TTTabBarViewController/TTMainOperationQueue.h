//
//  TTMainOperationQueue.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/13/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTMainOperationQueue : NSObject

@property (nonatomic, strong) NSOperationQueue *queue;

+ (TTMainOperationQueue *) sharedInstance;

@end
