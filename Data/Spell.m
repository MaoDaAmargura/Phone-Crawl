#import "Spell.h"
#import "Creature.h"
#import "Item.h" 
#import "PCPopupMenu.h"

//Spell spell_list[NUM_SPELLS];
BOOL haveSetSpells = FALSE;
#define LEVEL_DIFF_MULT 2

@implementation Spell

@synthesize name;
@synthesize range;
@synthesize spellTarget;
@synthesize spellId;
@synthesize turnPointCost;

- (id) initSpellWithName: (NSString *) spellName spellType: (spellType) desiredSpellType targetType: (targetType) spellTargetType elemType: (elemType) elementalType
		  manaCost: (int) mana damage: (int) dmg range: (int) spellRange spellLevel: (int) spellLevel spellId: (int) desiredSpellId
		   spellFn: (SEL) fn turnPointCost: (int) turnPntCost {
	
	if(self = [super init])
	{
		if (!haveSetSpells) {
			[Spell fillSpellList];
		}
		name = [NSString stringWithString: spellName];
		//DLog(@"Creating spell with name: %@, name is: %@",in_name,name);
	    type = desiredSpellType;
		spellTarget = spellTargetType; 
		element = elementalType;
		manaCost = mana;
		damage = dmg;
		range = spellRange; 
		level = spellLevel; 
		spellId = desiredSpellId;
		spellFn = fn;
		turnPointCost = turnPntCost;
		return self;
	}
	return nil;
}

- (NSString *) cast: (Creature *) caster target: (Creature *) target {
	if (caster == nil || (target != SELF && target == nil)) {
		NSLog(@"SPELL CAST ERROR: CASTER NIL");
		return @"Spell: Caster/Target nil";
	}
	int spellResult = 0;
	if(target.current.mana < manaCost)
		return @"Not enough mana!";
	caster.current.mana -= manaCost;
	BOOL didSpellLand = [self resistCheck:caster target:target];
	if (!didSpellLand && target != SELF) spellResult = SPELL_RESIST;
	else {
		if([self respondsToSelector:spellFn]){
			IMP f = [self methodForSelector:spellFn];
			spellResult = (int)(f)(self, spellFn, caster, target);
		}
	}
	if(spellResult > 0) return [NSString stringWithFormat:@"%d damage dealt!",spellResult];
	else switch (spellResult) {
		case SPELL_HASTENED: return @"Attack speed has increased!";
		case SPELL_FROZEN: return @"Target's attack speed decreased!";
		case SPELL_PURGED: return @"All conditions purged!";
		case SPELL_TAINTED: return @"Target tainted!";
		case SPELL_CONFUSED: return @"Target is confused!";
		case SPELL_RESIST: return @"Target resisted your spell!";
		case SPELL_NO_DAMAGE: return @""; 
		case SPELL_CAST_ERR: return @"Spell casting error!";
		default: return @"Spell result error!";
	}
	return @"Spell result switch error!";
}

+ (NSString *) castSpellById: (int) desiredSpellId caster: (Creature *) caster target: (Creature *) target {
	if (!haveSetSpells) [Spell fillSpellList];
	NSLog(@"In cast_id: Casting %d by %@",desiredSpellId,caster.name);
	Spell *spell = [spellList objectAtIndex:desiredSpellId];
	NSLog(@"Casting spell: %@",spell.name);
	return [spell cast:caster target:target];
	//return [[spell_list objectAtIndex: in_spell_id] cast:caster target:target];
};

