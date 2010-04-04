
#define LEVEL_DIFF_MULT 2

#import "Skill.h"

#import "Critter.h"
#import "Item.h"

#define ADD_ABILITY(NAME,DMG,FN,TPNTS) [abilityList addObject:[[[Skill alloc] initWithInfo:NAME damageMultiplier:DMG \
abilityLevel:abilityLvl++%3+1 abilityId:id_cnt++ abilityFn:FN turnPoints:TPNTS] autorelease]]

NSMutableArray *abilityList = nil;

BOOL have_set_abilities = FALSE;

@implementation Skill

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

- (NSString *) useAbility: (Critter *) caster target: (Critter *) target 
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
		DLog(@"Ability error: %@",self.name);
		return @"";
	}

}

+ (NSString *) useAbilityWithId: (int) desiredAbilityId caster: (Critter *) caster target: (Critter *) target {
	//if(!have_set_abilities) [Skill fillAbilityList];

	Skill *ca = [abilityList objectAtIndex:desiredAbilityId];
	return [ca useAbility:caster target:target];
};

- (int) mitigateDamage:(Critter *)caster target:(Critter *)target damage: (int) amountDamage {
	int resist = target.defense.armor;
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

- (int) basicAttack:(Critter *)attacker def:(Critter *)defender {
	float basedamage = [attacker getPhysDamage];
	basedamage *= damageMultiplier;
	return basedamage*((120-defender.defense.armor)/54+0.1); 
}

- (int) elementalAttack:(Critter *)attacker def:(Critter *)defender {
	float resist;
	float elementDamage = [attacker getElemDamage];
	elemType type = attacker.equipment.rhand.element;
	conditionType condtype = NO_CONDITION;
	switch (type) {
		case FIRE:
			resist = defender.defense.fire;
			condtype = BURNED;
			break;
		case COLD:
			resist = defender.defense.frost;
			condtype = CHILLED;
			break;
		case LIGHTNING:
			resist = defender.defense.shock;
			condtype = HASTENED;
			break;
		case POISON:
			resist = defender.defense.poison;
			condtype = POISONED;
			break;
		case DARK:
			resist = defender.defense.dark;
			condtype = CURSED;
			break;
		default:
			resist = 0;
			break;
	}

	int finaldamage = (elementDamage * (100-resist) / 100);
	if ([Rand min:0 max:100] > 20 * abilityLevel)
		[defender gainCondition:condtype];
	return finaldamage;
}

//Specialized ability function example
- (int) mixedStrike: (Critter *) attacker target: (Critter *) defender {
	if (attacker == nil || defender == nil) {
		DLog(@"ABILITY_ERR");
	}
	return 0.5*([self basicAttack: attacker def: defender] + [self elementalAttack:attacker def:defender]);
}

- (int) elementalStrike: (Critter *) attacker target: (Critter *) defender {
	if (attacker == nil || defender == nil) {
		DLog(@"ABILITY_ERR");
	}
	return [self elementalAttack: attacker def: defender];
}

- (int) defaultStrike: (Critter *) attacker target: (Critter *) defender {
	if (attacker == nil || defender == nil) {
		DLog(@"ABILITY_ERR");
	}
	int dmg = [self basicAttack: attacker def: defender];
	//DLog(@"%@ hits %@ for %d",attacker.stringName, defender.stringName, dmg); //Critter
	return dmg;
}


+ (void) initialize
{
	have_set_abilities = TRUE;
	int id_cnt = 0, abilityLvl = 1;
	abilityList = [[NSMutableArray alloc] init];
	SEL mix = @selector(mixedStrike:target:);
	SEL ele = @selector(elementalStrike:target:);
	SEL def = @selector(defaultStrike:target:);

	
	ADD_ABILITY(@"Basic",2.0,def,50);
	ADD_ABILITY(@"Quick",1.0,def,25);
	ADD_ABILITY(@"Power",4.0,def,100);
	ADD_ABILITY(@"Elem",2.0,ele,50);
	ADD_ABILITY(@"Combo",2.0,mix,50);
	ADD_ABILITY(@"Shitty",0.8,def,50);
}

+ (Skill*) skillOfType:(PC_COMBAT_ABILITY_TYPE)type
{
	return [abilityList objectAtIndex:type];
}

@end
