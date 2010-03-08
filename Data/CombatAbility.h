#import <Foundation/Foundation.h>

#define ABILITY_ERR -1

extern NSMutableArray* abilityList;

@class Creature;
@interface CombatAbility : NSObject {

	NSString *name;
	float damageMultiplier;
	int abilityLevel; //Novice, Journeyman, Master
	int abilityId; //Index in combat_list
	SEL abilityFn;
	int turnPointCost;
}

+ (void) fillAbilityList;
+ (NSString *) useAbilityWithId: (int) desiredAbilityId caster: (Creature *) caster target: (Creature *) target;
- (NSString *) useAbility: (Creature *) caster target: (Creature *) target;

- (id) initWithInfo: (NSString *) abilityName damageMultiplier: (float) abilityDamage abilityLevel: (int) level 
		 abilityId: (int) desiredId abilityFn: (SEL) fn turnPoints:(int) turnPntCost;
	

- (int) mitigateDamage: (Creature *) caster target: (Creature *) target damage: (int) amountDamage;


//Specialized ability function example
- (int) basicAttack:(Creature *)attacker def:(Creature *)defender;
- (int) elementalAttack:(Creature *)attacker def:(Creature *)defender;
- (int) defaultStrike: (Creature *) caster target: (Creature *) target;
- (int) elementalStrike:(Creature *)attacker target:(Creature *)defender;
- (int) mixedStrike:(Creature *)attacker target:(Creature *)defender;

@property (readonly, retain) NSString *name;
@property (readonly) int abilityId;
@property (readonly) float damageMultiplier;
@property (readonly) int abilityLevel;
@property (readonly) int turnPointCost;

@end
