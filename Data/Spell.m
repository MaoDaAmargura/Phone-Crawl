#import "Spell.h"
#import "Critter.h"
#import "Item.h" 
#import "PCPopupMenu.h"


NSMutableArray *spellList;
BOOL haveSetSpells = FALSE;
#define LEVEL_DIFF_MULT 2

// implementation for Spell
@implementation Spell

// getter and setter methods
@synthesize name;
@synthesize range;
@synthesize spellTarget;
@synthesize spellId;
@synthesize turnPointCost;

// creates a spell with the given parameters. Pretty straightforward-just storing argument data
- (id) initSpellWithName: (NSString *) spellName spellType: (spellType) desiredSpellType targetType: (targetType) spellTargetType elemType: (elemType) elementalType
		  manaCost: (int) mana damage: (int) dmg range: (int) spellRange spellLevel: (int) spellLevel spellId: (int) desiredSpellId
		   spellFn: (SEL) fn turnPointCost: (int) turnPntCost {
	
	if(self = [super init])
	{
		name = [NSString stringWithString: spellName];
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

// cast the spell on a specified target
- (NSString *) cast: (Critter *) caster target: (Critter *) target {
	// check to make sure everything is valid
	if (caster == nil || (target != SELF && target == nil)) {
		NSLog(@"SPELL CAST ERROR: CASTER NIL");
		return @"Spell: Caster/Target nil";
	}
	int spellResult = 0;
	// check to see if caster has enough mana to cast spell
	// calling this function also spends the mana if the caster has enough
	if (![caster spendMana:manaCost])
	{
		return @"Not enough mana!";		
	}
	// check if the spell was resisted
	BOOL didSpellLand = [self resistCheck:caster target:target];
	if (!didSpellLand && target != SELF) spellResult = SPELL_RESIST;
	else {
		// if the spell was not resisted and the action function is set
		if([self respondsToSelector:spellFn]){
			// get the method pointer
			IMP f = [self methodForSelector:spellFn];
			// cast the spell and store the result
			spellResult = (int)(f)(self, spellFn, caster, target);
		}
	}
	// if there was damage dealt, inform the player
	if(spellResult > 0) return [NSString stringWithFormat:@"%@ dealt %d damage to %@", name, spellResult, target.stringName];
	// otherwise a condition was set, find out what it is and inform the player
	else switch (spellResult) {
		case SPELL_HASTENED: return [target.stringName stringByAppendingString:@"'s Speed increased!"];
		case SPELL_FROZEN: return [target.stringName stringByAppendingString:@"'s Speed decreased!"];
		case SPELL_PURGED: return [target.stringName stringByAppendingString: @" lost all status conditions!"];
		case SPELL_TAINTED: return [target.stringName stringByAppendingString: @" was tainted!"];
		case SPELL_CONFUSED: return [target.stringName stringByAppendingString: @" became confused!"];
		case SPELL_RESIST: return [target.stringName stringByAppendingString:@" resisted the spell!"];
		case SPELL_NO_DAMAGE: return @""; 
		case SPELL_CAST_ERR: return @"Spell casting error!";
		default:
			return @"";
	}
	return @"";
}

// static function-alternate method of casting when just the ID of the spell is known
+ (NSString *) castSpellById: (int) desiredSpellId caster: (Critter *) caster target: (Critter *) target {
	// get the pointer to the spell requested
	Spell *spell = [spellList objectAtIndex:desiredSpellId];
	// cast the spell and return the result
	return [spell cast:caster target:target];
}

// check resistance
- (BOOL) resistCheck: (Critter *) caster target: (Critter *) target {
	// make sure parameters are valid
	if (caster == nil || target == nil) 
	{
		NSLog(@"Resist_Check nil");
		return FALSE;
	}
	// and caster is not target...
	if (caster == target) return TRUE;
	int resist = 0;
	// based on element of spell, get target's base resistance
	switch (element) {
		case FIRE:
			resist = target.defense.fire;
			break;
		case COLD:
			resist = target.defense.frost;
			break;
		case LIGHTNING:
			resist = target.defense.shock;
			break;
		case POISON:
			resist = target.defense.poison; 
			break;
		case DARK:
			resist = target.defense.dark;
			break;
	}
	// clamp resistance
	if (resist > STAT_MAX) {
		resist = STAT_MAX;
	} else if (resist < STAT_MIN) {
		resist = STAT_MIN;
	}
	// find difference in levels
	int level_diff = caster.level - target.level;
	// based on level difference, calculate adjusted resistance
	if(level_diff < 0)
		resist = STAT_MAX - resist * LEVEL_DIFF_MULT / level_diff;
	else if(level_diff > 0)
		resist = resist * LEVEL_DIFF_MULT / level_diff;
	// check if spell was resisted or not
	if([Rand min:0 max:STAT_MAX + 1] <= resist / 8)
		return FALSE;
	return TRUE;
}

//Return amount of damage to deal to combat system
- (int) damageSpell: (Critter *) caster target: (Critter *) target {
	// check for valid arguments
	if (caster == nil || target == nil) return SPELL_CAST_ERR;
	// damage the target
	[target takeDamage:damage];
	// randomly give target spell condition
	if ([Rand min: 0 max: STAT_MAX + 1] > 10 * level ) {
		switch (element) {
			case FIRE:
				[target gainCondition:BURNED];
				break;
			case COLD:
				[target gainCondition:CHILLED];
				break;
			case LIGHTNING:
				[target gainCondition:HASTENED];
				break;
			case POISON:
				[target gainCondition:POISONED];
				break;
			case DARK:
				[target gainCondition:CURSED];
				[caster gainHealth:damage];
				break;
		}
	}
	return damage;
}

// when a health potion is used
- (int) healPotion: (Critter *) caster target: (Critter *) target {
	if (caster == nil) return SPELL_CAST_ERR;
	// give caster extra health
	[caster gainHealth: damage];
	return SPELL_NO_DAMAGE;
}

// if a mana potion is used
- (int) manaPotion: (Critter *) caster target: (Critter *) target {
	if (caster == nil) return SPELL_CAST_ERR;
	// give caster extra mana
	[caster gainMana: damage];
	return SPELL_NO_DAMAGE;
}
	
// if a scroll is used
- (int) scroll: (Critter *) caster target: (Critter *) target {
	if (caster == nil) return SPELL_CAST_ERR;
	// increase the ability points of the caster
	++caster.abilityPoints;
	return SPELL_NO_DAMAGE;
}

///////////////////////////////////////
// the following 5 functions
// are designed to give conditions to
// the caster or target
///////////////////////////////////////

- (int) haste: (Critter *) caster target: (Critter *) target {
	if (caster == nil) return SPELL_CAST_ERR;
	[caster gainCondition:HASTENED];
	return SPELL_HASTENED;
}

- (int) freeze: (Critter *) caster target: (Critter *) target {
	if (target == nil) return SPELL_CAST_ERR;
	[target gainCondition:CHILLED];
	return SPELL_FROZEN;
}

- (int) purge: (Critter *) caster target: (Critter *) target {
	if (caster == nil || target == nil) return SPELL_CAST_ERR;
	[caster loseAllConditions];
	[caster takeDamage:(damage / level)];
	return SPELL_PURGED;
}
	
- (int) taint: (Critter *) caster target: (Critter *) target {
	if (target == nil) return SPELL_CAST_ERR;
	[target gainCondition:WEAKENED];
	return SPELL_TAINTED;
}

- (int) confusion: (Critter *) caster target: (Critter *) target {
	if (target == nil) return SPELL_CAST_ERR;
	[target gainCondition:CONFUSION];
	return SPELL_CONFUSED;
}


// static function to add all possible spells to the spell list
+ (void) initialize
{
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
	ADD_SPELL(@"Fire1",DAMAGE,SINGLE,FIRE,10,50,detr,50);
	ADD_SPELL(@"Fire2",DAMAGE,SINGLE,FIRE,20,50,detr,60);
	ADD_SPELL(@"Fire3",DAMAGE,SINGLE,FIRE,30,50,detr,70);
	ADD_SPELL(@"Fire4",DAMAGE,SINGLE,FIRE,40,50,detr,80);
	ADD_SPELL(@"Fire5",DAMAGE,SINGLE,FIRE,50,50,detr,90);
	
	ADD_SPELL(@"Cold1",DAMAGE,SINGLE,COLD,10,50,detr,50);
	ADD_SPELL(@"Cold2",DAMAGE,SINGLE,COLD,20,50,detr,60);
	ADD_SPELL(@"Cold3",DAMAGE,SINGLE,COLD,30,50,detr,70);
	ADD_SPELL(@"Cold4",DAMAGE,SINGLE,COLD,40,50,detr,80);
	ADD_SPELL(@"Cold5",DAMAGE,SINGLE,COLD,50,50,detr,90);
	
	ADD_SPELL(@"Shock1",DAMAGE,SINGLE,LIGHTNING,10,70,detr,50);
	ADD_SPELL(@"Shock2",DAMAGE,SINGLE,LIGHTNING,20,70,detr,60);
	ADD_SPELL(@"Shock3",DAMAGE,SINGLE,LIGHTNING,30,70,detr,70);
	ADD_SPELL(@"Shock4",DAMAGE,SINGLE,LIGHTNING,40,70,detr,80);
	ADD_SPELL(@"Shock5",DAMAGE,SINGLE,LIGHTNING,50,70,detr,90);
	
	ADD_SPELL(@"Pzn1",DAMAGE,SINGLE,POISON,10,40,detr,50);
	ADD_SPELL(@"Pzn2",DAMAGE,SINGLE,POISON,20,40,detr,60);
	ADD_SPELL(@"Pzn3",DAMAGE,SINGLE,POISON,30,40,detr,70);
	ADD_SPELL(@"Pzn4",DAMAGE,SINGLE,POISON,40,40,detr,80);
	ADD_SPELL(@"Pzn5",DAMAGE,SINGLE,POISON,50,40,detr,90);
	
	ADD_SPELL(@"Drain1",DAMAGE,SINGLE,DARK,10,30,detr,50);
	ADD_SPELL(@"Drain2",DAMAGE,SINGLE,DARK,20,30,detr,60);
	ADD_SPELL(@"Drain3",DAMAGE,SINGLE,DARK,30,30,detr,70);
	ADD_SPELL(@"Drain4",DAMAGE,SINGLE,DARK,40,30,detr,80);
	ADD_SPELL(@"Drain5",DAMAGE,SINGLE,DARK,50,30,detr,90);
	
	//Condition spells
	ADD_SPELL(@"Haste1",CONDITION,SELF,FIRE,20,10,haste,50);
	ADD_SPELL(@"Haste2",CONDITION,SELF,FIRE,40,15,haste,60);
	ADD_SPELL(@"Haste3",CONDITION,SELF,FIRE,60,20,haste,70);
	ADD_SPELL(@"Haste4",CONDITION,SELF,FIRE,80,25,haste,80);
	ADD_SPELL(@"Haste5",CONDITION,SELF,FIRE,80,30,haste,90);
	
	ADD_SPELL(@"Freeze1",CONDITION,SINGLE,COLD,20,10,freeze,50);
	ADD_SPELL(@"Freeze2",CONDITION,SINGLE,COLD,40,20,freeze,60);
	ADD_SPELL(@"Freeze3",CONDITION,SINGLE,COLD,60,30,freeze,70);
	ADD_SPELL(@"Freeze4",CONDITION,SINGLE,COLD,80,40,freeze,80);
	ADD_SPELL(@"Freeze5",CONDITION,SINGLE,COLD,100,50,freeze,90);
	
	ADD_SPELL(@"Purge1",CONDITION,SINGLE,LIGHTNING,20,20,purge,50);
	ADD_SPELL(@"Purge2",CONDITION,SINGLE,LIGHTNING,40,40,purge,60);
	ADD_SPELL(@"Purge3",CONDITION,SINGLE,LIGHTNING,60,60,purge,70);
	ADD_SPELL(@"Purge4",CONDITION,SINGLE,LIGHTNING,80,80,purge,80);
	ADD_SPELL(@"Purge5",CONDITION,SINGLE,LIGHTNING,100,60,purge,90);
	
	ADD_SPELL(@"Taint1",CONDITION,SINGLE,POISON,20,10,taint,50);
	ADD_SPELL(@"Taint2",CONDITION,SINGLE,POISON,40,15,taint,60);
	ADD_SPELL(@"Taint3",CONDITION,SINGLE,POISON,60,20,taint,70);
	ADD_SPELL(@"Taint4",CONDITION,SINGLE,POISON,80,25,taint,80);
	ADD_SPELL(@"Taint5",CONDITION,SINGLE,POISON,100,30,taint,90);
	
	ADD_SPELL(@"Cnfzn1",CONDITION,SINGLE,DARK,20,10,confusion,50);
	ADD_SPELL(@"Cnfzn2",CONDITION,SINGLE,DARK,40,10,confusion,60);
	ADD_SPELL(@"Cnfzn3",CONDITION,SINGLE,DARK,60,10,confusion,70);
	ADD_SPELL(@"Cnfzn4",CONDITION,SINGLE,DARK,80,10,confusion,80);
	ADD_SPELL(@"Cnfzn5",CONDITION,SINGLE,DARK,100,10,confusion,90);
	
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

// static function that returns a spell given a type and level
+ (Spell*) spellOfType:(PC_SPELL_TYPE)type level:(int)lvl
{
	return [spellList objectAtIndex:5*type + lvl + START_PC_SPELLS];
}

@end
