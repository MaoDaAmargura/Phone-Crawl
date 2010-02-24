#import <Foundation/Foundation.h>

#define ABILITY_ERR -1

extern NSMutableArray* ability_list;

@class Creature;
@interface CombatAbility : NSObject {

	NSString *name;
	int damage;
	int ability_level; //Novice, Journeyman, Master
	int ability_id; //Index in combat_list
	SEL ability_fn;
	int ability_points;
}

+ (void) fill_ability_list;
+ (void) use_ability_id: (int) in_ability_id caster: (Creature *) caster target: (Creature *) target;
- (void) use_ability: (Creature *) caster target: (Creature *) target;

- (id) initWithInfo: (NSString *) in_name damage: (int) in_damage ability_level: (int) in_ability_level 
		 ability_id: (int) in_ability_id ability_fn: (SEL) in_ability_fn points:(int)abilitypnts;
	

- (int) mitigate_damage: (Creature *) caster target: (Creature *) target damage: (int) amount_damage;


//Specialized ability function example
- (void) detr_ability: (Creature *) caster target: (Creature *) target;
- (void) basicAttack:(Creature *)attacker def:(Creature *)defender;
- (void) elementalAttack:(Creature *)attacker def:(Creature *)defender;

@property (readonly) NSString *name;
@property (readonly) int ability_id;
@property (readonly) int damage;
@property (readonly) int ability_level;
@property (readonly) int ability_points;

@end
