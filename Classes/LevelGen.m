#import "Util.h"
#import "Dungeon.h"
#import "LevelGen.h"
#import "Tile.h"
#import "Item.h"

#import "Critter.h"
#import "WarriorCritter.h"
#import "BerserkerCritter.h"
#import "ShadowKnightCritter.h"
#import "RogueCritter.h"
#import "MageCritter.h"
#import "PaladinCritter.h"
#import "NPCCritter.h"

// NPC Dialogs
#import "Priest.h"


#pragma mark --hacks

@interface Dungeon ()
- (bool) setTile: (Tile*) tile X: (int) x Y: (int) y Z: (int) z;
- (bool) setTile: (Tile*) tile at: (Coord*) coord;
@end

extern int placementOrderCountTotalForEntireClassOkayGuysNowThisIsHowYouProgramInObjectiveC;
#define CRYPT_ROOMS_COUNT 4
#define CRYPT_WALL_LENGTH MAP_DIMENSION/CRYPT_ROOMS_COUNT

static tileType deadTile [] = {
//	tileNone, tileGrass, tileConcrete, tileRubble, tileWoodWall,
//	tileWoodDoor, tileWoodFloor, tileWoodDoorOpen, tileWoodDoorSaloon, tileWoodDoorBroken,
//	tilePit, tileSlopeDown, tileSlopeUp, tileRockWall, tileLichen,
//	tileGroundCrumbling, tileStoneCrumbling

	tileNone, tileGrass, tileStoneCrumbling, tileRubble, tileRubble,
	tileWoodDoorBroken, tileRubble, tileWoodDoorBroken, tileWoodDoorBroken, tileWoodFloor,
	tileGroundCrumbling, tileGroundCrumbling, tileRubble, tileStoneCrumbling, tileLichen,
	tileNone, tileConcrete
};

#pragma mark --private methods

@interface LevelGen ()

+ (Dungeon*) makeOrcMines: (Dungeon*) dungeon;
+ (Dungeon*) putBuildings: (Dungeon*) dungeon onZLevel: (int) z;

@end

#pragma mark -

@implementation LevelGen

#pragma mark -
#pragma mark Flood Fill

+ (NSMutableArray*) singleComponent: (Dungeon*) dungeon withClearTiles: (NSMutableArray*) white {
	NSMutableArray *black = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *gray = [[[NSMutableArray alloc] init] autorelease];

	[gray addObject: [white objectAtIndex: 0]];
	[white removeObjectAtIndex: 0];

	NSMutableArray *nextGray = [[[NSMutableArray alloc] init] autorelease];
	while ([gray count]) {
		for (Tile *currTile in gray) {
			
			Tile *nextTile;
			for (int LCV = 0; LCV < 4; LCV++) {
				switch (LCV) {
					case 0:
						nextTile = [dungeon tileAtX: currTile.x - 1 Y: currTile.y Z: currTile.z];
						break;
					case 1:
						nextTile = [dungeon tileAtX: currTile.x + 1 Y: currTile.y Z: currTile.z];
						break;
					case 2:
						nextTile = [dungeon tileAtX: currTile.x Y: currTile.y - 1 Z: currTile.z];
						break;
					case 3:
						nextTile = [dungeon tileAtX: currTile.x Y: currTile.y + 1 Z: currTile.z];
						break;
					default: assert(false);
				}
				if (!nextTile) continue; // invalid x or y index
				if (nextTile.blockMove) continue;
				if (![white containsObject: nextTile]) continue;
//				assert (![gray containsObject: nextTile]); commented out for performance reasons

				[white removeObject: nextTile];
				[nextGray addObject: nextTile];
				[black addObject: nextTile];
			}
			// end LCV loop
		}
		NSMutableArray *swap = gray;
		gray = nextGray;
		nextGray = swap;
		[nextGray removeAllObjects];
	}

	return black;
}

// returns a two dimensional array of all connected components of the Z level it's called on
+ (NSMutableArray*) allConnected: (Dungeon*) dungeon onZLevel: (int) z {
	NSMutableArray *white = [[[NSMutableArray alloc] initWithCapacity: MAP_DIMENSION * MAP_DIMENSION / 2] autorelease];

	for (int x = 0; x < MAP_DIMENSION; x++) {
		for (int y = 0; y < MAP_DIMENSION; y++) {
			Tile *tile = [dungeon tileAtX: x Y: y Z: z];
			if (!tile.blockMove) [white addObject: tile];
		}
	}
	assert ([white count]);

	NSMutableArray *twoDimens = [[[NSMutableArray alloc] init] autorelease];
	while ([white count]) {
		NSMutableArray *connected = [self singleComponent: dungeon withClearTiles: white];
		if ([connected count]) [twoDimens addObject: connected];
//		else DLog(@"bug in flood fill?");
	}

	return twoDimens;
}

