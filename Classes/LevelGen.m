#import "Util.h"
#import "Dungeon.h"
#import "LevelGen.h"
#import "Tile.h"

#pragma mark --hacks

@interface Dungeon ()
- (bool) setTile: (Tile*) tile X: (int) x Y: (int) y Z: (int) z;
- (bool) setTile: (Tile*) tile at: (Coord*) coord;
@end

#pragma mark --private

@interface LevelGen ()

+ (Dungeon*) makeOrcMines: (Dungeon*) dungeon;
+ (Dungeon*) putRubble: (Dungeon*) dungeon;
//+ (Dungeon*) putBuildings: (Dungeon*) dungeon;

@end

#pragma mark --implementation

@implementation LevelGen

+ (int) min: (int) lowBound max: (int) highBound {
	assert (lowBound <= highBound);
	int range = highBound - lowBound + 1; // +1 is due to behavior of modulo
	return ((rand() % range) + lowBound);
}

+ (void) putRubblePatchIn: (Dungeon*) dungeon at: (Coord*) coord tightly: (bool) tight {
	int reps = tight? 3 : 6;
	for (int LCV = 0; LCV < reps; LCV++) {
		Tile *tile = [[Tile alloc] init];
		tile.blockMove = true;
		tile.type = tileDirt;

		Coord *curr = [Coord withX: coord.X Y: coord.Y Z: coord.Z];
		int delta = tight? 2 : 4;

		curr.X += [self min: 0 max: delta] - delta / 2;
		curr.Y += [self min: 0 max: delta] - delta / 2;

		[dungeon setTile: tile at: curr];

		if (!tight) [self putRubblePatchIn: dungeon at: curr tightly: true];
	}
}

+ (Dungeon*) putRubble: (Dungeon*) dungeon onZLevel: (int) z{
	for (int LCV = 0; LCV < 200; LCV++) {
		int x = [self min: 0 max: MAP_DIMENSION - 1];
		int y = [self min: 0 max: MAP_DIMENSION - 1];

		[self putRubblePatchIn: dungeon at: [Coord withX: x Y: y Z: z] tightly: false];
	}
	return dungeon;
}

+ (Dungeon*) makeOrcMines: (Dungeon*) dungeon {
	return [self putRubble: dungeon onZLevel: 0];
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

+ (Dungeon*) make: (Dungeon*) dungeon intoType: (levelType) lvlType {
	srand(time(0));
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