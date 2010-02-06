#import "Spell.h"

//Spell spell_list[NUM_SPELLS];
BOOL have_set_spells = FALSE;
#define LEVEL_DIFF_MULT 2

@implementation Spell

@synthesize name;
@synthesize range;
@synthesize target_type;
@synthesize spell_id;

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

- (int) cast: (Creature *) caster target: (Creature *) target {
	if(target.curr_mana < mana_cost)
		return ERR_NO_MANA;
	
	caster.curr_mana = (caster.curr_mana - mana_cost) < 0 ? 0 : (caster.curr_mana - mana_cost);
	if ([self Resist_Check:caster target:target]) {
		
		//The warning generated here is meaningless, because spells will ALWAYS have a return
		//If someone knows the proper pragma to get rid of the warning, please insert it.
		//Otherwise, ignore this warning please, or rewrite the line to return the value of the function
		//in a way that doesn't cause the warning.
		return [self spell_fn:caster target:target];
	}
	return ERR_RESIST;
}

+ (int) cast_id: (int) in_spell_id caster: (Creature *) caster target: (Creature *) target {
	return [[spell_list objectAtIndex: in_spell_id] cast:caster target:target];
};

- (BOOL) Resist_Check: (Creature *) caster target: (Creature *) target {
	if (caster == target) return TRUE;
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
	if([Rand min:0 max:(arc4random() % (STAT_MAX + 1))] <= resist)
		return FALSE;
	return TRUE;
}

//Return string listing damage and if condition was added to target
//Add formatted string creation for return
- (int) detr_spell: (Creature *) caster target: (Creature *) target {
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
	return damage;
};

- (int) heal_potion: (Creature *) caster target: (Creature *) target {
	[caster Heal: damage];
	return SPELL_NO_DAMAGE;
}

- (int) mana_potion: (Creature *) caster target: (Creature *) target {
	[caster Mana_Heal: damage];
	return SPELL_NO_DAMAGE;
}
	
- (int) scroll: (Creature *) caster target: (Creature *) target {
	++caster.ability_points;
	return SPELL_NO_DAMAGE;
}

- (int) haste: (Creature *) caster target: (Creature *) target {
	[caster Add_Condition:HASTENED];
	caster.turn_speed += caster.turn_speed * (damage/100.0); // Increase turn speed by percentage
	return SPELL_NO_DAMAGE;
}

- (int) freeze: (Creature *) caster target: (Creature *) target {
	[target Add_Condition:CHILLED];
	target.turn_speed -= target.turn_speed * (damage / 100.0); // Decrease turn speed by percentage
	return SPELL_NO_DAMAGE;
}

- (int) purge: (Creature *) caster target: (Creature *) target {
	[target Clear_Condition];
	//[target Take_Damage:damage];
	[caster Take_Damage:(damage / spell_level)];
	return damage;
}
	
- (int) taint: (Creature *) caster target: (Creature *) target {
	[target Add_Condition:WEAKENED];
	target.max_health -= target.max_health * (damage / 100.0); // Decrease max health by percentage
	target.max_shield -= target.max_shield * (damage / 100.0); // Decrease max shield by percentage
	return SPELL_NO_DAMAGE;
}

- (int) confusion: (Creature *) caster target: (Creature *) target {
	[target Add_Condition:CONFUSION];
	//What is confusion supposed to do?
	return SPELL_NO_DAMAGE;
}

