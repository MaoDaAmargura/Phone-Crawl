#import "CombatAbility.h"
#define LEVEL_DIFF_MULT 2

#import "Creature.h"
#import "PCPopupMenu.h"
#import "Item.h"

#define ADD_ABILITY(NAME,DMG,FN) [ability_list addObject:[[[CombatAbility alloc] initWithInfo:NAME damage:DMG \
ability_level:ability_lvl++%3+1 ability_id:id_cnt++ ability_fn:FN] autorelease]]

NSMutableArray *ability_list = nil;
BOOL have_set_abilities = FALSE;

@implementation CombatAbility

@synthesize name;
@synthesize ability_id;
@synthesize damage;
@synthesize ability_level;


- (id) initWithInfo: (NSString *) in_name damage: (int) in_damage ability_level: (int) in_ability_level 
		 ability_id: (int) in_ability_id ability_fn: (SEL) in_ability_fn {
	if (self = [super init]) {
		name = in_name;
		damage = in_damage;
		ability_level = in_ability_level;
		ability_fn = in_ability_fn;
		ability_id = in_ability_id;
		return self;
	}
	return nil;
}

- (void) use_ability: (Creature *) caster target: (Creature *) target 
{
	if([self respondsToSelector:ability_fn])
	{
		IMP f = [self methodForSelector:ability_fn];
		(void)(f)(self, ability_fn, caster, target);
	}
}

+ (void) use_ability_id: (int) in_ability_id caster: (Creature *) caster target: (Creature *) target {
	if(!have_set_abilities) [CombatAbility fill_ability_list];

	CombatAbility *ca = [ability_list objectAtIndex:in_ability_id];
	[ca use_ability:caster target:target];
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
- (void) detr_ability: (Creature *) attacker target: (Creature *) defender {
	if (attacker == nil || defender == nil) {
		DLog(@"ABILITY_ERR");
	}
	[self basicAttack: attacker def: defender];
	[self elementalAttack:attacker def:defender];
}

- (void) basicAttack:(Creature *)attacker def:(Creature *)defender {
	float basedamage = [attacker regular_weapon_damage];
	basedamage *= damage;
	float finaldamage = basedamage*((120-defender.armor)/54+0.1);
	[defender Take_Damage:finaldamage];
}

- (void) elementalAttack:(Creature *)attacker def:(Creature *)defender {
	float resist1;
	// this assumes weapon is held in right hand
	float elementDamage = [attacker elemental_weapon_damage];
	elemType type1 = attacker.equipment.r_hand.elem_type;
	conditionType condtype1;
	switch (type1) {
		case FIRE:
			resist1 = defender.fire;
			condtype1 = BURNED;
			break;
		case COLD:
			resist1 = defender.cold;
			condtype1 = CHILLED;
			break;
		case LIGHTNING:
			resist1 = defender.lightning;
			condtype1 = HASTENED;
			break;
		case POISON:
			resist1 = defender.poison;
			condtype1 = POISONED;
			break;
		case DARK:
			resist1 = defender.dark;
			condtype1 = CURSED;
			break;
		default:
			resist1 = 0;
			break;
	}

	int finaldamage = (elementDamage * (100-resist1) / 100);
	if ([Rand min:0 max:100] > 20 * ability_level)
		[defender Add_Condition:condtype1];
	[defender Take_Damage:finaldamage];
}

+ (void) fill_ability_list {
	have_set_abilities = TRUE;
	int id_cnt = 0, ability_lvl = 1;
	//ability_list = [[[NSMutableArray alloc] init] autorelease];
	ability_list = [[NSMutableArray alloc] init];
	SEL detr = @selector(detr_ability:target:);
	
	ADD_ABILITY(@"Default Strike",80,detr);
	ADD_ABILITY(@"Dildonic Strike of Death",1000,detr);
}

@end
