#import "Tile.h"
typedef enum {
	town, orcMines, morlockTunnels, crypts, undergroundForest, abyss
} levelType;


@class Coord;		// defined in Util
@class Tile;


#pragma mark -

@interface Dungeon : NSObject {
	;
}
- (Dungeon*) initWithType: (levelType) lvlType;
- (Tile*) tileAtX: (int) x Y: (int) y Z: (int) z;
- (Coord*) playerLocation;

+ (Dungeon*) loadDungeonFromFile:(NSString*)filename;

@end
