#import <Foundation/Foundation.h>

#define MAX_DUNGEON_LEVEL 4
#define MIN_DUNGEON_LEVEL 0

typedef enum {FIRE = 0,COLD = 1,LIGHTNING = 2,POISON = 3,DARK = 4} elemType;

#define NUM_COMBAT_ABILITY_TYPES 2

typedef enum {
	REG_STRIKE = 0,
	HEAVY_STRIKE = 1
} PC_COMBAT_ABILITY_TYPE;

#define NUM_PC_SPELL_TYPES 10
typedef enum {
	FIREDAMAGE = 0,
	FIRECONDITION = 1,
	COLDDAMAGE = 2,
	COLDCONDITION = 3,
	LIGHTNINGDAMAGE = 4,
	LIGHTNINGCONDITION = 5,
	POISONDAMAGE = 6,
	POISONCONDITION = 7,
	DARKDAMAGE = 8,
	DARKCONDITION = 9
} PC_SPELL_TYPE; // For use by spellbook field in creature.h

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
+ (int) point_distanceX1:(int)x1 Y1:(int)y1 X2:(int)x2 Y2:(int)y2;

@end

