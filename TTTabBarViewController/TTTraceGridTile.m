//
//  TTTraceGridTile.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/2/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "TTTraceGridTile.h"

@implementation TTTraceGridTile

@synthesize tileFrame;
@synthesize tileNumber=_tileNumber;
@synthesize adjacentTiles = _adjacentTiles;

-(id) initWithFrame:(CGRect)rect tileNumber:(NSInteger)number
{
    if(self = [super init])
    {
        tileFrame = rect;
        _tileNumber = number;
    }
    return self;
}

-(CGRect) hotSpot
{
    return CGRectInset(tileFrame,
                       tileFrame.size.width/4,
                       tileFrame.size.height/4);
}

-(CGPoint) tileCenter
{
    return CGPointMake(CGRectGetMidX(tileFrame), CGRectGetMidY(tileFrame));
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"Tile #: %d",self.tileNumber];
}
@end