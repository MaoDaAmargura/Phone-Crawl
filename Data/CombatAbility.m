//
//  CombatAbility.m
//  Phone-Crawl
//
//  Created by Benjamin Sangster on 2/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CombatAbility.h"
#define LEVEL_DIFF_MULT 2

@implementation CombatAbility

@synthesize name;
@synthesize ability_id;


- (id) initWithInfo: (NSString *) in_name damage: (int) in_damage ability_level: (int) in_ability_level 
		 ability_id: (int) in_ability_id ability_fn: (SEL) in_ability_fn {
	if (self = [super init]) {
		name = in_name;
		damage = in_damage;
		ability_level = in_ability_level;
		ability_fn = in_ability_fn;
		return self;
	}
	return nil;
}

- (int) use_ability: (Creature *) caster target: (Creature *) target 
{
	if([self respondsToSelector:ability_fn])
	{
		IMP f = [self methodForSelector:ability_fn];
		return (int)(f)(self, ability_fn, caster, target);
	}
	
	return 0;
}

+ (int) use_ability_id: (int) in_ability_id caster: (Creature *) caster target: (Creature *) target {
	return [[ability_list objectAtIndex: in_ability_id] cast:caster target:target];
};

- (int) mitigate_damage:(Creature *)caster target:(Creature *)target damage: (int) amt_damage {
	int resist = target.armor;
	if (resist > STAT_MAX) {
		resist = STAT_MAX;
	} else if (resist < STAT_MIN) {
		resist = STAT_MIN;
	}
	int level_diff = caster.level - target.level;
	if(level_diff < 0)
		resist = STAT_MAX - resist * LEVEL_DIFF_MULT / level_diff;
	else if(level_diff > 0)
		resist = resist * LEVEL_DIFF_MULT / level_diff;
	return amt_damage * resist / 100;
}

//Specialized ability function example
- (int) detr_ability: (Creature *) caster target: (Creature *) target {
	return [self mitigate_damage:caster target:target damage: (damage + [caster weapon_damage])];
}

+ (void) initialize {
	[super initialize];
	int id_cnt = 0, ability_lvl = 1;
	SEL detr = @selector(detr_ability:target:);

	
	
#define ADD_ABILITY(NAME,DMG,FN) [ability_list addObject:[[[CombatAbility alloc] initWithInfo:NAME damage:DMG \
									ability_level:ability_lvl++%3+1 ability_id:id_cnt++ ability_fn:FN] autorelease]]
	
	ADD_ABILITY(@"Default Strike",80,detr);
	ADD_ABILITY(@"Dildonic Strike of Death",1000000,detr);
}

@end
