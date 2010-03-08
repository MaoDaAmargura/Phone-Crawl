

typedef enum {
	town, orcMines, morlockTunnels, crypts, undergroundForest, abyss
} levelType;


@class Coord;		// defined in Util
@class Tile;


#pragma mark -

@interface Dungeon : NSObject 
{
	levelType dungeonType;
	Coord *playerLocation;
	NSMutableArray *liveEnemies;
	NSMutableDictionary *items;
}

- (Dungeon*) initWithType: (levelType) lvlType;

// note: returns nil in case of out of bounds
- (Tile*) tileAtX: (int) x Y: (int) y Z: (int) z;
- (Tile*) tileAt: (Coord*) coord;

+ (Dungeon*) loadDungeonFromFile:(NSString*)filename;

// These are attributes of the dungeon object used by engine to determine how to set up a game.
// This is object oriented programming 101. 
@property (nonatomic) levelType dungeonType;
@property (nonatomic, retain) Coord *playerLocation;
@property (nonatomic, retain) NSMutableArray *liveEnemies;
@property (nonatomic, retain) NSMutableDictionary *items;

@end
