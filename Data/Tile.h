#import <Foundation/Foundation.h>

typedef enum {
	tileNone, tileGrass, tileConcrete, tileDirt, tileWoodWall,
	tileWoodDoor, tileWoodFloor,
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
@property (nonatomic) bool blockShoot;
@property (nonatomic) bool blockMove;
@property (nonatomic) bool smashable;
@property (nonatomic) tileType type;


// level gen
@property (nonatomic) int placementOrder;
@property (nonatomic) bool cornerWall;

+ (void) initialize;
+ (UIImage*) imageForType:(tileType)type;

@end
