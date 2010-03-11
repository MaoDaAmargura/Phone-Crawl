#import "CombatAbility.h"
#define LEVEL_DIFF_MULT 2

#import "Creature.h"
#import "PCPopupMenu.h"
#import "Item.h"

#define ADD_ABILITY(NAME,DMG,FN,TPNTS) [abilityList addObject:[[[CombatAbility alloc] initWithInfo:NAME damageMultiplier:DMG \
abilityLevel:abilityLvl++%3+1 abilityId:id_cnt++ abilityFn:FN turnPoints:TPNTS] autorelease]]

NSMutableArray *abilityList = nil;
BOOL have_set_abilities = FALSE;

@implementation CombatAbility

@synthesize name;
@synthesize abilityId;
@synthesize damageMultiplier;
@synthesize abilityLevel;
@synthesize turnPointCost;


- (id) initWithInfo: (NSString *) abilityName damageMultiplier: (float) abilityDamage abilityLevel: (int) level 
		 abilityId: (int) desiredId abilityFn: (SEL) fn turnPoints:(int) turnPntCost {
	if (self = [super init]) {
		name = abilityName;
		damageMultiplier = abilityDamage;
		abilityLevel = level;
		abilityFn = fn;
		abilityId = desiredId;
		turnPointCost = turnPntCost;
		return self;
	}
	return nil;
}

- (NSString *) useAbility: (Creature *) caster target: (Creature *) target 
{
	int abilityResult = 0;

	if([self respondsToSelector:abilityFn])
	{
		IMP f = [self methodForSelector:abilityFn];
		abilityResult = (int)(f)(self, abilityFn, caster, target);
	}
	if (abilityResult >= 0) {
		[target takeDamage:abilityResult];
		return [NSString stringWithFormat:@"Target dealt %d damage!",abilityResult];
	} else {
		return @"Ability result text err!";
	}

}

+ (NSString *) useAbilityWithId: (int) desiredAbilityId caster: (Creature *) caster target: (Creature *) target {
	if(!have_set_abilities) [CombatAbility fillAbilityList];

	CombatAbility *ca = [abilityList objectAtIndex:desiredAbilityId];
	return [ca useAbility:caster target:target];
};

- (int) mitigateDamage:(Creature *)caster target:(Creature *)target damage: (int) amountDamage {
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
	return amountDamage * resist / 100;
}

- (int) basicAttack:(Creature *)attacker def:(Creature *)defender {
	float basedamage = [attacker regularWeaponDamage];
	basedamage *= damageMultiplier;
	float finaldamage = basedamage*((120-defender.armor)/54+0.1);
	//[defender takeDamage:finaldamage];
	return finaldamage;
}

- (int) elementalAttack:(Creature *)attacker def:(Creature *)defender {
	float resist1;
	// this assumes weapon is held in right hand
	float elementDamage = [attacker elementalWeaponDamage];
	elemType type1 = attacker.equipment.rHand.element;
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
	if ([Rand min:0 max:100] > 20 * abilityLevel)
		[defender addCondition:condtype1];
	//[defender takeDamage:finaldamage];
	return finaldamage;
}

//Specialized ability function example
- (int) mixedStrike: (Creature *) attacker target: (Creature *) defender {
	if (attacker == nil || defender == nil) {
		DLog(@"ABILITY_ERR");
	}
	return 0.5*([self basicAttack: attacker def: defender] + [self elementalAttack:attacker def:defender]);
}

- (int) elementalStrike: (Creature *) attacker target: (Creature *) defender {
	if (attacker == nil || defender == nil) {
		DLog(@"ABILITY_ERR");
	}
	return [self elementalAttack: attacker def: defender];
}

- (int) defaultStrike: (Creature *) attacker target: (Creature *) defender {
	if (attacker == nil || defender == nil) {
		DLog(@"ABILITY_ERR");
	}
	int dmg = [self basicAttack: attacker def: defender];
	DLog(@"%@ hits %@ for %d",attacker.iconName, defender.name, dmg);
	return dmg;
}


+ (void) fillAbilityList {
	have_set_abilities = TRUE;
	int id_cnt = 0, abilityLvl = 1;
	//ability_list = [[[NSMutableArray alloc] init] autorelease];
	abilityList = [[NSMutableArray alloc] init];
	SEL mix = @selector(mixedStrike:target:);
	SEL ele = @selector(elementalStrike:target:);
	SEL def = @selector(defaultStrike:target:);

	ADD_ABILITY(@"Strike",2.0,def,50);
	ADD_ABILITY(@"Brute",4.0,def,100);
	ADD_ABILITY(@"EStrike",2.0,ele,50);
	ADD_ABILITY(@"MStrike",2.0,mix,50);
	ADD_ABILITY(@"Quick",1.0,def,25);
	ADD_ABILITY(@"Shitty",0.8,def,50);
}

@end