+ (void) initialize {
	[super initialize];
	int id_cnt = 0, spell_lvl = 1;
	IMP scroll = [Spell methodForSelector:@selector(scroll:target:)];
	IMP heal_potion = [Spell methodForSelector:@selector(heal_potion:target:)];
	IMP mana_potion = [Spell methodForSelector:@selector(mana_potion:target:)];
	IMP detr = [Spell methodForSelector:@selector(detr_spell:target:)];
	IMP haste = [Spell methodForSelector:@selector(haste:target:)];
	IMP freeze = [Spell methodForSelector:@selector(freeze:target:)];
	IMP purge = [Spell methodForSelector:@selector(purge:target:)];
	IMP taint = [Spell methodForSelector:@selector(taint:target:)];
	IMP confusion = [Spell methodForSelector:@selector(confusion:target:)];
	
	
#define ADD_SPELL(NAME,TYPE,TARGET,ELEM,MANA,DMG,FN) [spell_list addObject:[[[Spell alloc] initWithInfo:NAME spell_type:TYPE target_type:TARGET\
														elem_type:ELEM mana_cost:MANA damage:DMG range:MAX_BOW_RANGE\
														spell_level:spell_lvl++%5+1 spell_id:id_cnt++ spell_fn:FN] autorelease]]
	
	[spell_list addObject:[[[Spell alloc] initWithInfo:@"Tome of Knowledge" spell_type:ITEM target_type:SINGLE 
											elem_type:DARK mana_cost:0 damage:0 range:MAX_BOW_RANGE
										  spell_level:1 spell_id:id_cnt++ spell_fn:scroll] autorelease]];
	
	ADD_SPELL(@"Minor Healing Potion",ITEM,SINGLE,DARK,0,100,heal_potion);
	ADD_SPELL(@"Lesser Healing Potion",ITEM,SINGLE,DARK,0,200,heal_potion);
	ADD_SPELL(@"Healing Potion",ITEM,SINGLE,DARK,0,300,heal_potion);
	ADD_SPELL(@"Major Healing Potion",ITEM,SINGLE,DARK,0,400,heal_potion);
	ADD_SPELL(@"Superior Healing Potion",ITEM,SINGLE,DARK,0,500,heal_potion);
	
	ADD_SPELL(@"Minor Mana Potion",ITEM,SINGLE,DARK,0,100,mana_potion);
	ADD_SPELL(@"Lesser Mana Potion",ITEM,SINGLE,DARK,0,200,mana_potion);
	ADD_SPELL(@"Mana Potion",ITEM,SINGLE,DARK,0,300,mana_potion);
	ADD_SPELL(@"Major Mana Potion",ITEM,SINGLE,DARK,0,400,mana_potion);
	ADD_SPELL(@"Superior Mana Potion",ITEM,SINGLE,DARK,0,500,mana_potion);
	
	//PC spells
	ADD_SPELL(@"Minor Fireball",DAMAGE,SINGLE,FIRE,50,50,detr);
	ADD_SPELL(@"Lesser Fireball",DAMAGE,SINGLE,FIRE,50,50,detr);
	ADD_SPELL(@"Fireball",DAMAGE,SINGLE,FIRE,50,50,detr);
	ADD_SPELL(@"Major Fireball",DAMAGE,SINGLE,FIRE,50,50,detr);
	ADD_SPELL(@"Superior Fireball",DAMAGE,SINGLE,FIRE,50,50,detr);
	
	ADD_SPELL(@"Minor Frostbolt",DAMAGE,SINGLE,COLD,50,50,detr);
	ADD_SPELL(@"Lesser Frostbolt",DAMAGE,SINGLE,COLD,50,50,detr);
	ADD_SPELL(@"Frostbolt",DAMAGE,SINGLE,COLD,50,50,detr);
	ADD_SPELL(@"Major Frostbolt",DAMAGE,SINGLE,COLD,50,50,detr);
	ADD_SPELL(@"Superior Frostbolt",DAMAGE,SINGLE,COLD,50,50,detr);
	
	ADD_SPELL(@"Minor Shock",DAMAGE,SINGLE,LIGHTNING,50,70,detr);
	ADD_SPELL(@"Lesser Shock",DAMAGE,SINGLE,LIGHTNING,50,70,detr);
	ADD_SPELL(@"Shock",DAMAGE,SINGLE,LIGHTNING,50,70,detr);
	ADD_SPELL(@"Major Shock",DAMAGE,SINGLE,LIGHTNING,50,70,detr);
	ADD_SPELL(@"Superior Shock",DAMAGE,SINGLE,LIGHTNING,50,70,detr);
	
	ADD_SPELL(@"Minor Poisoning",DAMAGE,SINGLE,POISON,40,40,detr);
	ADD_SPELL(@"Lesser Poisoning",DAMAGE,SINGLE,POISON,40,40,detr);
	ADD_SPELL(@"Poisoning",DAMAGE,SINGLE,POISON,40,40,detr);
	ADD_SPELL(@"Major Poisoning",DAMAGE,SINGLE,POISON,40,40,detr);
	ADD_SPELL(@"Superior Poisoning",DAMAGE,SINGLE,POISON,40,40,detr);
	
	ADD_SPELL(@"Minor Drain",DAMAGE,SINGLE,DARK,50,30,detr);
	ADD_SPELL(@"Lesser Drain",DAMAGE,SINGLE,DARK,50,30,detr);
	ADD_SPELL(@"Drain Drain",DAMAGE,SINGLE,DARK,50,30,detr);
	ADD_SPELL(@"Major Drain",DAMAGE,SINGLE,DARK,50,30,detr);
	ADD_SPELL(@"Superior Drain",DAMAGE,SINGLE,DARK,50,30,detr);
	
	//Condition spells
	ADD_SPELL(@"Minor Haste",CONDITION,SELF,FIRE,80,10,haste);
	ADD_SPELL(@"Lesser Haste",CONDITION,SELF,FIRE,80,15,haste);
	ADD_SPELL(@"Haste",CONDITION,SELF,FIRE,80,20,haste);
	ADD_SPELL(@"Major Haste",CONDITION,SELF,FIRE,80,25,haste);
	ADD_SPELL(@"Superior Haste",CONDITION,SELF,FIRE,80,30,haste);
	
	ADD_SPELL(@"Minor Freeze",CONDITION,SINGLE,COLD,50,10,freeze);
	ADD_SPELL(@"Lesser Freeze",CONDITION,SINGLE,COLD,65,20,freeze);
	ADD_SPELL(@"Freeze",CONDITION,SINGLE,COLD,80,30,freeze);
	ADD_SPELL(@"Major Freeze",CONDITION,SINGLE,COLD,90,40,freeze);
	ADD_SPELL(@"Superior Freeze",CONDITION,SINGLE,COLD,105,50,freeze);
	
	ADD_SPELL(@"Minor Purge",CONDITION,SINGLE,LIGHTNING,60,20,purge);
	ADD_SPELL(@"Lesser Purge",CONDITION,SINGLE,LIGHTNING,75,40,purge);
	ADD_SPELL(@"Purge",CONDITION,SINGLE,LIGHTNING,90,60,purge);
	ADD_SPELL(@"Major Purge",CONDITION,SINGLE,LIGHTNING,110,80,purge);
	ADD_SPELL(@"Superior Purge",CONDITION,SINGLE,LIGHTNING,60,60,purge);
	
	ADD_SPELL(@"Minor Taint",CONDITION,SINGLE,POISON,40,10,taint);
	ADD_SPELL(@"Lesser Taint",CONDITION,SINGLE,POISON,50,15,taint);
	ADD_SPELL(@"Taint",CONDITION,SINGLE,POISON,60,20,taint);
	ADD_SPELL(@"Major Taint",CONDITION,SINGLE,POISON,70,25,taint);
	ADD_SPELL(@"Superior Taint",CONDITION,SINGLE,POISON,80,30,taint);
	
	ADD_SPELL(@"Minor Confusion",CONDITION,SINGLE,DARK,40,10,confusion);
	ADD_SPELL(@"Lesser Confusion",CONDITION,SINGLE,DARK,40,10,confusion);
	ADD_SPELL(@"Confusion",CONDITION,SINGLE,DARK,40,10,confusion);
	ADD_SPELL(@"Major Confusion",CONDITION,SINGLE,DARK,40,10,confusion);
	ADD_SPELL(@"Superior Confusion",CONDITION,SINGLE,DARK,40,10,confusion);
	
	
	//Wand spells
	ADD_SPELL(@"Minor Fireball",DAMAGE,SINGLE,FIRE,0,50,detr);
	ADD_SPELL(@"Lesser Fireball",DAMAGE,SINGLE,FIRE,0,50,detr);
	ADD_SPELL(@"Fireball",DAMAGE,SINGLE,FIRE,0,50,detr);
	ADD_SPELL(@"Major Fireball",DAMAGE,SINGLE,FIRE,0,50,detr);
	ADD_SPELL(@"Superior Fireball",DAMAGE,SINGLE,FIRE,0,50,detr);
	
	ADD_SPELL(@"Minor Frostbolt",DAMAGE,SINGLE,COLD,0,50,detr);
	ADD_SPELL(@"Lesser Frostbolt",DAMAGE,SINGLE,COLD,0,50,detr);
	ADD_SPELL(@"Frostbolt",DAMAGE,SINGLE,COLD,0,50,detr);
	ADD_SPELL(@"Major Frostbolt",DAMAGE,SINGLE,COLD,0,50,detr);
	ADD_SPELL(@"Superior Frostbolt",DAMAGE,SINGLE,COLD,0,50,detr);
	
	ADD_SPELL(@"Minor Shock",DAMAGE,SINGLE,LIGHTNING,0,70,detr);
	ADD_SPELL(@"Lesser Shock",DAMAGE,SINGLE,LIGHTNING,0,70,detr);
	ADD_SPELL(@"Shock",DAMAGE,SINGLE,LIGHTNING,0,70,detr);
	ADD_SPELL(@"Major Shock",DAMAGE,SINGLE,LIGHTNING,0,70,detr);
	ADD_SPELL(@"Superior Shock",DAMAGE,SINGLE,LIGHTNING,0,70,detr);
	
	ADD_SPELL(@"Minor Poisoning",DAMAGE,SINGLE,POISON,0,40,detr);
	ADD_SPELL(@"Lesser Poisoning",DAMAGE,SINGLE,POISON,0,40,detr);
	ADD_SPELL(@"Poisoning",DAMAGE,SINGLE,POISON,0,40,detr);
	ADD_SPELL(@"Major Poisoning",DAMAGE,SINGLE,POISON,0,40,detr);
	ADD_SPELL(@"Superior Poisoning",DAMAGE,SINGLE,POISON,0,40,detr);
	
	ADD_SPELL(@"Minor Drain",DAMAGE,SINGLE,DARK,0,30,detr);
	ADD_SPELL(@"Minor Drain",DAMAGE,SINGLE,DARK,0,30,detr);
	ADD_SPELL(@"Minor Drain",DAMAGE,SINGLE,DARK,0,30,detr);
	ADD_SPELL(@"Minor Drain",DAMAGE,SINGLE,DARK,0,30,detr);
	ADD_SPELL(@"Minor Drain",DAMAGE,SINGLE,DARK,0,30,detr);
	
}

@end