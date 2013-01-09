//
//  TTTraceGridTile.h
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/2/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

@interface TTTraceGridTile : NSObject

@property (assign) NSInteger tileNumber;
@property (assign) CGRect tileFrame;
@property (assign, readonly) CGRect hotSpot;  //inner rect that when entered causes
//the tile to be included in the selectedTiles

@property (strong, nonatomic) NSArray *adjacentTiles;
-(id) initWithFrame:(CGRect)rect tileNumber:(NSInteger)number;
-(CGPoint)tileCenter;

@end
