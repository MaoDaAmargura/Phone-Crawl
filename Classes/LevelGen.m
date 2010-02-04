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
+ (Dungeon*) putRubble: (Dungeon*) dungeon onZLevel: (int) z;
+ (Dungeon*) putBuildings: (Dungeon*) dungeon onZLevel: (int) z;

@end

#pragma mark --implementation

@implementation LevelGen

#pragma mark -
#define MAX_PIT_RADIUS 10
+ (void) putPit: (Dungeon*) dungeon onZLevel: (int) z {
	assert(z < MAP_DEPTH - 1);

	for (int LCV = 0; LCV < 6; LCV++) {

		int xStart = [Rand min: MAX_PIT_RADIUS max: MAP_DIMENSION - 1 - MAX_PIT_RADIUS];
		int yStart = [Rand min: MAX_PIT_RADIUS max: MAP_DIMENSION - 1 - MAX_PIT_RADIUS];

		for (int x = xStart - MAX_PIT_RADIUS; x < xStart + MAX_PIT_RADIUS; x++) {
			for (int y = yStart - MAX_PIT_RADIUS; y < yStart + MAX_PIT_RADIUS; y++) {
				tileType type = tilePit;
				tileType typePitBase = tileConcrete;

				int deltaX = abs(xStart - x);
				int deltaY = abs(yStart - y);
				int delta = sqrt(deltaX * deltaX + deltaY * deltaY);
				if (delta > MAX_PIT_RADIUS) continue;
				if (delta > MAX_PIT_RADIUS - 2) {
					type = tileSlopeDown;
					typePitBase = tileSlopeUp;
				}

				Tile *tile = [dungeon tileAt: [Coord withX: x Y: y Z: z]];
				[tile initWithType: type];

				Tile *tilePitBase = [dungeon tileAt: [Coord withX: x Y: y Z: z + 1]];
				[tilePitBase initWithType: typePitBase];

				DLog (@"tilepitbase loc:%@ type %@",[[Coord withX: x Y: y Z: z + 1] description], (tilePitBase.type == tileConcrete? @"concrete":@"something crazy"));
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

			Tile *existing = [dungeon tileAtX: x Y: y Z: coord.Z];
			if (existing.type == tileWoodFloor) continue;
			if (existing.cornerWall) continue;

			Tile *tile = [Tile alloc];

			// check to see if we're inside the 1 tile thick perimeter (of walls)
			bool inRoomOnYAxis = false;
			if (y > startY && y < END_Y - 1) inRoomOnYAxis = true;
			bool inRoomOnXAxis = false;
			if (x > startX && x < END_X - 1) inRoomOnXAxis = true;

			// place either a wall or a floor, overwriting what was there.
			if (inRoomOnXAxis && inRoomOnYAxis) {
				[tile initWithType: tileWoodFloor];
			}
			else {
				[tile initWithType: tileWoodWall];

				// corner case.
				bool corner = (inRoomOnXAxis || inRoomOnYAxis)? false : true;
				tile.cornerWall = corner;
			}

			Coord *curr = [Coord withX: x Y: y Z: coord.Z];
			[dungeon setTile: tile at: curr];
			
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
					[tile initWithType: (tile.type == tileWoodWall)? tileWoodDoorOpen : tileRubble];
					break;
				case 2:
					[tile initWithType: (tile.type == tileWoodWall)? tileWoodDoorBroken : tileRubble];
					break;
				case 3:
					[tile initWithType: (tile.type == tileWoodWall)? tileWoodDoorSaloon : tileRubble];
					break;
				case 4:
					[tile initWithType: (tile.type == tileWoodWall)? tileWoodDoor : tileRubble];
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

+ (void) putRubblePatchIn: (Dungeon*) dungeon at: (Coord*) coord tightly: (bool) tight {
	int reps = tight? 3 : 6;
	for (int LCV = 0; LCV < reps; LCV++) {
		Tile *tile = [[Tile alloc] init];
		tile.blockMove = true;
		tile.type = tileRubble;

		Coord *curr = [Coord withX: coord.X Y: coord.Y Z: coord.Z];
		int delta = tight? 2 : 4;

		curr.X += [Rand min: 0 max: delta] - delta / 2;
		curr.Y += [Rand min: 0 max: delta] - delta / 2;

		if (!tight) [self putRubblePatchIn: dungeon at: curr tightly: true];

		if (![dungeon tileAt: curr].blockMove) {
			[dungeon setTile: tile at: curr];
		}
	}
}

+ (Dungeon*) putRubble: (Dungeon*) dungeon onZLevel: (int) z {
	for (int LCV = 0; LCV < 200; LCV++) {
		int x = [Rand min: 0 max: MAP_DIMENSION - 1];
		int y = [Rand min: 0 max: MAP_DIMENSION - 1];

		[self putRubblePatchIn: dungeon at: [Coord withX: x Y: y Z: z] tightly: false];
	}
	return dungeon;
}

#pragma mark -

+ (Dungeon*) makeOrcMines: (Dungeon*) dungeon {
	[self putRubble: dungeon onZLevel: 0];
	[self putBuildings: dungeon onZLevel: 0];
	[self putPit: dungeon onZLevel: 0];

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