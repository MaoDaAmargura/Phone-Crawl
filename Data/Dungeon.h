

typedef enum {
	town, orcMines, morlockTunnels, crypts, undergroundForest, abyss, NOT_INITIALIZED,
} levelType;


@class Coord;		// defined in Util
@class Tile;


#pragma mark -

@interface Dungeon : NSObject 
{
	levelType dungeonType;
	Coord *playerStartLocation;
	NSMutableArray *liveEnemies;
	NSMutableDictionary *items;
	
	@private
	NSMutableArray *tiles;
}

- (void) convertToType: (levelType) lvlType;

// note: returns nil in case of out of bounds
- (Tile*) tileAtX: (int) x Y: (int) y Z: (int) z;
- (Tile*) tileAt: (Coord*) coord;

+ (Dungeon*) loadDungeonFromFile:(NSString*)filename;

- (int) numberOfLevels;

// These are attributes of the dungeon object used by engine to determine how to set up a game.
// This is object oriented programming 101. 
@property (nonatomic) levelType dungeonType;
@property (nonatomic, retain) Coord *playerStartLocation;
@property (nonatomic, retain) NSMutableArray *liveEnemies;
@property (nonatomic, retain) NSMutableDictionary *items;

@end