+ (void) bomb: (Dungeon*) dungeon targeting: (NSMutableArray*) targets tightly: (bool) tight towardsCenter: (bool) directed {
//	DLog(@"max %d", [targets count] - 1);
	Tile *target = [targets objectAtIndex: [Rand min: 0 max: [targets count] - 1]];

//	int height = [Rand min: 3 max: 9];
//	int width = 12 - height;

//	int xRange = tight?  FIXME
	#define BOMB_SIZE 6
	int xBegin = target.x + [Rand min: -BOMB_SIZE max: BOMB_SIZE];
	int yBegin = target.y + [Rand min: -BOMB_SIZE max: BOMB_SIZE];

	for (int x = xBegin - BOMB_SIZE; x <= xBegin + BOMB_SIZE; x++) {
		for (int y = yBegin - BOMB_SIZE; y <= yBegin + BOMB_SIZE; y++) {
			Tile *curr = [dungeon tileAtX: x Y: y Z: target.z];
			if (curr) [curr convertToType: tileConcrete];
		}
	}
}


#pragma mark -
#pragma mark Game of Life

typedef enum {
	agentOrange, average, fecund
} golParam;

+ (int) golCountNeighborsIn: (Dungeon*) dungeon ofType: (tileType) type around: (Coord*) coord {
	int neighbors = 0;
	for (int dx = -1; dx <= 1; dx++) {
		if (coord.X + dx < 1 || coord.X + dx >= MAP_DIMENSION - 1) continue;
		for (int dy = -1; dy <= 1; dy++) {
			if (coord.Y + dy < 1 || coord.Y + dy >= MAP_DIMENSION - 1) continue;
			if (dy == 0 && dx == 0) continue;
			if ([dungeon tileAtX:coord.X + dx Y: coord.Y + dy Z: coord.Z].type == type) {
				neighbors++;
			}
		}
	}
	return neighbors;
}

+ (bool) killWithNeighbors:(int) neighbors harshness: (golParam) harshness {
	if (neighbors == 8) {
		return false;
	}

	switch (harshness) {
		case agentOrange:
			if (neighbors < 3) {
				return true;
			}
			return false;
		case average:
			if (neighbors < 2 || neighbors > 3) {
				return true;
			}
			return false;
		case fecund:
			if (neighbors < 1 || neighbors > 4) {
				return true;
			}
			return false;
		default:
			[NSException raise:@"Game of Life blew up in switch statement A" format: nil];
	}
	exit(1);
}

+ (bool) birthWithNeighbors:(int) neighbors harshness: (golParam) harshness {
	if (harshness == agentOrange) return false;

	switch (harshness) {
		case average:
			if (neighbors == 3) {
				return true;
			}
			return false;
		case fecund:
			if (neighbors < 2 || neighbors > 3) {
				return true;
			}
			return false;
		default:
			[NSException raise:@"Game of Life blew up in switch statement B" format: nil];
	}
	exit(1);
}

+ (void) gameOfLife: (Dungeon*) dungeon zLevel: (int) z targeting: (tileType) type harshness: (golParam) harshness {
	// declared outside loop to avoid a fat autorelease pool
	Coord *coord = [Coord withX:0 Y:0 Z:z];
	NSMutableSet *tilesToKill = [[[NSMutableSet alloc] initWithCapacity: 120] autorelease];
	NSMutableSet *tilesToBirth = [[[NSMutableSet alloc] initWithCapacity: 120] autorelease];

	for (int x = 0; x < MAP_DIMENSION; x++) {
		for (int y = 0; y < MAP_DIMENSION; y++) {
			coord.X = x, coord.Y = y;
			int neighbors = [self golCountNeighborsIn:dungeon ofType:type around:coord];

			if ([dungeon tileAt:coord].type == type && [self killWithNeighbors:neighbors harshness:harshness]) {
				[tilesToKill addObject: [dungeon tileAt: coord]];
				continue;
			}

			else if ([dungeon tileAt:coord].type != type && [self birthWithNeighbors:neighbors harshness:harshness]) {
				[tilesToBirth addObject: [dungeon tileAt: coord]];
			}
		}
	}

	//DLog(@"%d",[tilesToKill count]);
	//DLog(@"%d",[tilesToBirth count]);

	for (Tile *tile in tilesToKill) {
		[tile convertToType: deadTile[type]];
	}
	for (Tile *tile in tilesToBirth) {
		[tile convertToType: type];
	}
	
}

#pragma mark -

