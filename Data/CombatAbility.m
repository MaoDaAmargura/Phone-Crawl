#import "CombatAbility.h"
#define LEVEL_DIFF_MULT 2

#import "Creature.h"
#import "PCPopupMenu.h"
#import "Item.h"

#define ADD_ABILITY(NAME,DMG,FN,PNTS,TPNTS) [abilityList addObject:[[[CombatAbility alloc] initWithInfo:NAME damage:DMG \
abilityLevel:abilityLvl++%3+1 abilityId:id_cnt++ abilityFn:FN points:PNTS turnPoints:TPNTS] autorelease]]

NSMutableArray *abilityList = nil;
BOOL have_set_abilities = FALSE;

@implementation CombatAbility

@synthesize name;
@synthesize abilityId;
@synthesize damage;
@synthesize abilityLevel;
@synthesize turnPoints;
@synthesize turnPointCost;


- (id) initWithInfo: (NSString *) abilityName damage: (int) abilityDamage abilityLevel: (int) level 
		 abilityId: (int) desiredId abilityFn: (SEL) fn points:(int)turnPnts 
		 turnPoints:(int) turnPntCost {
	if (self = [super init]) {
		name = abilityName;
		damage = abilityDamage;
		abilityLevel = level;
		abilityFn = fn;
		abilityId = desiredId;
		turnPoints = turnPnts;
		turnPointCost = turnPntCost;
		return self;
	}
	return nil;
}

- (NSString *) useAbility: (Creature *) caster target: (Creature *) target 
{
	int abilityResult = 0;
	if (caster.turnPoints >= turnPoints) {
		caster.turnPoints -= turnPoints;
		if([self respondsToSelector:abilityFn])
		{
			IMP f = [self methodForSelector:abilityFn];
			abilityResult = (int)(f)(self, abilityFn, caster, target);
		}
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

//Specialized ability function example
- (int) defaultAbility: (Creature *) attacker target: (Creature *) defender {
	if (attacker == nil || defender == nil) {
		DLog(@"ABILITY_ERR");
	}
	return [self basicAttack: attacker def: defender] + [self elementalAttack:attacker def:defender];
}

- (int) basicAttack:(Creature *)attacker def:(Creature *)defender {
	float basedamage = [attacker regularWeaponDamage];
	basedamage *= damage;
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

- (int) elementalStrike: (Creature *) attacker target: (Creature *) defender {
	if (attacker == nil || defender == nil) {
		DLog(@"ABILITY_ERR");
	}
	return [self elementalAttack: attacker def: defender] * 2;
}

- (int) bruteStrike: (Creature *) attacker target: (Creature *) defender {
	if (attacker == nil || defender == nil) {
		DLog(@"ABILITY_ERR");
	}
	return [self basicAttack: attacker def: defender] * 2;
}

- (int) quickStrike: (Creature *) attacker target: (Creature *) defender {
	if (attacker == nil || defender == nil) {
		DLog(@"ABILITY_ERR");
	}
	attacker.turnPoints += 40;
	return [self basicAttack: attacker def: defender] + [self elementalAttack:attacker def:defender];
}

+ (void) fillAbilityList {
	have_set_abilities = TRUE;
	int id_cnt = 0, abilityLvl = 1;
	//ability_list = [[[NSMutableArray alloc] init] autorelease];
	abilityList = [[NSMutableArray alloc] init];
	SEL detr = @selector(defaultAbility:target:);
	SEL ele = @selector(elementalStrike:target:);
	SEL brute = @selector(bruteStrike:target:);
	SEL quick = @selector(quickStrike:target:);
	
	ADD_ABILITY(@"Swing",80,detr,50,20);
	ADD_ABILITY(@"Brute",1000,brute,50,100);
	ADD_ABILITY(@"EStrike",60,ele,50,40);
	ADD_ABILITY(@"Quick",40,quick,50,20);
	
}

@end
