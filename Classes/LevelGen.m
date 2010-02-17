#import "Util.h"
#import "Dungeon.h"
#import "LevelGen.h"
#import "Tile.h"

#pragma mark --hacks

@interface Dungeon ()
- (bool) setTile: (Tile*) tile X: (int) x Y: (int) y Z: (int) z;
- (bool) setTile: (Tile*) tile at: (Coord*) coord;
@end

extern int placementOrderCountTotalForEntireClassOkayGuysNowThisIsHowYouProgramInObjectiveC;

#pragma mark --private

@interface LevelGen ()

+ (Dungeon*) makeOrcMines: (Dungeon*) dungeon;
+ (Dungeon*) putBuildings: (Dungeon*) dungeon onZLevel: (int) z;

@end

#pragma mark -

@implementation LevelGen

#pragma mark -
#pragma mark Flood Fill

+ (void) fill: (Dungeon*) dungeon fromTile: (Tile*) tile atX: (int) x Y: (int) y Z: (int) z
		withReachable: (NSMutableArray*) reachable withUnreachable: (NSMutableArray*) unreachable {

//	if (blockMove) return;
	

//	fill
}


+ (NSMutableArray*) unconnected: (Dungeon*) dungeon onZLevel: (int) z {
	NSMutableArray *retval = [[NSMutableArray alloc] init];
	for (int x = 0; x < MAP_DIMENSION; x++) {
		for (int y = 0; y < MAP_DIMENSION; y++) {
			Tile *tile = [dungeon tileAtX: x Y: y Z: z];
			if (!tile.blockMove) [retval addObject: tile];
		}
	}

//	NSMutableArray *connected = [[NSMutableArray alloc] init];

	return [retval autorelease];
}


#pragma mark -
#pragma mark Game of Life


static tileType deadTile [] = {
//	tileNone, tileGrass, tileConcrete, tileRubble, tileWoodWall,
//	tileWoodDoor, tileWoodFloor, tileWoodDoorOpen, tileWoodDoorSaloon, tileWoodDoorBroken,
//	tilePit, tileSlopeDown, tileSlopeUp, tileRockWall, tileLichen,
//	tileGroundCrumbling, tileStoneCrumbling

	tileNone, tileGrass, tileStoneCrumbling, tileRubble, tileRubble,
	tileWoodDoorBroken, tileRubble, tileWoodDoorBroken, tileWoodDoorBroken, tileWoodFloor,
	tileGroundCrumbling, tileGroundCrumbling, tileRubble, tileRockWall, tileLichen,
	tileNone, tileConcrete
};

typedef enum {
	agentOrange, average, fecund
} golParam;

+ (int) golCountNeighborsIn: (Dungeon*) dungeon ofType: (tileType) type around: (Coord*) coord {
	int neighbors = 0;
	for (int dx = -1; dx <= 1; dx++) {
		if (coord.X + dx < 0 || coord.X + dx >= MAP_DIMENSION) continue;
		for (int dy = -1; dy <= 1; dy++) {
			if (coord.Y + dy < 0 || coord.Y + dy >= MAP_DIMENSION) continue;
			if ([dungeon tileAtX:coord.X + dx Y: coord.Y + dy Z: coord.Z].type == type) {
				neighbors++;
			}
		}
	}
	return neighbors;
}

+ (bool) killWithNeighbors:(int) neighbors harshness: (golParam) harshness {
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
	NSMutableArray *tilesToKill = [[NSMutableArray alloc] initWithCapacity: 120];
	NSMutableArray *tilesToBirth = [[NSMutableArray alloc] initWithCapacity: 120];

	for (int x = 0; x < MAP_DIMENSION; x++) {
		for (int y = 0; y < MAP_DIMENSION; y++) {
			coord.X = x, coord.Y = y;
			int neighbors = [self golCountNeighborsIn:dungeon ofType:type around:coord];

			if ([dungeon tileAt:coord].type == type && [self killWithNeighbors:neighbors harshness:harshness]) {
				[tilesToKill addObject: [dungeon tileAt: coord]];
			}

			else if ([dungeon tileAt:coord].type != type && [self birthWithNeighbors:neighbors harshness:harshness]) {
				[tilesToBirth addObject: [dungeon tileAt: coord]];
			}
		}
	}

	for (Tile *tile in tilesToKill) {
		[tile initWithTileType: deadTile[type]];
	}
	for (Tile *tile in tilesToBirth) {
		[tile initWithTileType: type];
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
				[tile initWithTileType: type];
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
				[[dungeon tileAtX:x Y:y Z:z+1] initWithTileType: tileSlopeUp];
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
				[[dungeon tileAtX:x Y:y Z:z+1] initWithTileType: tileConcrete];
			}
			if (up.type == tileSlopeDown) {
				[[dungeon tileAtX:x Y:y Z:z+1] initWithTileType: tileSlopeUp];
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
			if (inRoomOnXAxis && inRoomOnYAxis) {
				type = tileWoodFloor;
			}

			[tile initWithTileType: type];

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
					[tile initWithTileType: (tile.type == tileWoodWall)? tileWoodDoorOpen : tileRubble];
					break;
				case 2:
					[tile initWithTileType: (tile.type == tileWoodWall)? tileWoodDoorBroken : tileRubble];
					break;
				case 3:
					[tile initWithTileType: (tile.type == tileWoodWall)? tileWoodDoorSaloon : tileRubble];
					break;
				case 4:
					[tile initWithTileType: (tile.type == tileWoodWall)? tileWoodDoor : tileRubble];
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
			[[dungeon tileAt: curr] initWithTileType: type];
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
			[[dungeon tileAtX:x Y:y Z:z] initWithTileType: type];
		}
	}
}

+ (Dungeon*) makeOrcMines: (Dungeon*) dungeon {
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


	[self setFloorOf: dungeon to: tileRockWall onZLevel: 1];
	[self followPit:dungeon fromZLevel:0];
	for (int LCV = 0; LCV < 4; LCV++) {
		[self gameOfLife:dungeon zLevel:1 targeting:tileRockWall harshness: agentOrange];
	}
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

	

	return dungeon;
}

+ (Dungeon*) makeTown: (Dungeon*) dungeon {
	for (int XCV = 0; XCV < MAP_DIMENSION; XCV++) {
		for (int YCV = 0; YCV < MAP_DIMENSION; YCV++) {
//			bool validTile = [dungeon tileAtX:XCV Y:YCV Z:0]? true : false;
//			Tile *tile = [];
//			[dungeon setTile:  X:  Y:  Z: ];
		}
	}
	return dungeon;
}

#pragma mark -

+ (Dungeon*) make: (Dungeon*) dungeon intoType: (levelType) lvlType {
	switch (lvlType) {
		case orcMines:
			dungeon = [self makeOrcMines: dungeon];
			break;
		case town:
			dungeon = [self makeTown: dungeon];
			break;
		default:
			DLog(@"invalid dungeon type");
			break;
	}
	return nil;
}

@end