#define MAX_PIT_RADIUS 10
+ (void) putPit: (Dungeon*) dungeon onZLevel: (int) z {
	assert(z < MAP_DEPTH - 1);

	while (true) {

		int xStart = [Rand min: MAX_PIT_RADIUS max: MAP_DIMENSION - 1 - MAX_PIT_RADIUS];
		int yStart = [Rand min: MAX_PIT_RADIUS max: MAP_DIMENSION - 1 - MAX_PIT_RADIUS];

		if ([dungeon tileAtX:xStart Y:yStart Z:z].type == tileRockWall) {
			continue;
		}

		for (int x = xStart - MAX_PIT_RADIUS; x < xStart + MAX_PIT_RADIUS; x++) {
			for (int y = yStart - MAX_PIT_RADIUS; y < yStart + MAX_PIT_RADIUS; y++) {
				tileType type = tilePit;

				int deltaX = abs(xStart - x);
				int deltaY = abs(yStart - y);
				int delta = sqrt(deltaX * deltaX + deltaY * deltaY);
				if (delta > MAX_PIT_RADIUS) continue;
				if (delta > MAX_PIT_RADIUS - 2) {
					type = tileSlopeDown;
				}

				Tile *tile = [dungeon tileAtX: x Y: y Z: z];
				[tile convertToType: type];
			}
		}

		break;
	}
}

+ (void) followDownSlopes: (Dungeon*) dungeon fromZLevel: (int) z {
	assert (z >= 0 && z < MAP_DEPTH - 1);
	
	for (int x = 0; x < MAP_DIMENSION; x++) {
		for (int y = 0; y < MAP_DIMENSION; y++) {
			Tile *up = [dungeon tileAtX:x Y:y Z:z];
			if (up.type == tileSlopeDown) {
				[[dungeon tileAtX:x Y:y Z:z+1] convertToType: tileSlopeUp];
			}
		}
	}	
}

+ (void) followPit: (Dungeon*) dungeon fromZLevel: (int) z {
	assert (z >= 0 && z < MAP_DEPTH - 1);

	for (int x = 0; x < MAP_DIMENSION; x++) {
		for (int y = 0; y < MAP_DIMENSION; y++) {
			Tile *up = [dungeon tileAtX:x Y:y Z:z];
			if (up.type == tilePit || up.type == tileGroundCrumbling) {
				[[dungeon tileAtX:x Y:y Z:z+1] convertToType: tileConcrete];
			}
			if (up.type == tileSlopeDown) {
				[[dungeon tileAtX:x Y:y Z:z+1] convertToType: tileSlopeUp];
			}
		}
	}
}


