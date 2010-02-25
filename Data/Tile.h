#import <Foundation/Foundation.h>

typedef enum {
	tileNone, tileGrass, tileConcrete, tileRubble, tileWoodWall,
	tileWoodDoor, tileWoodFloor, tileWoodDoorOpen, tileWoodDoorSaloon, tileWoodDoorBroken,
	tilePit, tileSlopeDown, tileSlopeUp, tileRockWall, tileLichen,
	tileGroundCrumbling, tileStoneCrumbling, tileStairsToOrcMines
} tileType;

typedef enum {
	slopeNone, slopeUp, slopeDown, slopeToOrc, slopeToTown
} slopeType;

@interface Tile : NSObject {
	bool blockShoot;
	bool blockMove;
	bool smashable;
	tileType type;
	slopeType slope;

	int x, y, z;

	// level gen
	int placementOrder;
	bool cornerWall;
}

// DEPRECATION WARNING! instead of changing these manually, use initWithType:
@property (nonatomic) bool blockShoot;
@property (nonatomic) bool blockMove;
@property (nonatomic) bool smashable;
@property (nonatomic) tileType type;
@property (nonatomic) slopeType slope;

@property (nonatomic) int x;
@property (nonatomic) int y;
@property (nonatomic) int z;

// level gen
@property (nonatomic) int placementOrder;
@property (nonatomic) bool cornerWall;

+ (void) initialize;
+ (UIImage*) imageForType:(tileType)type;
- (Tile*) initWithTileType: (tileType) _type;

@end
