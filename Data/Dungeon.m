
#import "Util.h"
#import "Dungeon.h"
#import "LevelGen.h"
#import "Item.h"

#include <stdio.h>


#pragma mark --hacks

@interface LevelGen ()
+ (Dungeon*) make: (Dungeon*) dungeon intoType: (levelType) lvlType;
@end

#pragma mark -
#pragma mark Dungeon

@interface Dungeon () 
static NSMutableArray *tiles = nil;
@end

@implementation Dungeon

@synthesize playerLocation;
NSMutableDictionary *items;

#pragma mark --private

- (int) indexOfTileAtX: (int) x Y: (int) y Z: (int) z {
	int location = x;
	location += y * MAP_DIMENSION;
	location += z * MAP_DIMENSION * MAP_DIMENSION;

	return location;
}

- (int) indexOfTileAtCoord: (Coord*) coord {
	return [self indexOfTileAtX: coord.X Y: coord.Y Z: coord.Z];
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
		for (int z = 0; z < MAP_DEPTH; z++) {
			for (int y = 0; y < MAP_DIMENSION; y++) {
				for (int x = 0; x < MAP_DIMENSION; x++) {
					Tile *tile = [Tile alloc];
					tile.x = x, tile.y = y, tile.z = z;
					[tiles addObject: tile];
				}
			}
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
//		DLog(@"Dungeon.h - tileAtX:Y:Z: Array Index Too Large: (%d, %d, %d) is outside (%d, %d, %d)", x, y, z, MAP_DIMENSION, MAP_DIMENSION, MAP_DEPTH);
		return nil;
	}

	int index = [self indexOfTileAtX: x Y: y Z: z];

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