- (BOOL) resistCheck: (Creature *) caster target: (Creature *) target {
	if (caster == nil || target == nil) 
	{
		NSLog(@"Resist_Check nil");
		return FALSE;
	}
	if (caster == target) return TRUE;
	int resist;
	switch (element) {
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
	if([Rand min:0 max:STAT_MAX + 1] <= resist)
		return FALSE;
	return TRUE;
}

//Return amount of damage to deal to combat system
- (int) damageSpell: (Creature *) caster target: (Creature *) target {
	if (caster == nil || target == nil) return SPELL_CAST_ERR;
	//[target Take_Damage:damage];
	if ([Rand min: 0 max: STAT_MAX + 1] > 10 * level ) {
		switch (element) {
			case FIRE:
				[target addCondition:BURNED];
				break;
			case COLD:
				[target addCondition:CHILLED];
				break;
			case LIGHTNING:
				[target addCondition:HASTENED];
				break;
			case POISON:
				[target addCondition:POISONED];
				break;
			case DARK:
				[target addCondition:CURSED];
				[caster heal:damage];
				break;
		}
	}
	return damage;
};

- (int) healPotion: (Creature *) caster target: (Creature *) target {
	if (caster == nil) return SPELL_CAST_ERR;
	//DLog(@"In heal potion, healing for %d", damage);
	[caster heal: damage];
	//DLog(@"Post heal");
	return SPELL_NO_DAMAGE;
}

- (int) manaPotion: (Creature *) caster target: (Creature *) target {
	if (caster == nil) return SPELL_CAST_ERR;
	[caster healMana: damage];
	return SPELL_NO_DAMAGE;
}
	
- (int) scroll: (Creature *) caster target: (Creature *) target {
	if (caster == nil) return SPELL_CAST_ERR;
	++caster.abilityPoints;
	return SPELL_NO_DAMAGE;
}

- (int) haste: (Creature *) caster target: (Creature *) target {
	if (caster == nil) return SPELL_CAST_ERR;
	[caster addCondition:HASTENED];
	caster.current.turnSpeed += caster.current.turnSpeed * (damage/100.0); // Increase turn speed by percentage
	return SPELL_HASTENED;
}

- (int) freeze: (Creature *) caster target: (Creature *) target {
	if (target == nil) return SPELL_CAST_ERR;
	[target addCondition:CHILLED];
	target.current.turnSpeed -= target.current.turnSpeed * (damage / 100.0); // Decrease turn speed by percentage
	return SPELL_FROZEN;
}

- (int) purge: (Creature *) caster target: (Creature *) target {
	if (caster == nil || target == nil) return SPELL_CAST_ERR;
	[caster clearCondition];
	[caster takeDamage:(damage / level)];
	return SPELL_PURGED;
}
	
- (int) taint: (Creature *) caster target: (Creature *) target {
	if (target == nil) return SPELL_CAST_ERR;
	[target addCondition:WEAKENED];
	target.max.health -= target.max.health * (damage / 100.0); // Decrease max health by percentage
	target.max.shield -= target.max.shield * (damage / 100.0); // Decrease max shield by percentage
	return SPELL_TAINTED;
}

- (int) confusion: (Creature *) caster target: (Creature *) target {
	if (target == nil) return SPELL_CAST_ERR;
	[target addCondition:CONFUSION];
	//What is confusion supposed to do?
	return SPELL_CONFUSED;
}

+ (void) fillSpellList {
	haveSetSpells = TRUE;
	int id_cnt = 0, spell_lvl = 1;
	spellList = [[NSMutableArray alloc] init];
	SEL scroll = @selector(scroll:target:);
	SEL healPotion = @selector(healPotion:target:);
	SEL manaPotion = @selector(manaPotion:target:);
	SEL detr = @selector(damageSpell:target:);
	SEL haste = @selector(haste:target:);
	SEL freeze = @selector(freeze:target:);
	SEL	purge = @selector(purge:target:);
	SEL taint = @selector(taint:target:);
	SEL confusion = @selector(confusion:target:);
	
	
#define ADD_SPELL(NAME,TYPE,TARGET,ELEM,MANA,DMG,FN,TPNTS) [spellList addObject:[[[Spell alloc] initSpellWithName:NAME spellType:TYPE targetType:TARGET elemType:ELEM manaCost:MANA damage:DMG range:MAX_BOW_RANGE spellLevel:spell_lvl++%5+1 spellId:id_cnt++ spellFn:FN turnPointCost:TPNTS] autorelease]]
	
	[spellList addObject:[[[Spell alloc] initSpellWithName:@"Tome" spellType:ITEM targetType:SELF 
											 elemType:DARK manaCost:0 damage:0 range:MAX_BOW_RANGE
										   spellLevel:1 spellId:id_cnt++ spellFn:scroll turnPointCost:10] autorelease]];
	
	
	ADD_SPELL(@"HPot1",ITEM,SELF,DARK,0,100,healPotion,30);
	ADD_SPELL(@"HPot2",ITEM,SELF,DARK,0,200,healPotion,40);
	ADD_SPELL(@"HPot3",ITEM,SELF,DARK,0,300,healPotion,50);
	ADD_SPELL(@"HPot4",ITEM,SELF,DARK,0,400,healPotion,60);
	ADD_SPELL(@"HPot5",ITEM,SELF,DARK,0,500,healPotion,70);
	
	ADD_SPELL(@"MPot1",ITEM,SELF,DARK,0,100,manaPotion,30);
	ADD_SPELL(@"MPot2",ITEM,SINGLE,DARK,0,200,manaPotion,40);
	ADD_SPELL(@"MPot3",ITEM,SINGLE,DARK,0,300,manaPotion,50);
	ADD_SPELL(@"MPot4",ITEM,SINGLE,DARK,0,400,manaPotion,60);
	ADD_SPELL(@"MPot5",ITEM,SINGLE,DARK,0,500,manaPotion,70);
	
	//PC spells
	ADD_SPELL(@"Fire1",DAMAGE,SINGLE,FIRE,50,50,detr,50);
	ADD_SPELL(@"Fire2",DAMAGE,SINGLE,FIRE,50,50,detr,60);
	ADD_SPELL(@"Fire3",DAMAGE,SINGLE,FIRE,50,50,detr,70);
	ADD_SPELL(@"Fire4",DAMAGE,SINGLE,FIRE,50,50,detr,80);
	ADD_SPELL(@"Fire5",DAMAGE,SINGLE,FIRE,50,50,detr,90);
	
	ADD_SPELL(@"Cold1",DAMAGE,SINGLE,COLD,50,50,detr,50);
	ADD_SPELL(@"Cold2",DAMAGE,SINGLE,COLD,50,50,detr,60);
	ADD_SPELL(@"Cold3",DAMAGE,SINGLE,COLD,50,50,detr,70);
	ADD_SPELL(@"Cold4",DAMAGE,SINGLE,COLD,50,50,detr,80);
	ADD_SPELL(@"Cold5",DAMAGE,SINGLE,COLD,50,50,detr,90);
	
	ADD_SPELL(@"Shock1",DAMAGE,SINGLE,LIGHTNING,50,70,detr,50);
	ADD_SPELL(@"Shock2",DAMAGE,SINGLE,LIGHTNING,50,70,detr,60);
	ADD_SPELL(@"Shock3",DAMAGE,SINGLE,LIGHTNING,50,70,detr,70);
	ADD_SPELL(@"Shock4",DAMAGE,SINGLE,LIGHTNING,50,70,detr,80);
	ADD_SPELL(@"Shock5",DAMAGE,SINGLE,LIGHTNING,50,70,detr,90);
	
	ADD_SPELL(@"Pzn1",DAMAGE,SINGLE,POISON,40,40,detr,50);
	ADD_SPELL(@"Pzn2",DAMAGE,SINGLE,POISON,40,40,detr,60);
	ADD_SPELL(@"Pzn3",DAMAGE,SINGLE,POISON,40,40,detr,70);
	ADD_SPELL(@"Pzn4",DAMAGE,SINGLE,POISON,40,40,detr,80);
	ADD_SPELL(@"Pzn5",DAMAGE,SINGLE,POISON,40,40,detr,90);
	
	ADD_SPELL(@"Drain1",DAMAGE,SINGLE,DARK,50,30,detr,50);
	ADD_SPELL(@"Drain2",DAMAGE,SINGLE,DARK,50,30,detr,60);
	ADD_SPELL(@"Drain3",DAMAGE,SINGLE,DARK,50,30,detr,70);
	ADD_SPELL(@"Drain4",DAMAGE,SINGLE,DARK,50,30,detr,80);
	ADD_SPELL(@"Drain5",DAMAGE,SINGLE,DARK,50,30,detr,90);
	
	//Condition spells
	ADD_SPELL(@"Haste1",CONDITION,SELF,FIRE,80,10,haste,50);
	ADD_SPELL(@"Haste2",CONDITION,SELF,FIRE,80,15,haste,60);
	ADD_SPELL(@"Haste3",CONDITION,SELF,FIRE,80,20,haste,70);
	ADD_SPELL(@"Haste4",CONDITION,SELF,FIRE,80,25,haste,80);
	ADD_SPELL(@"Haste5",CONDITION,SELF,FIRE,80,30,haste,90);
	
	ADD_SPELL(@"Freeze1",CONDITION,SINGLE,COLD,50,10,freeze,50);
	ADD_SPELL(@"Freeze2",CONDITION,SINGLE,COLD,65,20,freeze,60);
	ADD_SPELL(@"Freeze3",CONDITION,SINGLE,COLD,80,30,freeze,70);
	ADD_SPELL(@"Freeze4",CONDITION,SINGLE,COLD,90,40,freeze,80);
	ADD_SPELL(@"Freeze5",CONDITION,SINGLE,COLD,105,50,freeze,90);
	
	ADD_SPELL(@"Purge1",CONDITION,SINGLE,LIGHTNING,60,20,purge,50);
	ADD_SPELL(@"Purge2",CONDITION,SINGLE,LIGHTNING,75,40,purge,60);
	ADD_SPELL(@"Purge3",CONDITION,SINGLE,LIGHTNING,90,60,purge,70);
	ADD_SPELL(@"Purge4",CONDITION,SINGLE,LIGHTNING,110,80,purge,80);
	ADD_SPELL(@"Purge5",CONDITION,SINGLE,LIGHTNING,60,60,purge,90);
	
	ADD_SPELL(@"Taint1",CONDITION,SINGLE,POISON,40,10,taint,50);
	ADD_SPELL(@"Taint2",CONDITION,SINGLE,POISON,50,15,taint,60);
	ADD_SPELL(@"Taint3",CONDITION,SINGLE,POISON,60,20,taint,70);
	ADD_SPELL(@"Taint4",CONDITION,SINGLE,POISON,70,25,taint,80);
	ADD_SPELL(@"Taint5",CONDITION,SINGLE,POISON,80,30,taint,90);
	
	ADD_SPELL(@"Cnfzn1",CONDITION,SINGLE,DARK,40,10,confusion,50);
	ADD_SPELL(@"Cnfzn2",CONDITION,SINGLE,DARK,40,10,confusion,60);
	ADD_SPELL(@"Cnfzn3",CONDITION,SINGLE,DARK,40,10,confusion,70);
	ADD_SPELL(@"Cnfzn4",CONDITION,SINGLE,DARK,40,10,confusion,80);
	ADD_SPELL(@"Cnfzn5",CONDITION,SINGLE,DARK,40,10,confusion,90);
	
	//Wand spells
	ADD_SPELL(@"Fire1",DAMAGE,SINGLE,FIRE,0,50,detr,50);
	ADD_SPELL(@"Fire2",DAMAGE,SINGLE,FIRE,0,50,detr,60);
	ADD_SPELL(@"Fire3",DAMAGE,SINGLE,FIRE,0,50,detr,70);
	ADD_SPELL(@"Fire4",DAMAGE,SINGLE,FIRE,0,50,detr,80);
	ADD_SPELL(@"Fire5",DAMAGE,SINGLE,FIRE,0,50,detr,90);
	
	ADD_SPELL(@"Cold1",DAMAGE,SINGLE,COLD,0,50,detr,50);
	ADD_SPELL(@"Cold2",DAMAGE,SINGLE,COLD,0,50,detr,60);
	ADD_SPELL(@"Cold3",DAMAGE,SINGLE,COLD,0,50,detr,70);
	ADD_SPELL(@"Cold4",DAMAGE,SINGLE,COLD,0,50,detr,80);
	ADD_SPELL(@"Cold5",DAMAGE,SINGLE,COLD,0,50,detr,90);
	
	ADD_SPELL(@"Shock1",DAMAGE,SINGLE,LIGHTNING,0,70,detr,50);
	ADD_SPELL(@"Shock2",DAMAGE,SINGLE,LIGHTNING,0,70,detr,60);
	ADD_SPELL(@"Shock3",DAMAGE,SINGLE,LIGHTNING,0,70,detr,70);
	ADD_SPELL(@"Shock4",DAMAGE,SINGLE,LIGHTNING,0,70,detr,80);
	ADD_SPELL(@"Shock5",DAMAGE,SINGLE,LIGHTNING,0,70,detr,90);
	
	ADD_SPELL(@"Pzn1",DAMAGE,SINGLE,POISON,0,40,detr,50);
	ADD_SPELL(@"Pzn2",DAMAGE,SINGLE,POISON,0,40,detr,60);
	ADD_SPELL(@"Pzn3",DAMAGE,SINGLE,POISON,0,40,detr,70);
	ADD_SPELL(@"Pzn4",DAMAGE,SINGLE,POISON,0,40,detr,80);
	ADD_SPELL(@"Pzn5",DAMAGE,SINGLE,POISON,0,40,detr,90);
	
	ADD_SPELL(@"Drain1",DAMAGE,SINGLE,DARK,0,30,detr,50);
	ADD_SPELL(@"Drain2",DAMAGE,SINGLE,DARK,0,30,detr,60);
	ADD_SPELL(@"Drain3",DAMAGE,SINGLE,DARK,0,30,detr,70);
	ADD_SPELL(@"Drain4",DAMAGE,SINGLE,DARK,0,30,detr,80);
	ADD_SPELL(@"Drain5",DAMAGE,SINGLE,DARK,0,30,detr,90);
	
}

@end
