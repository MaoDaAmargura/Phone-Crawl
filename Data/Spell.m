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

- (id) initWithInfo: (NSString *) in_name spell_type: (spellType) in_spell_type target_type: (targetType) in_target_type elem_type: (elemType) in_elem_type
		  mana_cost: (int) in_mana_cost damage: (int) in_damage range: (int) in_range spell_level: (int) in_spell_level spell_id: (int) in_spell_id
		   spell_fn: (IMP) in_spell_fn {
	
	if(self = [super init])
	{
		name = in_name;
	    spell_type = in_spell_type;
		target_type = in_target_type; 
		elem_type = in_elem_type;
		mana_cost = in_mana_cost;
		damage = in_damage;
		range = in_range; 
		spell_level = in_spell_level; 
		spell_id = in_spell_id;
		spell_fn = in_spell_fn;
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

	switch (spell_type) {
		case DAMAGE:
			if ([self Resist_Check:caster target:target]) 
				return [self detr_spell:caster target:target];
			else return @"Target resisted spell!";

			break;
		case CONDITION:
			if ([self Resist_Check:caster target:target]) 
				return [self cond_spell:caster target:target];
			else return @"Target resisted spell!";

		case ITEM:
			return [self spell_fn: caster target: target];
		default:
			break;
	};
	return @"Spell cast error!";
};

- (BOOL) Resist_Check: (Creature *) caster target: (Creature *) target {
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
		return FALSE;
	return TRUE;
}

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
	return [NSString stringWithFormat:@"Added <%s> to <%s>",name,
			target.name];
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
				[caster Heal:damage];
				break;
		}
	}
	return [NSString stringWithFormat:@"<%s> hit for <%d> points of damage!",name,
			target.name];
};

- (NSString *) heal_potion: (Creature *) caster target: (Creature *) target {
	[target Heal: damage];
	return [NSString stringWithFormat:@"Healed for <%d> health points!",damage];
}

- (NSString *) mana_potion: (Creature *) caster target: (Creature *) target {
	[target Mana_Heal: damage];
	return [NSString stringWithFormat:@"<%d> mana points replenished!",damage];
}
	
- (NSString *) wand: (Creature *) caster target: (Creature *) target {
	if ([self Resist_Check:caster target:target]) 
		return [self detr_spell:caster target:target];
	else return @"Target resisted spell!";
}
	
- (NSString *) scroll: (Creature *) caster target: (Creature *) target {
	++caster.ability_points;
	return @"You gained an ability point!";
}

