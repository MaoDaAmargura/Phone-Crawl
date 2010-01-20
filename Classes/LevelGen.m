#import "Util.h"
#import "Dungeon.h"
#import "LevelGen.h"

#pragma mark --hacks

@interface Dungeon ()
- (bool) setTile: (Tile*) tile X: (int) x Y: (int) y Z: (int) z;
@end

#pragma mark --private

@interface LevelGen ()

+ (Dungeon*) makeOrcMines: (Dungeon*) dungeon;

@end

#pragma mark --implementation

@implementation LevelGen

+ (Dungeon*) makeOrcMines: (Dungeon*) dungeon {
	return dungeon;
}

+ (Dungeon*) makeTown: (Dungeon*) dungeon {
	for (int XCV = 0; XCV < MAP_DIMENSION; XCV++) {
		for (int YCV = 0; YCV < MAP_DIMENSION; YCV++) {
//			bool validTile = [dungeon tileAtX:XCV Y:YCV Z:0]? true : false;
//			Tile *tile = [];
//			[dungeon setTile:<#(Tile *)tile#> X:<#(int)x#> Y:<#(int)y#> Z:<#(int)z#>];
		}
	}
	return dungeon;
}

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