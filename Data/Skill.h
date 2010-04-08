//	the Skill class is designed to hold data on a specific
//	combat ability

#import <Foundation/Foundation.h>

#define ABILITY_ERR -1

#define NUM_SKILL_TYPES 6
#define NUM_PLAYER_SKILL_TYPES 5

// typedef for list of combat ability IDs
typedef enum {
	REG_STRIKE = 0,
	QUICK_STRIKE = 1,
	BRUTE_STRIKE = 2,
	ELE_STRIKE = 3,
	MIX_STRIKE = 4
} PC_COMBAT_ABILITY_TYPE;


#import "Util.h"

@class Critter;

// interface for Skill
@interface Skill : NSObject {
	// name of skill
	NSString *name;
	// damage of skill
	float damageMultiplier;
	// abilityLevel
	int abilityLevel; //Novice, Journeyman, Master
	// abilityId, index in combat_list for Critter
	int abilityId;
	// function that this ability will call when it is used
	SEL abilityFn;
	// how much this ability costs in turn pints
	int turnPointCost;
}

// use functions
+ (NSString *) useAbilityWithId: (int) desiredAbilityId caster: (Critter *) caster target: (Critter *) target;
- (NSString *) useAbility: (Critter *) caster target: (Critter *) target;

// init functions
- (id) initWithInfo: (NSString *) abilityName damageMultiplier: (float) abilityDamage abilityLevel: (int) level 
		 abilityId: (int) desiredId abilityFn: (SEL) fn turnPoints:(int) turnPntCost;
+ (void) initialize;
// creates a skill with a given type and level
+ (Skill*) skillOfType:(PC_COMBAT_ABILITY_TYPE)type level: (int)lvl;
	
// checks to see how much damage will be done, taking armor into account
- (int) mitigateDamage: (Critter *) caster target: (Critter *) target damage: (int) amountDamage;


//Specialized ability functions
- (int) basicAttack:(Critter *)attacker def:(Critter *)defender;
- (int) elementalAttack:(Critter *)attacker def:(Critter *)defender;
- (int) defaultStrike: (Critter *) caster target: (Critter *) target;
- (int) elementalStrike:(Critter *)attacker target:(Critter *)defender;
- (int) mixedStrike:(Critter *)attacker target:(Critter *)defender;



// getter and setter methods
@property (readonly, retain) NSString *name;
@property (readonly) int abilityId;
@property (readonly) float damageMultiplier;
@property (readonly) int abilityLevel;
@property (readonly) int turnPointCost;

@end
