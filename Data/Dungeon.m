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
	assert (x < kMapDimension);
	assert (y < kMapDimension);
	assert (z < kMapDepth);

	
	return nil;
}

#pragma mark --public

- (Dungeon*) initWithType: (levelType) lvlType {
	if (!tiles) {
		tiles = [[NSMutableArray alloc] initWithCapacity: kMapDimension * kMapDimension * kMapDepth];
		for (int LCV = 0; LCV < kMapDimension * kMapDimension * kMapDepth; LCV++) {
			[tiles addObject: [[Tile alloc] init]];
		}
	}

	[LevelGen make: self intoType: lvlType];
	return self;
}

- (Tile*) tileAtX: (int) x Y: (int) y Z: (int) z {
	assert (x < kMapDimension);
	assert (y < kMapDimension);
	assert (z < kMapDepth);

	int location = x;
	location += y * kMapDimension;
	location += z * kMapDimension * kMapDimension;

	return [tiles objectAtIndex: location];
}

- (Coord*) playerLocation {
	return nil;
}


@end
