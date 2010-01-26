#import <Foundation/Foundation.h>

typedef enum {
	tileNone, tileGrass, tileConcrete, tileDirt, tileWood, tileRockFloor, tileRockWall
} tileType;

@interface Tile : NSObject {
	bool blockView;
	bool blockMove;
	tileType type;
}
@property (nonatomic) bool blockView;
@property (nonatomic) bool blockMove;
@property (nonatomic) tileType type;

+ (void) initialize;
+ (UIImage*) imageForType:(tileType)type;

@end