+ (void) initialize {
	[super initialize];
	int id_cnt = 0, spell_lvl = 1;
	IMP scroll = [Spell methodForSelector:@selector(scroll:target:)];
	IMP heal_potion = [Spell methodForSelector:@selector(heal_potion:target:)];
	IMP mana_potion = [Spell methodForSelector:@selector(mana_potion:target:)];
	IMP wand = [Spell methodForSelector:@selector(wand:target:)];
	
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Tome of Knowledge" spell_type:ITEM target_type:SINGLE elem_type:DARK mana_cost:0 damage:0 range:MAX_BOW_RANGE
										  spell_level:1 spell_id:id_cnt++ spell_fn:scroll]];
	
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Healing Potion" spell_type:ITEM target_type:SINGLE elem_type:DARK mana_cost:0 damage:100 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5+1 spell_id:id_cnt++ spell_fn:heal_potion]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Lesser Healing Potion" spell_type:ITEM target_type:SINGLE elem_type:DARK mana_cost:0 damage:200 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5+1 spell_id:id_cnt++ spell_fn:heal_potion]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Healing Potion" spell_type:ITEM target_type:SINGLE elem_type:DARK mana_cost:0 damage:300 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5+1 spell_id:id_cnt++ spell_fn:heal_potion]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Major Healing Potion" spell_type:ITEM target_type:SINGLE elem_type:DARK mana_cost:0 damage:400 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5+1 spell_id:id_cnt++ spell_fn:heal_potion]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Superior Healing Potion" spell_type:ITEM target_type:SINGLE elem_type:DARK mana_cost:0 damage:500 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5+1 spell_id:id_cnt++ spell_fn:heal_potion]];
	
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Mana Potion" spell_type:ITEM target_type:SINGLE elem_type:DARK mana_cost:0 damage:100 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5+1 spell_id:id_cnt++ spell_fn:mana_potion]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Lesser Mana Potion" spell_type:ITEM target_type:SINGLE elem_type:DARK mana_cost:0 damage:200 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5+1 spell_id:id_cnt++ spell_fn:mana_potion]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Mana Potion" spell_type:ITEM target_type:SINGLE elem_type:DARK mana_cost:0 damage:300 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5+1 spell_id:id_cnt++ spell_fn:mana_potion]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Major Mana Potion" spell_type:ITEM target_type:SINGLE elem_type:DARK mana_cost:0 damage:400 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5+1 spell_id:id_cnt++ spell_fn:mana_potion]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Superior Mana Potion" spell_type:ITEM target_type:SINGLE elem_type:DARK mana_cost:0 damage:500 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5+1 spell_id:id_cnt++ spell_fn:mana_potion]];
	
	
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Fireball" spell_type:DAMAGE target_type:SINGLE elem_type:FIRE mana_cost:50 damage:50 range:MAX_BOW_RANGE 
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Lesser Fireball" spell_type:DAMAGE target_type:SINGLE elem_type:FIRE mana_cost:50 damage:50 range:MAX_BOW_RANGE 
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Fireball" spell_type:DAMAGE target_type:SINGLE elem_type:FIRE mana_cost:50 damage:50 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Major Fireball" spell_type:DAMAGE target_type:SINGLE elem_type:FIRE mana_cost:50 damage:50 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Superior Fireball" spell_type:DAMAGE target_type:SINGLE elem_type:FIRE mana_cost:50 damage:50 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Frostbolt" spell_type:DAMAGE target_type:SINGLE elem_type:COLD mana_cost:50 damage:50 range:MAX_BOW_RANGE
										 spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Lesser Frostbolt" spell_type:DAMAGE target_type:SINGLE elem_type:COLD mana_cost:50 damage:50 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Frostbolt" spell_type:DAMAGE target_type:SINGLE elem_type:COLD mana_cost:50 damage:50 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Major Frostbolt" spell_type:DAMAGE target_type:SINGLE elem_type:COLD mana_cost:50 damage:50 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Superior Frostbolt" spell_type:DAMAGE target_type:SINGLE elem_type:COLD mana_cost:50 damage:50 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Shock" spell_type:DAMAGE target_type:SINGLE elem_type:LIGHTNING mana_cost:50 damage:70 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Lesser Shock" spell_type:DAMAGE target_type:SINGLE elem_type:LIGHTNING mana_cost:50 damage:70 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Shock" spell_type:DAMAGE target_type:SINGLE elem_type:LIGHTNING mana_cost:50 damage:70 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Major Shock" spell_type:DAMAGE target_type:SINGLE elem_type:LIGHTNING mana_cost:50 damage:70 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Superior Shock" spell_type:DAMAGE target_type:SINGLE elem_type:LIGHTNING mana_cost:50 damage:70 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Poisoning" spell_type:DAMAGE target_type:SINGLE elem_type:POISON mana_cost:40 damage:40 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Lesser Poisoning" spell_type:DAMAGE target_type:SINGLE elem_type:POISON mana_cost:40 damage:40 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Poisoning" spell_type:DAMAGE target_type:SINGLE elem_type:POISON mana_cost:40 damage:40 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Major Poisoning" spell_type:DAMAGE target_type:SINGLE elem_type:POISON mana_cost:40 damage:40 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Superior Poisoning" spell_type:DAMAGE target_type:SINGLE elem_type:POISON mana_cost:40 damage:40 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Drain" spell_type:DAMAGE target_type:SINGLE elem_type:DARK mana_cost:50 damage:30 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Drain" spell_type:DAMAGE target_type:SINGLE elem_type:DARK mana_cost:50 damage:30 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Drain" spell_type:DAMAGE target_type:SINGLE elem_type:DARK mana_cost:50 damage:30 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Drain" spell_type:DAMAGE target_type:SINGLE elem_type:DARK mana_cost:50 damage:30 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Drain" spell_type:DAMAGE target_type:SINGLE elem_type:DARK mana_cost:50 damage:30 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:nil]];
	
	//Wand spells
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Fireball" spell_type:DAMAGE target_type:SINGLE elem_type:FIRE mana_cost:0 damage:50 range:MAX_BOW_RANGE 
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Lesser Fireball" spell_type:DAMAGE target_type:SINGLE elem_type:FIRE mana_cost:0 damage:50 range:MAX_BOW_RANGE 
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Fireball" spell_type:DAMAGE target_type:SINGLE elem_type:FIRE mana_cost:0 damage:50 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Major Fireball" spell_type:DAMAGE target_type:SINGLE elem_type:FIRE mana_cost:0 damage:50 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Superior Fireball" spell_type:DAMAGE target_type:SINGLE elem_type:FIRE mana_cost:0 damage:50 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Frostbolt" spell_type:DAMAGE target_type:SINGLE elem_type:COLD mana_cost:0 damage:50 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Lesser Frostbolt" spell_type:DAMAGE target_type:SINGLE elem_type:COLD mana_cost:0 damage:50 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Frostbolt" spell_type:DAMAGE target_type:SINGLE elem_type:COLD mana_cost:0 damage:50 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Major Frostbolt" spell_type:DAMAGE target_type:SINGLE elem_type:COLD mana_cost:0 damage:50 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Superior Frostbolt" spell_type:DAMAGE target_type:SINGLE elem_type:COLD mana_cost:0 damage:50 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Shock" spell_type:DAMAGE target_type:SINGLE elem_type:LIGHTNING mana_cost:0 damage:70 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Lesser Shock" spell_type:DAMAGE target_type:SINGLE elem_type:LIGHTNING mana_cost:0 damage:70 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Shock" spell_type:DAMAGE target_type:SINGLE elem_type:LIGHTNING mana_cost:0 damage:70 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Major Shock" spell_type:DAMAGE target_type:SINGLE elem_type:LIGHTNING mana_cost:0 damage:70 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Superior Shock" spell_type:DAMAGE target_type:SINGLE elem_type:LIGHTNING mana_cost:0 damage:70 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Poisoning" spell_type:DAMAGE target_type:SINGLE elem_type:POISON mana_cost:0 damage:40 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Lesser Poisoning" spell_type:DAMAGE target_type:SINGLE elem_type:POISON mana_cost:0 damage:40 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Poisoning" spell_type:DAMAGE target_type:SINGLE elem_type:POISON mana_cost:0 damage:40 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Major Poisoning" spell_type:DAMAGE target_type:SINGLE elem_type:POISON mana_cost:0 damage:40 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Superior Poisoning" spell_type:DAMAGE target_type:SINGLE elem_type:POISON mana_cost:0 damage:40 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Drain" spell_type:DAMAGE target_type:SINGLE elem_type:DARK mana_cost:0 damage:30 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Drain" spell_type:DAMAGE target_type:SINGLE elem_type:DARK mana_cost:0 damage:30 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Drain" spell_type:DAMAGE target_type:SINGLE elem_type:DARK mana_cost:0 damage:30 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Drain" spell_type:DAMAGE target_type:SINGLE elem_type:DARK mana_cost:0 damage:30 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	[spell_list addObject:[[Spell alloc] initWithInfo:@"Minor Drain" spell_type:DAMAGE target_type:SINGLE elem_type:DARK mana_cost:0 damage:30 range:MAX_BOW_RANGE
										  spell_level:spell_lvl++%5 + 1 spell_id:id_cnt++ spell_fn:wand]];
	
}

@end