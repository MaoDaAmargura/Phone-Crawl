
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

@synthesize playerLocation;
#pragma mark --private

- (int) indexOfTileAtCoord: (Coord*) coord {
	int location = coord.X;
	location += coord.Y * MAP_DIMENSION;
	location += coord.Z * MAP_DIMENSION * MAP_DIMENSION;

	return location;
}

#pragma mark --friend 

- (bool) setTile: (Tile*) tile X: (int) x Y: (int) y Z: (int) z {
	if (x < 0 || x >= MAP_DIMENSION ||
		y < 0 || y >= MAP_DIMENSION ||
		z < 0 || z >= MAP_DEPTH) {

		DLog (@"check your arguments: x %d, y%d, z%d", x,y,z);
		return false;
	}

	int index = [self indexOfTileAtCoord: [Coord withX: x Y: y Z: z]];
	[tiles replaceObjectAtIndex: index withObject: tile];
	return true;
}

- (bool) setTile: (Tile*) tile at: (Coord*) coord {
	return [self setTile: tile X: coord.X Y: coord.Y Z: coord.Z];
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
	playerLocation = [[Coord withX: 2 Y: 2 Z: 0] retain];
	return self;
}

- (Tile*) tileAtX: (int) x Y: (int) y Z: (int) z {
	if (x<0 || y<0 || z<0) {
//		DLog(@"Dungeon.h - tileAtX:Y:Z: Negative Array Index: (%d, %d, %d)", x, y, z);
		return nil;
	}
	if (x >= MAP_DIMENSION || y>= MAP_DIMENSION || z > MAP_DEPTH) {
		DLog(@"Dungeon.h - tileAtX:Y:Z: Array Index Too Large: (%d, %d, %d) is outside (%d, %d, %d)", x, y, z, MAP_DIMENSION, MAP_DIMENSION, MAP_DEPTH);
		return nil;
	}

	int index = [self indexOfTileAtCoord: [Coord withX: x Y: y Z: z]];

	return [tiles objectAtIndex: index];
}

- (Tile*) tileAt: (Coord*) coord {
	return [self tileAtX: coord.X Y: coord.Y Z: coord.Z];
}

#pragma mark -
#pragma mark Static

+ (Dungeon*) loadDungeonFromFile:(NSString *)filename
{
	return nil;
}


@end
