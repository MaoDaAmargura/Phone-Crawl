#import <Foundation/Foundation.h>

#define MAX_DUNGEON_LEVEL 4
#define MIN_DUNGEON_LEVEL 0

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
   int pathing_distance;
	Coord *pathing_parentCoord;
}

@property (nonatomic) int X;
@property (nonatomic) int Y;
@property (nonatomic) int Z;
@property (nonatomic) int pathing_distance;
@property (nonatomic, retain) Coord *pathing_parentCoord; // I don't think this needs retain. Not sure though.

- (BOOL) equals:(Coord*)other;
- (id) copyWithZone: (NSZone*) zone;

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

+ (int) maxValueOfX:(int)x andY:(int)y;
+ (int) minValueOfX:(int)x andY:(int)y;

+ (int) point_distanceC1:(Coord *)c1 C2:(Coord *)c2;
+ (int) point_distanceX1:(int)x1 Y1:(int)y1 X2:(int)x2 Y2:(int)y2;

@end

