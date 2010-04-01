
#import "Util.h"
#import "Dungeon.h"
#import "LevelGen.h"
#import "Item.h"
#import "Tile.h"

#include <stdio.h>


#pragma mark --hacks

@interface LevelGen ()
+ (Dungeon*) make: (Dungeon*) dungeon intoType: (levelType) lvlType;
@end


@interface Dungeon (Recreation) 

- (void) resetPlayerStartLocation;

@end

@implementation Dungeon

@synthesize playerStartLocation, liveEnemies, items, dungeonType;

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

		//DLog (@"check your arguments: x %d, y%d, z%d", x,y,z);
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

- (id) init 
{
	if (self = [super init])
	{
		dungeonType = NOT_INITIALIZED;
		self.items = [[[NSMutableDictionary alloc] init] autorelease];
		self.liveEnemies = [[[NSMutableArray alloc] init] autorelease];
		
		tiles = [[NSMutableArray alloc] initWithCapacity: MAP_DIMENSION * MAP_DIMENSION * MAP_DEPTH];
		for (int z = 0; z < MAP_DEPTH; ++z) {
			for (int y = 0; y < MAP_DIMENSION; ++y) {
				for (int x = 0; x < MAP_DIMENSION; ++x) {
					Tile *tile = [[[Tile alloc] init] autorelease];
					tile.x = x, tile.y = y, tile.z = z;
					[tiles addObject: tile];
				}
			}
		}
	}
	return self;
}

- (void) convertToType: (levelType) lvlType 
{
	[items removeAllObjects];	
	[liveEnemies removeAllObjects];
	
	dungeonType = lvlType;

	[LevelGen make: self intoType: lvlType];
	[self resetPlayerStartLocation];
}

- (void) resetPlayerStartLocation
{
	// put the player on the top leftmost square that can take him
	for (int delta = 0;; delta++) {
		for (int x = delta; x >= 0; x--) {
			if (![self tileAtX: x Y: delta - x Z: 0].blockMove) {
				self.playerStartLocation = [Coord withX:x Y:delta-x Z:0];
				if (self.dungeonType != town)
					[[self tileAt: playerStartLocation] convertToType: tileStairsToTown];
				return;
			}			
		}
	}
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

- (Tile*) tileAt: (Coord*) coord 
{
	//NSString *tmp = [coord description];
	assert (tiles);
	//tmp = [NSString stringWithFormat:@"%d",[tiles count]];
	return [self tileAtX: coord.X Y: coord.Y Z: coord.Z];
}

- (int) numberOfLevels
{
	return [tiles count]/(MAP_DIMENSION*MAP_DIMENSION);
}

#pragma mark -
#pragma mark Static

+ (Dungeon*) loadDungeonFromFile:(NSString *)filename
{
	return nil;
}


@end
