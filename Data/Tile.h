#import <Foundation/Foundation.h>

typedef enum {
	tileNone, tileGrass, tileConcrete, tileRubble, tileWoodWall,
	tileWoodDoor, tileWoodFloor, tileWoodDoorOpen, tileWoodDoorSaloon, tileWoodDoorBroken,
	tilePit, tileSlopeDown, tileSlopeUp,
	tileRockFloor, tileRockWall		// FIXME import images on this line
} tileType;

typedef enum {
	slopeNone, slopeUp, slopeDown
} slopeType;

@interface Tile : NSObject {
	bool blockShoot;
	bool blockMove;
	bool smashable;
	tileType type;
	slopeType slope;

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

// level gen
@property (nonatomic) int placementOrder;
@property (nonatomic) bool cornerWall;

+ (void) initialize;
+ (UIImage*) imageForType:(tileType)type;
- (Tile*) initWithType: (tileType) _type;

@end
