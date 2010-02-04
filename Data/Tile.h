#import <Foundation/Foundation.h>

typedef enum {
	tileNone, tileGrass, tileConcrete, tileRubble, tileWoodWall,
	tileWoodDoor, tileWoodFloor, tileWoodDoorOpen, tileWoodDoorSaloon, tileWoodDoorBroken,
	tilePit, tileSlopeDown, tileSlopeUp,
	tileRockFloor, tileRockWall		// FIXME import images on this line
} tileType;

@interface Tile : NSObject {
	bool blockShoot;
	bool blockMove;
	bool smashable;
	tileType type;

	// level gen
	int placementOrder;
	bool cornerWall;
}

// DEPRECATION WARNING! instead of changing these manually, use initWithType:
@property (nonatomic) bool blockShoot;
@property (nonatomic) bool blockMove;
@property (nonatomic) bool smashable;
@property (nonatomic) tileType type;


// level gen
@property (nonatomic) int placementOrder;
@property (nonatomic) bool cornerWall;

+ (void) initialize;
+ (UIImage*) imageForType:(tileType)type;
- (Tile*) initWithTileType: (tileType) _type;

@end
