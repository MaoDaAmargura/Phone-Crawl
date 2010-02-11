#import <Foundation/Foundation.h>

typedef enum {FIRE,COLD,LIGHTNING,POISON,DARK} elemType;

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

@interface Coord : NSObject {
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

- (id) init;

- (BOOL) equals:(Coord*)other;

+ (Coord*) withX:(int)x Y:(int)y Z:(int)z;

@end

@interface Rand : NSObject {
	;
}

+ (int) min: (int) lowBound max: (int) highBound;

@end