#pragma mark -
#define BLDG_SIZE 12
+ (void) putBuildingIn: (Dungeon*) dungeon at: (Coord*) coord {
	placementOrderCountTotalForEntireClassOkayGuysNowThisIsHowYouProgramInObjectiveC++;

	int addX = [Rand min: -BLDG_SIZE / 4 max: BLDG_SIZE / 4];
	int addY = [Rand min: -BLDG_SIZE / 4 max: BLDG_SIZE / 4];

	int startX = coord.X + [Rand min: -BLDG_SIZE / 2 max: BLDG_SIZE / 2];
	int startY = coord.Y + [Rand min: -BLDG_SIZE / 2 max: BLDG_SIZE / 2];

	#define END_X (coord.X + BLDG_SIZE + addX)
	for (int x = startX; x < END_X; x++) {

		#define END_Y (startY + BLDG_SIZE + addY)
		for (int y = startY; y < END_Y; y++) {

			Tile *tile = [dungeon tileAtX: x Y: y Z: coord.Z];
			if (tile.type == tileWoodFloor) continue;
			if (tile.cornerWall) continue;

			tileType type = tileWoodWall;

			// check to see if we're inside the 1 tile thick perimeter (of walls)
			bool inRoomOnYAxis = false;
			if (y > startY && y < END_Y - 1) inRoomOnYAxis = true;
			bool inRoomOnXAxis = false;
			if (x > startX && x < END_X - 1) inRoomOnXAxis = true;

			// place either a wall or a floor, overwriting what was there.
			// don't place walls on the edge of the map, preventing some initial box-ins.
			if ((inRoomOnXAxis && inRoomOnYAxis) || x == 0 || x == MAP_DIMENSION - 1 || y == 0 || y == MAP_DIMENSION - 1) {
				type = tileWoodFloor;
			}

			[tile convertToType: type];

			bool corner = (inRoomOnXAxis || inRoomOnYAxis)? false : true;
			tile.cornerWall = corner;

			// If the walls of two buildings would be flush with one another, both walls are replaced with wooden floor.
			// leverage the 'corner' attribute for this.
			
			// FIXME: this is painfully slow.  leaving it out for now.
/*			if (tile.cornerWall) tile.type = tileConcrete;

			if (tile.type == tileWoodWall && !tile.cornerWall) {
				Tile *left = [dungeon tileAtX: x - 1 Y: y Z: coord.Z];
				Tile *right = [dungeon tileAtX: x + 1 Y: y Z: coord.Z];
				Tile *up = [dungeon tileAtX: x Y: y - 1 Z: coord.Z];
				Tile *down = [dungeon tileAtX: x Y: y + 1 Z: coord.Z];

				NSArray *neighbors = [NSArray arrayWithObjects: left, right, up, down, nil];
				for (Tile *neighbor in neighbors) {
					if (neighbor.type != tileWoodWall) continue;
					if (neighbor.cornerWall) continue;
					if (neighbor.placementOrder == tile.placementOrder) continue;
					neighbor.type = tileWoodDoor;
					neighbor.blockMove = false;
					neighbor.blockShoot = false;
					neighbor.smashable = false;

					tile.type = tileNone;
					tile.blockMove = false;
					tile.blockShoot = false;
					tile.smashable = false;					
				}
			}
*/
			
			

			//Any non-corner wall has a 1 / 12 chance of being a crumbling (breakable) wall, a 1 / 12 chance of being a 
			//			broken (passable) wall, and a 1 / 12 chance of being a door.

			// FIXME: allow this to replace tileWoodFloor as well when suitable graphics are found.
			if (tile.type == tileWoodFloor || tile.cornerWall) continue;

			switch ([Rand min:1 max:12]) {
				case 1:
					[tile convertToType: (tile.type == tileWoodWall)? tileWoodDoorOpen : tileRubble];
					break;
				case 2:
					[tile convertToType: (tile.type == tileWoodWall)? tileWoodDoorBroken : tileRubble];
					break;
				case 3:
					[tile convertToType: (tile.type == tileWoodWall)? tileWoodDoorSaloon : tileRubble];
					break;
				case 4:
					[tile convertToType: (tile.type == tileWoodWall)? tileWoodDoor : tileRubble];
					break;
				default:
					break;
			}
		}
	}
}

+ (Dungeon*) putBuildings: (Dungeon*) dungeon onZLevel: (int) z {
	for (int LCV = 0; LCV < 50; LCV++) {
		int x = [Rand min: 0 max: MAP_DIMENSION - 1];
		int y = [Rand min: 0 max: MAP_DIMENSION - 1];
		Coord *coord = [Coord withX: x Y: y Z: z];

		[self putBuildingIn: dungeon at: coord];
	}
	return dungeon;
}

+ (Dungeon*) putDiamondOf: (tileType) type into: (Dungeon*) dungeon centeredAt: (Coord*) coord {
	int xStart = coord.X;
	int yStart = coord.Y;
	xStart += [Rand min: 1 max: CRYPT_WALL_LENGTH / 2];
	yStart += [Rand min: 1 max: CRYPT_WALL_LENGTH / 2];

	int xEnd = xStart + CRYPT_WALL_LENGTH / 2 - 1;
	int yEnd = yStart + CRYPT_WALL_LENGTH / 2 - 1;
	int stretch = [Rand min: -CRYPT_WALL_LENGTH / 4 max: CRYPT_WALL_LENGTH / 4];
	xEnd += stretch, yEnd -= stretch;

	for (int x = xStart; x < xEnd; x++) {
		for (int y = yStart; y < yEnd; y++) {
			int xCenter = xStart + (xEnd - xStart) / 2;
			int yCenter = yStart + (yEnd - yStart) / 2;

			int xDelta = abs(xCenter - x);
			int yDelta = abs(yCenter - y);
			if (xDelta + yDelta > CRYPT_WALL_LENGTH / 4) continue; 

			[[dungeon tileAtX: x Y: y Z: coord.Z] convertToType: type];
		}
	}
	return dungeon;
}

+ (Dungeon*) putBlockOf: (tileType) type into: (Dungeon*) dungeon centeredAt: (Coord*) coord {
	int xStart = coord.X;
	int yStart = coord.Y;
	xStart += [Rand min: 1 max: CRYPT_WALL_LENGTH / 2];
	yStart += [Rand min: 1 max: CRYPT_WALL_LENGTH / 2];

	int xEnd = xStart + CRYPT_WALL_LENGTH / 2 - 1;
	int yEnd = yStart + CRYPT_WALL_LENGTH / 2 - 1;
	int stretch = [Rand min: -CRYPT_WALL_LENGTH / 4 max: CRYPT_WALL_LENGTH / 4];
	xEnd += stretch, yEnd -= stretch;

	for (int x = xStart; x < xEnd; x++) {
		for (int y = yStart; y < yEnd; y++) {
			[[dungeon tileAtX: x Y: y Z: coord.Z] convertToType: type];
		}
	}
	return dungeon;
}

