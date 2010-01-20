@class Coord;		// defined in Util

typedef enum levelType {
	town, orcMines, morlockTunnels, crypts, undergroundForest, abyss
} levelType;

typedef enum tileSprite {
	tileNotInitialized, grass, rockFloor, rockWall
} tileSprite;

#pragma mark -

@interface Tile : NSObject {
	bool blockView;
	bool blockMove;
	tileSprite sprite;
}
@property (nonatomic) bool blockView;
@property (nonatomic) bool blockMove;
@property (nonatomic) tileSprite sprite;

@end

#pragma mark -

@interface Dungeon : NSObject {
	;
}
- (Dungeon*) initWithType: (levelType) lvlType;
- (Tile*) tileAtX: (int) x Y: (int) y Z: (int) z;
- (Coord*) playerLocation;

@end
