#import "Tile.h"
typedef enum {
	town, orcMines, morlockTunnels, crypts, undergroundForest, abyss
} levelType;


@class Coord;		// defined in Util
@class Tile;


#pragma mark -

@interface Dungeon : NSObject {
	Coord *playerLocation;
	NSMutableArray *liveEnemies;	// note: shared with Engine
}

- (Dungeon*) initWithType: (levelType) lvlType;

// note: returns nil in case of out of bounds
- (Tile*) tileAtX: (int) x Y: (int) y Z: (int) z;
- (Tile*) tileAt: (Coord*) coord;

+ (Dungeon*) loadDungeonFromFile:(NSString*)filename;

// FIXME: is this ever updated / still necessary?
@property (nonatomic, retain) Coord *playerLocation;
@property (nonatomic, retain) NSMutableArray *liveEnemies;

extern NSMutableDictionary *items;

@end
