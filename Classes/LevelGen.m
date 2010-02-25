#import "Util.h"
#import "Dungeon.h"
#import "LevelGen.h"
#import "Tile.h"
#import "Item.h"
#import "Creature.h"

#pragma mark --hacks

@interface Dungeon ()
- (bool) setTile: (Tile*) tile X: (int) x Y: (int) y Z: (int) z;
- (bool) setTile: (Tile*) tile at: (Coord*) coord;
@end

extern int placementOrderCountTotalForEntireClassOkayGuysNowThisIsHowYouProgramInObjectiveC;
extern NSMutableDictionary *items; // from Dungeon.h

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
	NSMutableArray *black = [[NSMutableArray alloc] init];

	NSMutableArray *gray = [[NSMutableArray alloc] init];
	[gray addObject: [white objectAtIndex: 0]];
	[white removeObjectAtIndex: 0];
	
	NSMutableArray *nextGray = [[NSMutableArray alloc] init];
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
				assert (![gray containsObject: nextTile]);

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

	return [black autorelease];
}

// returns a two dimensional array of all connected components of the Z level it's called on
+ (NSMutableArray*) allConnected: (Dungeon*) dungeon onZLevel: (int) z {
	NSMutableArray *white = [[NSMutableArray alloc] initWithCapacity: MAP_DIMENSION * MAP_DIMENSION / 2];

	for (int x = 0; x < MAP_DIMENSION; x++) {
		for (int y = 0; y < MAP_DIMENSION; y++) {
			Tile *tile = [dungeon tileAtX: x Y: y Z: z];
			if (!tile.blockMove) [white addObject: tile];
		}
	}
	assert ([white count]);

	NSMutableArray *twoDimens = [[NSMutableArray alloc] init];
	while ([white count]) {
		NSMutableArray *connected = [self singleComponent: dungeon withClearTiles: white];
		if ([connected count]) [twoDimens addObject: connected];
		else DLog(@"bug in flood fill?");
	}

	return [twoDimens autorelease];
}

+ (void) bomb: (Dungeon*) dungeon targeting: (NSMutableArray*) targets tightly: (bool) tight towardsCenter: (bool) directed {
	DLog(@"max %d", [targets count] - 1);
	Tile *target = [targets objectAtIndex: [Rand min: 0 max: [targets count] - 1]];
	DLog(@"b");

//	int height = [Rand min: 3 max: 9];
//	int width = 12 - height;

//	int xRange = tight?  FIXME
	int xBegin = target.x + [Rand min: -6 max: 6];
	int yBegin = target.y + [Rand min: -6 max: 6];

	for (int x = xBegin - 6; x <= xBegin + 6; x++) {
		for (int y = yBegin - 6; y <= yBegin + 6; y++) {
			Tile *curr = [dungeon tileAtX: x Y: y Z: target.z];
			if (curr) [curr initWithTileType: tileConcrete];
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
			// don't place walls on the edge of the map, preventing some initial box-ins.
			if ((inRoomOnXAxis && inRoomOnYAxis) || x == 0 || x == MAP_DIMENSION - 1 || y == 0 || y == MAP_DIMENSION - 1) {
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
	[[dungeon tileAtX: 2 Y: 0 Z: 0] initWithTileType: tileStairsToTown];


	[items removeAllObjects];
	Coord *coord = [Coord withX: 0 Y: 0 Z: 0];
	for (int LCV = 0; LCV < MAP_DIMENSION * MAP_DIMENSION / 2; LCV++) {
		coord.X = [Rand min: 0 max: MAP_DIMENSION - 1];
		coord.Y = [Rand min: 0 max: MAP_DIMENSION - 1];
		Item *item = [Item generate_random_item: 0 elem_type: [Rand min: 0 max: 4]];

		[items setObject: item forKey: coord];
//		+(Item *) generate_random_item: (int) dungeon_level elem_type: (elemType) elem_type;
//		typedef enum {FIRE = 0,COLD = 1,LIGHTNING = 2,POISON = 3,DARK = 4} elemType;
	}

	if (!LVL_GEN_ENV) return;

	[self setFloorOf: dungeon to: tileRockWall onZLevel: 1];
	[self followPit:dungeon fromZLevel:0];
//	NSMutableArray *connected = [[NSMutableArray alloc] init];
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
			}
		}
		connected = [self allConnected: dungeon onZLevel: 2];
	}
	for (int LCV = 0; LCV < 3; LCV++) {
		[self gameOfLife:dungeon zLevel:2 targeting:tileRockWall harshness: agentOrange];
		[self gameOfLife:dungeon zLevel:2 targeting:tileRockWall harshness: average];
	}
	[self followDownSlopes: dungeon fromZLevel:1];
	
	//DLog (@"%@",[self allConnected:dungeon onZLevel: 2]);

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
	#define TOWN_DIMENSION 6
	const char TOWN [TOWN_DIMENSION][TOWN_DIMENSION] =
	{
		{ 'g', 'g', 'w', 'w', 'w', 'w' } ,
		{ 'g', 'g', 'd', 'f', 'i', 'w' } ,
		{ 'g', 'g', 'w', 'f', 'f', 'w' } ,
		{ 'g', 'g', 'w', 'w', 'w', 'w' } ,
		{ 'g', 'g', 'g', 'g', 'g', 'g' } ,
		{ 'o', 'm', 'c', 'u', 'g', 'a' }
	};

	[self setFloorOf: dungeon to: tilePit onZLevel: 0];

	for (int x = 0; x < TOWN_DIMENSION; x++) {
		for (int y = 0; y < TOWN_DIMENSION; y++) {
			Tile *tile = [dungeon tileAtX:x Y:y Z:0];
			switch (TOWN [y][x]) {
				case 'g':
					[tile initWithTileType: tileGrass];
					break;
				case 'w':
					[tile initWithTileType: tileWoodWall];
					break;
				case 'f':
					[tile initWithTileType: tileWoodFloor];
					break;
				case 'd':
					[tile initWithTileType: tileWoodDoorOpen];
					break;
				case 'i':
					[tile initWithTileType: tileShopKeeper];
					break;
				case 'o':
					[tile initWithTileType: tileStairsToOrcMines];
					// FIXME should be a staircase 
					break;
				default:
					[tile initWithTileType: tileGroundCrumbling];
					// FIXME need more graphics
			}
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