//
//  TTSelectedTiles.m
//  TTTabBarViewController
//
//  Created by Thomas Thompson on 1/3/13.
//  Copyright (c) 2013 Thomas Thompson. All rights reserved.
//

#import "TTSelectedTiles.h"
#import "TTTraceGridTile.h"


@interface TTSelectedTiles ()
{
    dispatch_queue_t updateQueue;
}

-(dispatch_queue_t) updateQueue;
-(void) setUpdateQueue:(dispatch_queue_t) queue;

@end


@implementation TTSelectedTiles

#pragma mark - accessors

-(dispatch_queue_t) updateQueue
{
    if(! updateQueue){
        updateQueue = dispatch_queue_create("com.tsquaredapps.selectedTilesUpdateQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return updateQueue;
}

#pragma mark - SelectedTiles methods

-(id)initWithCapacity:(NSUInteger)capacity
{
    if(self = [super init]){
        _tiles = [[NSMutableArray alloc] initWithCapacity:capacity];
    }
    return self;
}

-(void) setUpdateQueue:(dispatch_queue_t) queue
{
        updateQueue = queue;
}

-(void) addTile:(TTTraceGridTile *)tile
{
    dispatch_barrier_async([self updateQueue], ^{
        [_tiles addObject:tile];
    });
    
}
-(void) removeAllTiles
{
    dispatch_barrier_async([self updateQueue], ^{
        [_tiles removeAllObjects];
    });
    
}
-(BOOL) containsTile:(TTTraceGridTile *)tile
{
    BOOL __block retVal = NO;
    dispatch_sync(self.updateQueue, ^{
        retVal = [_tiles containsObject:tile];
    });
    return retVal;
}


-(NSUInteger) count
{
    __block NSUInteger cnt;
    dispatch_sync(self.updateQueue, ^{
        cnt = [_tiles count];
    });
    return cnt;
}

-(TTTraceGridTile *) tileAtIndex:(NSUInteger)index
{
    TTTraceGridTile __block *tile = nil;
    
    dispatch_sync(self.updateQueue, ^{
        if(index <[_tiles count])
            tile = [_tiles objectAtIndex:index ];
    });
    return tile;
}


//we should create this and not use the @synchronize blocks that I am using
//the is a good article re this at mikeash's blog (in my programming bookmarks)
//http://www.mikeash.com/pyblog/friday-qa-2010-04-16-implementing-fast-enumeration.html
//
//perhaps when we have some more time
/*
 - (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
 */

@end
