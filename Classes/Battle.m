#import "Battle.h"


@implementation Battle

+ (void)doAttack:(Creature *)attacker :(Creature *)defender :(CombatAbility *)action {
	float basedamage = [attacker regular_weapon_damage];
	basedamage *= [Battle getDamage:action];
	float elementDamage = [attacker elemental_weapon_damage];
	elemType type1 = attacker.equipment.r_hand.elem_type;
	float finaldamage = basedamage*((120-defender.armor)/54+0.1);
	
	float resist1;
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
	
	finaldamage += (elementDamage * resist1 / 100);	
	[defender Take_Damage:finaldamage];
	
	if ([Rand min:0 max:100] > 20 * action.ability_level)
		[defender Add_Condition:condtype1];
}

+ (float)getDamage:(CombatAbility *)action {
	return action.damage*action.ability_level;
	//return 1;
}

@end
