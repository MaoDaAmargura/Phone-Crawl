#import <Foundation/Foundation.h>

typedef enum {
	tileNone, tileGrass, tileConcrete, tileDirt, tileWoodWall,
	tileWoodDoor,
	tileRockFloor, tileRockWall
} tileType;

@interface Tile : NSObject {
	bool blockShoot;
	bool blockMove;
	bool smashable;
	tileType type;
}
@property (nonatomic) bool blockShoot;
@property (nonatomic) bool blockMove;
@property (nonatomic) bool smashable;
@property (nonatomic) tileType type;

+ (void) initialize;
+ (UIImage*) imageForType:(tileType)type;

@end