+ (Dungeon*) drunkenWalk: (Dungeon*) dungeon from: (Coord*) start to: (Coord*) end {
//	bool foundBlockingTerrain = false;
	int xDelta = end.X - start.X;
	int yDelta = end.Y - start.Y;
	int xDir = xDelta < 0? -1 : 1;	// if it's == 0, these values are never used.
	int yDir = yDelta < 0? -1 : 1;

	Coord *curr = [Coord withX: start.X Y: start.Y Z: start.Z];
	Tile *prev = nil;
	bool placedInitialDoor = false;
	while (![curr isEqual: end]) {
//		DLog(@"%d %d %d %d", xDelta, xDir, yDelta, yDir);
		if (xDelta) {
			xDelta -= xDir;
			curr.X += xDir;
		}
		else if (yDelta) {
			yDelta -= yDir;
			curr.Y += yDir;
		}

		if ([dungeon tileAt: curr].type == tileStoneGround) {
			if (prev && prev.type == tileBoneWall) {
				[prev convertToType: tileSkullDoor];
			}
		}
//		if (!prev) {
//			[[dungeon tileAt: curr] convertToType: tileSkullDoor];
//		}

		if ([dungeon tileAt: curr].blockMove) {
			if (!placedInitialDoor) {
				[[dungeon tileAt: curr] convertToType: tileSkullDoor];
				placedInitialDoor = true;
			}
			else {
				[[dungeon tileAt: curr] convertToType: tileBoneWall];
			}
		}
		prev = [dungeon tileAt: curr];

//		NSLog([curr description]);
//		if (foundBlockingTerrain)
	}
	return dungeon;
}

+ (Dungeon*) connectRoomIn: (Dungeon*) dungeon at: (Coord*) coord toRoomIn: (bool [CRYPT_ROOMS_COUNT][CRYPT_ROOMS_COUNT]) rooms {
//	for (int y = 0; y < CRYPT_ROOMS_COUNT; y++) { 
//		NSLog(@"%d %d %d %d", rooms[0][y], rooms[1][y], rooms[2][y], rooms[3][y]);
//	}
	
	int xStart = coord.X;
	int yStart = coord.Y;
	int xRoomToConnectTo, yRoomToConnectTo;
	for (int delta = 1; ; delta++) {
		assert (delta < 6);
		for (int xDelta = -delta; xDelta <= delta; xDelta++) {
			for (int yDelta = -delta; yDelta <= delta; yDelta++) {
				if (!xDelta && !yDelta) continue;
				int xCurrent = xStart + xDelta;
				int yCurrent = yStart + yDelta;

				if (xCurrent < 0 || yCurrent < 0 || xCurrent >= CRYPT_ROOMS_COUNT || yCurrent >= CRYPT_ROOMS_COUNT) {
					continue;
				}

				if (rooms[xCurrent][yCurrent]) {
					xRoomToConnectTo = xCurrent, yRoomToConnectTo = yCurrent;
					goto FOUND_ROOM;
				}
			}
		}
	}
	FOUND_ROOM:;

	xRoomToConnectTo *= CRYPT_WALL_LENGTH;
	yRoomToConnectTo *= CRYPT_WALL_LENGTH;

	int xTileToConnectTo, yTileToConnectTo;

	for (int x = xRoomToConnectTo; ; x++) {
		for (int y = yRoomToConnectTo; y < yRoomToConnectTo + CRYPT_WALL_LENGTH; y++) {
//			DLog(@"%d %d",x,y);
//			assert(x < xRoomToConnectTo + CRYPT_WALL_LENGTH + 1);
			Tile *tile = [dungeon tileAtX: x Y: y Z: coord.Z];
			if (!tile.blockMove) {
				xTileToConnectTo = x, yTileToConnectTo = y;
				goto FOUND_END_TILE;
			}
		}
	}
	FOUND_END_TILE:;

	Coord *end = [Coord withX: xTileToConnectTo Y: yTileToConnectTo Z: coord.Z];

	int xToConnectFrom = coord.X * CRYPT_WALL_LENGTH;
	int yToConnectFrom = coord.Y * CRYPT_WALL_LENGTH;

	for (int x = xToConnectFrom; x < xToConnectFrom + CRYPT_WALL_LENGTH; x++) {
		for (int y = yToConnectFrom; y < yToConnectFrom + CRYPT_WALL_LENGTH; y++) {
			Tile *tile = [dungeon tileAtX: x Y: y Z: coord.Z];
//			if (!tile.blockMove) {
			if (tile.type == tileStoneGround) {
				xToConnectFrom = x, yToConnectFrom = y;
				goto FOUND_START_TILE;
			}
		}
	}
	FOUND_START_TILE:;

	Coord *start = [Coord withX: xToConnectFrom Y: yToConnectFrom Z: coord.Z];

	return [self drunkenWalk: dungeon from: start to: end];
}



