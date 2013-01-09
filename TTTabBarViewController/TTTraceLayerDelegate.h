//
//  TTTraceLayerDelegate.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@class TTTraceGridView;

#define kTracePathWidth 4.0

@interface TTTraceLayerDelegate : NSObject
@property (nonatomic, weak) TTTraceGridView *traceView;

-(id) initWithTraceGridView:(TTTraceGridView*)view;

@end

