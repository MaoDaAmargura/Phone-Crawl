#import <Foundation/Foundation.h>
#import "Creature.h"
#import "Util.h" // for elemType
#import "Item.h"
#import "CombatAbility.h"
#include <stdlib.h>

//typedef enum {
//	QUICK_ATTACK,
//	STANDARD_ATTACK,
//	FATAL_SWING
//} Action;

@interface Battle : NSObject {
	
}

+ (void)doAttack:(Creature *)attacker :(Creature *)defender :(CombatAbility)action;
+ (float)getDamage:(CombatAbility)action;

@end