#pragma mark -

+ (void) putPatchOf: (tileType) type into: (Dungeon*) dungeon at: (Coord*) coord tightly: (bool) tight {
	int reps = tight? 3 : 6;
	for (int LCV = 0; LCV < reps; LCV++) {
		Coord *curr = [Coord withX: coord.X Y: coord.Y Z: coord.Z];
		int delta = tight? 2 : 4;

		curr.X += [Rand min: 0 max: delta] - delta / 2;
		curr.Y += [Rand min: 0 max: delta] - delta / 2;

		if (!tight) [self putPatchOf: type into: dungeon at: curr tightly: true];

		if (![dungeon tileAt: curr].blockMove) {
			[[dungeon tileAt: curr] convertToType: type];
		}
	}
}

+ (Dungeon*) putPatchesOf: (tileType) type into: (Dungeon*) dungeon onZLevel: (int) z {
	for (int LCV = 0; LCV < 200; LCV++) {
		int x = [Rand min: 0 max: MAP_DIMENSION - 1];
		int y = [Rand min: 0 max: MAP_DIMENSION - 1];

		// FIXME... quick hack to prevent most of initial box ins
		if (x + y < 25) {
			LCV--;
			continue;
		}

		[self putPatchOf: type into: dungeon at: [Coord withX: x Y: y Z: z] tightly: false];
	}
	return dungeon;
}

#pragma mark -
#pragma mark --High level

+ (void) setFloorOf: (Dungeon*) dungeon to: (tileType) type onZLevel: (int) z {
	for (int x = 0; x < MAP_DIMENSION; x++) {
		for (int y = 0; y < MAP_DIMENSION; y++) {
			[[dungeon tileAtX:x Y:y Z:z] convertToType: type];
		}
	}
}

+ (void) placeItems:(int) number inDungeon:(Dungeon*)dungeon
{
	for (int level=0; level < [dungeon numberOfLevels]; ++level) 
	{
		for (int LCV = 0; LCV < number; ++LCV) 
		{
			Coord *itemLoc;
			// Find a square that we can place a monster in.
			//TODO: Find a way to do this that is better than triple nested loop.
			do {
				itemLoc = [Coord withX:[Rand min:0 max:MAP_DIMENSION] Y:[Rand min:0 max:MAP_DIMENSION] Z:level];
			} while ([dungeon tileAt:itemLoc].blockMove);
			
			
			Item *item = [Item generateRandomItem: 0 elemType: [Rand min: 0 max: 4]];
			// note: the key apparently gets copied during this call.
			[dungeon.items setObject: item forKey: itemLoc];
		}
	}
}

+ (void) placeMonsters:(int) number inDungeon:(Dungeon*)dungeon
{
	for (int level=0; level < [dungeon numberOfLevels]; ++level) 
	{
		for (int LCV = 0; LCV < number; ++LCV) 
		{
			Coord *monsterLoc;
			// Find a square that we can place a monster in.
			//TODO: Find a way to do this that is better than triple nested loop.
			do {
				monsterLoc = [Coord withX:[Rand min:0 max:MAP_DIMENSION] Y:[Rand min:0 max:MAP_DIMENSION] Z:level];
			} while ([dungeon tileAt:monsterLoc].blockMove);
			
			int aiType = [Rand min:0 max:5];
			int monsterlevel = level*4 + [Rand min:0 max:4];
			Critter *critter = [[[Critter alloc] initWithLevel:0] autorelease];
			switch (aiType) {
				case 0:
					critter = [[[BerserkerCritter alloc] initWithLevel:monsterlevel] autorelease];
					break;
				case 1:
					critter = [[[WarriorCritter alloc] initWithLevel:monsterlevel] autorelease];
					break;
				case 2:
					critter = [[[PaladinCritter alloc] initWithLevel:monsterlevel] autorelease];
					break;
				case 3:
					critter = [[[ShadowKnightCritter alloc] initWithLevel:monsterlevel] autorelease];
					break;
				case 4:
					critter = [[[RogueCritter alloc] initWithLevel:monsterlevel] autorelease];
					break;
				case 5:
					critter = [[[MageCritter alloc] initWithLevel:monsterlevel] autorelease];
					break;
			}
			critter.location = monsterLoc;
			[dungeon.liveEnemies addObject:critter];
		}
	}
}

