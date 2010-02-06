//
//  CombatAbility.h
//  Phone-Crawl
//
//  Created by Benjamin Sangster on 2/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Creature.h"

NSMutableArray *ability_list;

@class Creature;
@interface CombatAbility : NSObject {
	NSString *name;
	int damage;
	int ability_level; //Novice, Journeyman, Master
	int ability_id; //Index in combat_list
	IMP ability_fn;
}

+ (int) use_ability_id: (int) in_ability_id caster: (Creature *) caster target: (Creature *) target;
- (int) use_ability: (Creature *) caster target: (Creature *) target;

- (id) initWithInfo: (NSString *) in_name damage: (int) in_damage ability_level: (int) in_ability_level 
		 ability_id: (int) in_ability_id ability_fn: (IMP) in_ability_fn;
	

- (int) mitigate_damage: (Creature *) caster target: (Creature *) target damage: (int) amount_damage;


//Specialized ability function example
- (int) detr_ability: (Creature *) caster target: (Creature *) target;


@property (readonly) NSString *name;
@property (readonly) int ability_id;

@end
