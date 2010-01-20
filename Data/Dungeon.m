#import "Util.h"
#import "Dungeon.h"
#import "LevelGen.h"

#pragma mark Tile

@implementation Tile
@synthesize blockMove, blockView, sprite;

- (id) init {
	blockMove = false;
	blockView = false;
	sprite = tileNotInitialized;
	return self;
}

@end

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

- (Tile*) tileAtX: (int) x Y: (int) y Z: (int) z {
	assert (x < MAP_DIMENSION);
	assert (y < MAP_DIMENSION);
	assert (z < MAP_DEPTH);

	int location = x;
	location += y * MAP_DIMENSION;
	location += z * MAP_DIMENSION * MAP_DIMENSION;

	return [tiles objectAtIndex: location];
}

- (Coord*) playerLocation {
	return nil;
}


@end
