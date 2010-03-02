#import <Foundation/Foundation.h>

#define ABILITY_ERR -1

extern NSMutableArray* abilityList;

@class Creature;
@interface CombatAbility : NSObject {

	NSString *name;
	int damage;
	int abilityLevel; //Novice, Journeyman, Master
	int abilityId; //Index in combat_list
	SEL abilityFn;
	int turnPoints;
	int turnPointCost;
}

+ (void) fillAbilityList;
+ (NSString *) useAbilityWithId: (int) desiredAbilityId caster: (Creature *) caster target: (Creature *) target;
- (NSString *) useAbility: (Creature *) caster target: (Creature *) target;

- (id) initWithInfo: (NSString *) abilityName damage: (int) abilityDamage abilityLevel: (int) level 
		 abilityId: (int) desiredId abilityFn: (SEL) fn points:(int)turnPnts
		 turnPoints:(int) turnPntCost;
	

- (int) mitigateDamage: (Creature *) caster target: (Creature *) target damage: (int) amountDamage;


//Specialized ability function example
- (int) defaultAbility: (Creature *) caster target: (Creature *) target;
- (int) basicAttack:(Creature *)attacker def:(Creature *)defender;
- (int) elementalAttack:(Creature *)attacker def:(Creature *)defender;

@property (readonly) NSString *name;
@property (readonly) int abilityId;
@property (readonly) int damage;
@property (readonly) int abilityLevel;
@property (readonly) int turnPoints;
@property (readonly) int turnPointCost;

@end