+ (Dungeon*) makeOrcMines: (Dungeon*) dungeon 
{
	[self setFloorOf: dungeon to: tileGrass onZLevel: 0];
	[self putPatchesOf: tileRubble into: dungeon onZLevel:0];
	[self putBuildings: dungeon onZLevel: 0];
	for (int LCV = 0; LCV < 6; LCV++) {
		[self putPit: dungeon onZLevel: 0];
	}
	for (int LCV = 0; LCV < 2; LCV++) {
		[self gameOfLife:dungeon zLevel:0 targeting:tileSlopeDown harshness: average];
	}
	[self gameOfLife:dungeon zLevel:0 targeting:tileSlopeDown harshness: agentOrange];
	[[dungeon tileAtX: 2 Y: 0 Z: 0] convertToType: tileStairsToTown];

	[self setFloorOf: dungeon to: tileRockWall onZLevel: 1];
	[self followPit:dungeon fromZLevel:0];
	for (int LCV = 0; LCV < 18; LCV++) {
		[self gameOfLife:dungeon zLevel:1 targeting:tileRockWall harshness: agentOrange];
	}

	[self gameOfLife:dungeon zLevel:1 targeting:tileRockWall harshness: average];

	[self putPatchesOf: tileRubble into: dungeon onZLevel:1];
	[self putPatchesOf: tileLichen into: dungeon onZLevel:1];
	for (int LCV = 0; LCV < 4; LCV++) {
		[self putPit: dungeon onZLevel: 1];
	}
	for (int LCV = 0; LCV < 2; LCV++) {
		[self gameOfLife:dungeon zLevel:1 targeting:tileSlopeDown harshness: average];
	}
	[self gameOfLife:dungeon zLevel:1 targeting:tileSlopeDown harshness: agentOrange];
	[self followDownSlopes:dungeon fromZLevel:0];

	[self setFloorOf: dungeon to: tileRockWall onZLevel: 2];
	[self followPit: dungeon fromZLevel:1];
	NSMutableArray *connected = [self allConnected: dungeon onZLevel: 2];
	while ([connected count] > 1) {
		for (NSMutableArray *tiles in connected) {
			for (int SCV = 0; SCV < 12; SCV++) {
				[self bomb:dungeon targeting:tiles tightly:true towardsCenter:true];
				[self gameOfLife:dungeon zLevel:2 targeting:tileRockWall harshness: agentOrange];
//			[self gameOfLife:dungeon zLevel:2 targeting:tileRockWall harshness: average];
			}
		}
		break;
		connected = [self allConnected: dungeon onZLevel: 2];
	}
//	for (int LCV = 0; LCV < 3; LCV++) {
//
//	}
	[self followDownSlopes: dungeon fromZLevel:1];
	
	[self placeMonsters:70 inDungeon:dungeon];
	[self placeItems:40 inDungeon:dungeon];

	return dungeon;
}

