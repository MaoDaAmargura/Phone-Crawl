#import <Foundation/Foundation.h>

typedef enum {FIRE = 0,COLD = 1,LIGHTNING = 2,POISON = 3,DARK = 4} elemType;

//Items can always go in Bag, need non-bag slot to go in more
#define NUM_ARMOR_TYPES 2
typedef enum {
    HEAD = 0,
    CHEST = 1,
    LEFT = 2,
	RIGHT = 3,
    BOTH = 4,
    EITHER = 5,
    BAG = 6
} slotType;

@interface Coord : NSObject <NSCopying> {
	int X;
	int Y;
	int Z;
   
   // for pathfinding
   int distance;
}

@property (nonatomic) int X;
@property (nonatomic) int Y;
@property (nonatomic) int Z;
@property (nonatomic) int distance;

- (BOOL) equals:(Coord*)other;

+ (Coord*) withX:(int)x Y:(int)y Z:(int)z;

@end

@interface Rand : NSObject {
	;
}

+ (int) min: (int) lowBound max: (int) highBound;

@end


@interface Util : NSObject {
	;
}
+ (int) point_distanceX1:(int)x1 Y1:(int)y1 X2:(int)x2 Y2:(int)y2;

@end

