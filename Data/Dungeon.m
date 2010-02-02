
#import "Util.h"
#import "Dungeon.h"
#import "LevelGen.h"

#include <stdio.h>


#pragma mark --hacks

@interface LevelGen ()
+ (Dungeon*) make: (Dungeon*) dungeon intoType: (levelType) lvlType;
@end

#pragma mark -
#pragma mark Dungeon

@interface Dungeon () 
NSMutableArray *tiles = nil;
@end

@implementation Dungeon

#pragma mark --private

#pragma mark --friend
- (bool) setTile: (Tile*) tile X: (int) x Y: (int) y Z: (int) z {
	return true;
}

- (Tile*) setTileAtX: (int) x Y: (int) y Z: (int) z {
	assert (x < MAP_DIMENSION);
	assert (y < MAP_DIMENSION);
	assert (z < MAP_DEPTH);

	return nil;
}

#pragma mark --public

- (Dungeon*) initWithType: (levelType) lvlType {
	if (!tiles) {
		tiles = [[NSMutableArray alloc] initWithCapacity: MAP_DIMENSION * MAP_DIMENSION * MAP_DEPTH];
		for (int LCV = 0; LCV < MAP_DIMENSION * MAP_DIMENSION * MAP_DEPTH; LCV++) {
			[tiles addObject: [[Tile alloc] init]];
		}
	}

	[LevelGen make: self intoType: lvlType];
	return self;
}

- (Tile*) tileAtX: (int) x Y: (int) y Z: (int) z 
{
	if (x<0 || y<0 || z<0) 
	{
		NSLog(@"Dungeon.h - tileAtX:Y:Z: Negative Array Index: (%d, %d, %d)", x, y, z);
		return nil;
	}
	if (x >= MAP_DIMENSION || y>= MAP_DIMENSION || z > MAP_DEPTH)
	{
		NSLog(@"Dungeon.h - tileAtX:Y:Z: Array Index Too Large: (%d, %d, %d) is outside (%d, %d, %d)", x, y, z, MAP_DIMENSION, MAP_DIMENSION, MAP_DEPTH);
		return nil;
	}

	int location = x;
	location += y * MAP_DIMENSION;
	location += z * MAP_DIMENSION * MAP_DIMENSION;

	return [tiles objectAtIndex: location];
}

- (Coord*) playerLocation {
	return [Coord newCoordWithX: 2 Y: 2 Z: 0];
}


#pragma mark -
#pragma mark Static

+ (Dungeon*) loadDungeonFromFile:(NSString *)filename
{
	return nil;
}


@end
