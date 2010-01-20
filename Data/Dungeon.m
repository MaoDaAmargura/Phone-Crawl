
#import "Util.h"
#import "Dungeon.h"
#import "LevelGen.h"



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

- (Tile*) tileAtX: (int) x Y: (int) y Z: (int) z 
{
	if (x<0 || y<0 || z<0) 
	{
		NSLog(@"Dungeon.h - tileAtX:Y:Z: Negative Array Index: (%d, %d, %d)", x, y, z);
		return nil;
	}
	if (x >= kMapDimension || y>= kMapDimension || z>kMapDepth)
	{
		NSLog(@"Dungeon.h - tileAtX:Y:Z: Array Index Too Large: (%d, %d, %d) is outside (%d, %d, %d)", x, y, z, kMapDimension, kMapDimension, kMapDepth);
		return nil;
	}

	int location = x;
	location += y * kMapDimension;
	location += z * kMapDimension * kMapDimension;

	return [tiles objectAtIndex: location];
}

- (Coord*) playerLocation {
	return nil;
}


@end
