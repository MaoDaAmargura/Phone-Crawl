#define kMapDimension 120
#define kMapDepth 5
#import "Tile.h"

@class Coord;		// defined in Util
@class Tile;


#pragma mark -

@interface Dungeon : NSObject {
	;
}
- (Dungeon*) initWithType: (levelType) lvlType;
- (Tile*) tileAtX: (int) x Y: (int) y Z: (int) z;
- (Coord*) playerLocation;

@end
