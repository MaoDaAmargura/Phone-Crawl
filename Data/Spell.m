//
//  Spell.m
//  Phone-Crawl
//
//  Created by Benjamin Sangster on 1/23/10. 
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Spell.h"

//Spell spell_list[NUM_SPELLS];
BOOL have_set_spells = FALSE;

#define LEVEL_DIFF_MULT 2

@implementation Spell

- (id) init 
{
	if(self = [super init])
	{
		if(!have_set_spells)
			[Spell BuildSpellSet];
		return self;
	}
	return nil;
}

+ (void) BuildSpellSet
{
	//Fill spell_list with Spell* pointers to all of the spells from pre-made data
	//have_set_spells = TRUE
}

//FIRE,COLD,LIGHTNING,POISON,DARK
- (NSString *) cast : (Creature *) caster target: (Creature *) target {
	if(target.curr_mana < mana_cost)
		return @"Not enough mana to cast this spell!";
	int resist;
	switch (elem_type) {
		case FIRE:
			resist = target.fire;
			break;
		case COLD:
			resist = target.cold;
			break;
		case LIGHTNING:
			resist = target.lightning;
			break;
		case POISON:
			resist = target.poison;
			break;
		case DARK:
			resist = target.dark;
			break;
	}
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
	if((arc4random() % (STAT_MAX + 1)) <= resist)
		return @"Target resisted spell";
	
	switch (spell_type) {
		case DAMAGE:
			return [self detr_spell:caster target:target];
			break;
		case CONDITION:
			return [self cond_spell:caster target:target];
			break;
		default:
			break;
	};
	return @"Spell cast error!";
};

- (NSString *) cond_spell:(Creature *)caster target:(Creature *)target {
	caster.curr_mana = (caster.curr_mana - mana_cost) < 0 ? 0 : (caster.curr_mana - mana_cost);
	switch (elem_type) {
		case FIRE:
			[target Add_Condition:FIRE_HASTE];
			break;
		case COLD:
			[target Add_Condition:COLD_SLOW];
			break;
		case LIGHTNING:
			[target Clear_Condition];
			[target Take_Damage:damage];
			break;
		case POISON:
			[target Add_Condition:WEAKENED];
			// Max health debuff...how to store original max_hp and update new one? Do in combat system?
			// Max health is formulaically calculated -- have a check that does if(weakened) reset_max_hp?
			break;
		case DARK:
			[target Add_Condition:CONFUSION];
			//See note about Max health debuff
			break;
	}
	return @"Added <condition> to <target>";
}

//Return string listing damage and if condition was added to target
//Add formatted string creation for return
- (NSString *) detr_spell: (Creature *) caster target: (Creature *) target {
	caster.curr_mana = (caster.curr_mana - mana_cost) < 0 ? 0 : (caster.curr_mana - mana_cost);
	[target Take_Damage:damage];
	if ((arc4random() % STAT_MAX + 1) > 10 * spell_level ) {
		switch (elem_type) {
			case FIRE:
				[target Add_Condition:BURNED];
				break;
			case COLD:
				[target Add_Condition:CHILLED];
				break;
			case LIGHTNING:
				[target Add_Condition:HASTENED];
				break;
			case POISON:
				[target Add_Condition:POISONED];
				break;
			case DARK:
				[target Add_Condition:CURSED];
				break;
		}
	}
	return @"<Spell> hit for <damage> points of damage!";
};
	
@end

