#import "Battle.h"


@implementation Battle

+ (void)doAttack:(Creature *)attacker :(Creature *)defender :(CombatAbility *)action {
	float basedamage = attacker.l_hand.damage + attacker.r_hand.damage;
	basedamage *= [Battle getDamage:action];
	float elementDamage = attacker.l_hand.elem_damage + attacker.r_hand.elem_damage;
	elemType type = attacker.l_hand.elem_type;
	float armor = defender.l_hand.armor + defender.r_hand.armor + defender.head.armor + defender.chest.armor;
	float finaldamage = basedamage*((120-armor)/54+0.1);
	
	float resist;
	conditionType condtype;
	switch (type) {
		case FIRE:
			resist = defender.fire;
			condtype = BURNED;
			break;
		case COLD:
			resist = defender.cold;
			condtype = CHILLED;
			break;
		case LIGHTNING:
			resist = defender.lightning;
			condtype = HASTENED;
			break;
		case POISON:
			resist = defender.poison;
			condtype = POISONED;
			break;
		case DARK:
			resist = defender.dark;
			condtype = CURSED;
			break;
		default:
			resist = 0;
			break;
	}
	int chance = arc4random() % 100;
	BOOL doElemental = chance >= resist ? YES : NO;
	
	if (doElemental) {
		finaldamage += elementDamage;
	}
	
	defender.curr_shield -= finaldamage;
	if (defender.curr_shield < 0) {
		finaldamage -= (-defender.curr_shield);
		defender.curr_shield = 0;
		defender.curr_health -= finaldamage;
	}
	
	// run test again to see if a condition occurs (only if we did elemental damage though)
	chance = arc4random() % 100;
	if (chance >= resist && doElemental) {
		[defender Add_Condition:condtype];
	}
}

+ (float)getDamage:(CombatAbility *)action {
	//return action.damage;
	return 1;
}

@end
