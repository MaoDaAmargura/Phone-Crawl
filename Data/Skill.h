#import <Foundation/Foundation.h>

#define ABILITY_ERR -1

#define NUM_SKILL_TYPES 6
#define NUM_PLAYER_SKILL_TYPES 5

typedef enum {
	REG_STRIKE = 0,
	QUICK_STRIKE = 1,
	BRUTE_STRIKE = 2,
	ELE_STRIKE = 3,
	MIX_STRIKE = 4,
	SHITTY_STRIKE = 5	// should not be available to player
} PC_COMBAT_ABILITY_TYPE;


#import "Util.h"

@class Critter;

@interface Skill : NSObject {

	NSString *name;
	float damageMultiplier;
	int abilityLevel; //Novice, Journeyman, Master
	int abilityId; //Index in combat_list
	SEL abilityFn;
	int turnPointCost;
}

//+ (void) fillAbilityList;
+ (NSString *) useAbilityWithId: (int) desiredAbilityId caster: (Critter *) caster target: (Critter *) target;
- (NSString *) useAbility: (Critter *) caster target: (Critter *) target;

- (id) initWithInfo: (NSString *) abilityName damageMultiplier: (float) abilityDamage abilityLevel: (int) level 
		 abilityId: (int) desiredId abilityFn: (SEL) fn turnPoints:(int) turnPntCost;
	

- (int) mitigateDamage: (Critter *) caster target: (Critter *) target damage: (int) amountDamage;


//Specialized ability function example
- (int) basicAttack:(Critter *)attacker def:(Critter *)defender;
- (int) elementalAttack:(Critter *)attacker def:(Critter *)defender;
- (int) defaultStrike: (Critter *) caster target: (Critter *) target;
- (int) elementalStrike:(Critter *)attacker target:(Critter *)defender;
- (int) mixedStrike:(Critter *)attacker target:(Critter *)defender;

+ (void) initialize;
+ (Skill*) skillOfType:(PC_COMBAT_ABILITY_TYPE)type level: (int)lvl;

@property (readonly, retain) NSString *name;
@property (readonly) int abilityId;
@property (readonly) float damageMultiplier;
@property (readonly) int abilityLevel;
@property (readonly) int turnPointCost;

@end