+ (Dungeon*) makeTown: (Dungeon*) dungeon {
	/*
	 ye olde key:
	 g = Grass
	 w = wooden Wall
	 f = wooden Floor
	 d = Door
	 o = Orc mines stair
	 m = Morlock tunnels stair
	 c = Crypts stair
	 u = Underground forest stair
	 a = Abyss stair
	 i = Innkeeper
	 */
	#define TOWN_DIMENSION 12
	const char TOWN [TOWN_DIMENSION][TOWN_DIMENSION] =
	{
		{ 'g', 'g', 'w', 'w', 'w', 'w' , 'f' , 'f' , 'f' , 'w' , 'g' , 'g' } ,
		{ 'g', 'g', 'd', 'f', 'i', 'w' , 'f' , 'f' , 'f' , 'w' , 'g' , 'g' } ,
		{ 'g', 'g', 'w', 'f', 'f', 'w' , 'f' , 'f' , 'f' , 'w' , 'g' , 'g' } ,
		{ 'g', 'g', 'w', 'w', 'w', 'w' , 'd' , 'w' , 'w' , 'w' , 'g' , 'g' } ,
		{ 'g', 'g', 'g', 'g', 'g', 'g' , 'g' , 'g' , 'g' , 'g' , 'g' , 'g' } ,
		{ 'g', 'g', 'g', 'g', 'g', 'g' , 'g' , 'g' , 'g' , 'g' , 'g' , 'g' } ,
		{ 'g', 'g', 'g', 'g', 'w', 'w' , 'd' , 'w' , 'w' , 'g' , 'g' , 'g' } ,
		{ 'g', 'g', 'g', 'g', 'w', 'f' , 'f' , 'f' , 'w' , 'g' , 'g' , 'g' } ,
		{ 'g', 'g', 'g', 'g', 'w', 'f' , 'f' , 'f' , 'w' , 'g' , 'g' , 'g' } ,
		{ 'g', 'g', 'g', 'g', 'w', 'f' , 'f' , 'f' , 'w' , 'g' , 'g' , 'g' } ,
		{ 'g', 'g', 'g', 'g', 'w', 'w' , 'w' , 'w' , 'w' , 'g' , 'g' , 'g' } ,
		{ 'o', 'm', 'c', 'u', 'g', 'a' , 'g' , 'g' , 'g' , 'g' , 'g' , 'g' }
	};

	[self setFloorOf: dungeon to: tilePit onZLevel: 0];

	for (int x = 0; x < TOWN_DIMENSION; x++) {
		for (int y = 0; y < TOWN_DIMENSION; y++) {
			Tile *tile = [dungeon tileAtX:x Y:y Z:0];
			switch (TOWN [y][x]) {
				case 'g':
					[tile convertToType: tileGrass];
					break;
				case 'w':
					[tile convertToType: tileWoodWall];
					break;
				case 'f':
					[tile convertToType: tileWoodFloor];
					break;
				case 'd':
					[tile convertToType: tileWoodDoorOpen];
					break;
				case 'i':
					[tile convertToType: tileShopKeeper];
					break;
				case 'c':
					[tile convertToType: tileStairsToCrypt];
					break;
				case 'o':
					[tile convertToType: tileStairsToOrcMines];
					break;
				default:
					[tile convertToType: tileGroundCrumbling];
					// FIXME need more graphics
			}
		}
	}
	
	// place NPC characters
	Critter *critter;
	critter = [[[NPCCritter alloc] initWithLevel:1] autorelease];
	critter.location = [Coord withX:7 Y:1 Z:0];
	critter.npc = YES;
	//critter.stringIcon = @"Priest.png";
	critter.dialog = [[Priest alloc] init];
	[dungeon.liveEnemies addObject:critter];
	return dungeon;
}

//tileStairsToCrypt, tileBoneWall, tileStoneGround, tileBrickWall, tileBloodyWall
+ (Dungeon*) makeCrypts: (Dungeon*) dungeon {
	[self setFloorOf: dungeon to: tileBrickWall onZLevel: 0];

	bool rooms [CRYPT_ROOMS_COUNT][CRYPT_ROOMS_COUNT];
	for (int x = 0; x < CRYPT_ROOMS_COUNT; x++) { for (int y = 0; y < CRYPT_ROOMS_COUNT; y++) {
		rooms[x][y] = 0;
	} }

	int roomsPlaced = 0;
	Coord *coord = [Coord withX: 0 Y: 0 Z: 0];
	
	while (roomsPlaced < CRYPT_ROOMS_COUNT * CRYPT_ROOMS_COUNT) {
		int x = [Rand min:0 max:CRYPT_ROOMS_COUNT - 1];
		int y = [Rand min:0 max:CRYPT_ROOMS_COUNT - 1];
		if (rooms[x][y]) {
			continue;
		}
		else {
			rooms[x][y] = true;
			roomsPlaced++;
		}

		coord.X = x * CRYPT_WALL_LENGTH;
		coord.Y = y * CRYPT_WALL_LENGTH;
		switch ([Rand min: 0 max: 1]) {
			case 0:
				[self putBlockOf: tileStoneGround into: dungeon centeredAt: coord];
				break;
			case 1:
				[self putDiamondOf: tileStoneGround into: dungeon centeredAt: coord];
				break;
			default:
				assert (false);
		}

		if (roomsPlaced > 1) {
			coord.X = x;
			coord.Y = y;
			[self connectRoomIn: dungeon at: coord toRoomIn: rooms];
		}

	}
	
	[self placeMonsters:40 inDungeon:dungeon];
	[self placeItems:25 inDungeon:dungeon];
	
	return dungeon;
}

#pragma mark -

+ (Dungeon*) make: (Dungeon*) dungeon intoType: (levelType) lvlType {
	//bool lvlGen = LVL_GEN_ENV;
	//LVL_GEN_ENV = false;
	switch (lvlType) {
		case orcMines:
			dungeon = [self makeOrcMines: dungeon];
			break;
		case town:
			dungeon = [self makeTown: dungeon];
			break;
		case crypts:
			dungeon = [self makeCrypts: dungeon];
			break;			
		default:
			DLog(@"invalid dungeon type");
			break;
	}
	//LVL_GEN_ENV = lvlGen;
	return dungeon;
}

@end