//
//  TTSelectedTiles.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TTTraceGridTile;

@interface TTSelectedTiles : NSObject

@property (nonatomic, strong) NSMutableArray *tiles;

-(id)initWithCapacity:(NSUInteger)capacity;
-(void) removeAllTiles;
-(void) addTile:(TTTraceGridTile *)tile;
-(BOOL) containsTile:(TTTraceGridTile *)tile;
-(NSUInteger) count;
-(TTTraceGridTile *) tileAtIndex:(NSUInteger)index;

@end
