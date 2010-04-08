//
//  Critter.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Critter.h"
#import "Critter+LoadExtensions.h"

#import "Item.h"
#import "Spell.h"
#import "Skill.h"

#define TURN_POINTS_FOR_MOVEMENT_ACTION 40
#define TURN_POINTS_FOR_ITEM_USE		50

@implementation Critter

@synthesize stringName, stringIcon;
@synthesize alive, inBattle;
@synthesize cachedPath;
@synthesize level, turnPoints, money, abilityPoints, deathPenalty, turnSpeed;
@synthesize location;
@synthesize equipment;
@synthesize target;
@synthesize defense;
@synthesize current, max;
@synthesize abilities;
@synthesize npc;
@synthesize dialog;

- (id) initWithLevel:(int)lvl
{
	if (self = [super init])
	{
		level = lvl;
		alive = YES;
		int baseStat = 100 + 25*level;
		[self setHealth:baseStat];
		[self setShield:baseStat];
		[self setMana:baseStat];
		inventory = [[NSMutableArray alloc] initWithCapacity:10];
		abilities.spells = malloc(NUM_PLAYER_SPELL_TYPES*sizeof(int));
		for (int i = 0; i < NUM_PLAYER_SPELL_TYPES; ++i) 
			abilities.spells[i] = 0;
		abilities.skills = malloc(NUM_PLAYER_SKILL_TYPES*sizeof(int));
		abilities.skills[0] = 1;
		for (int i = 1; i < NUM_PLAYER_SKILL_TYPES; ++i)
			abilities.skills[i] = 0;
		abilityPoints = 8;
		turnPoints = 0;
		turnSpeed = 15;
		abilityPoints = 5;
		npc = NO;
	}
	return self;
}
								  
- (void) dealloc
{
	free(abilities.spells);
	free(abilities.skills);
	[inventory release];
	[super dealloc];
}

- (BOOL) hasCondition:(conditionType)cond
{
	return cond&conditionBitSet != 0;
}
	
- (void) gainCondition:(conditionType)cond
{
	if (![self hasCondition:cond])
	{
		conditionBitSet |= cond;
		if (cond == WEAKENED) {
			max.hp *= .8; 
			if (current.hp < max.hp)
				current.hp = max.hp;
		}
	}
}

- (void) loseCondition:(conditionType)cond
{
	if ([self hasCondition:cond]) 
	{
		if (cond ==  WEAKENED)
			max.hp *= 1.25;
		conditionBitSet &= ~cond;
	}
}

- (void) loseAllConditions
{
	if ([self hasCondition:WEAKENED])
		max.hp *= 1.25;
	conditionBitSet &= 0;
}

- (void) gainExperience:(int) exp
{
	experience += exp;
	while (experience >= 1000) 
	{
		++level;
		experience -= 1000;
	}
}

- (void) incrementTurnPoints
{
	int realTS = turnSpeed;
	if (conditionBitSet&CHILLED)
		realTS *= 0.7;
	if (conditionBitSet&HASTENED)
		realTS *= 1.2;
	turnPoints += realTS;
}

- (void) takeDamage:(int)amount
{
	current.sp -= amount;
	if (current.sp >= 0) return;

	current.hp += current.sp;
	current.sp = 0;

	if (current.hp <= 0)
	{
		current.hp = 0;
		alive = NO;
	}
}

- (void) resetStats {
	current.hp = max.hp;
	current.sp = max.sp;
	current.mp = max.mp;
}

- (void) gainHealth:(int)amount
{
	current.hp += amount;
	if (current.hp <= max.hp) return;
	
	current.sp += current.hp - max.hp;
	current.hp = max.hp;
	if (current.sp > max.sp) 
		current.sp = max.sp;
}

- (BOOL) spendMana:(int)amount
{
	if (current.mp > amount) 
	{
		current.mp -= amount;
		return YES;
	}
	else {
		return NO;
	}
}


- (void) gainMana:(int)amount
{
	current.mp += amount;
	if (current.mp > max.mp)
		current.mp = max.mp;
}

- (void) regenShield
{
	current.sp += [Util minValueOfX:max.sp*0.05 andY:(max.sp-current.sp)];
}

- (void) gainItem:(Item*)it
{
	[inventory addObject:it];
}

- (void) loseItem:(Item*)it
{
	[inventory removeObject:it];
}

/* Add items stats to critters stats for calculation */
- (void) gainStatsForItem:(Item*)it
{
	if (!it) return;
	
	max.hp += it.hp;
	current.hp += it.hp;
	
	max.sp += it.shield;
	current.sp += it.shield;
	
	max.mp += it.mana;
	current.mp += it.mana;
	
	defense.armor += it.armor;
	defense.fire += it.fire;
	defense.frost += it.cold;
	defense.shock += it.lightning;
	defense.dark += it.dark;
	defense.poison += it.poison;
}

/* Remove an items stats from the critters stats used for calculations */
- (void) loseStatsForItem:(Item*)it
{
	if (!it) return;
	
	max.hp -= it.hp;
	current.hp -= it.hp;
	if (current.hp < 1) current.hp = 1;
	
	max.sp -= it.shield;
	current.sp -= it.shield;
	if (current.sp < 0) current.sp = 0;
	
	max.mp -= it.mana;
	current.mp -= it.mana;
	if (current.mp < 0) current.mp = 0;
	
	defense.armor -= it.armor;
	defense.fire -= it.fire;
	defense.frost -= it.cold;
	defense.shock -= it.lightning;
	defense.dark -= it.dark;
	defense.poison -= it.poison;
}

- (void) equipItem:(Item*)it
{
	if ([inventory containsObject:it])
	{
		if (![self hasItemEquipped:it]) 
		{
			switch (it.slot) 
			{
				case HEAD:
					[self loseStatsForItem:equipment.head];
					[self gainStatsForItem:it];
					equipment.head = it;
					break;
				case CHEST:
					[self loseStatsForItem:equipment.chest];
					[self gainStatsForItem:it];
					equipment.chest = it;
					break;
				case LEFT:
					[self loseStatsForItem:equipment.lhand];
					[self gainStatsForItem:it];
					equipment.lhand = it;
					break;
				case RIGHT:
					[self loseStatsForItem:equipment.lhand];
					[self gainStatsForItem:it];
					equipment.rhand = it;
					break;
				case EITHER:
					if (equipment.rhand == nil || equipment.rhand.slot == BOTH) 
					{
						[self gainStatsForItem:it];
						equipment.rhand = it;
					}
					else 
					{
						[self loseStatsForItem:equipment.lhand];
						[self gainStatsForItem:it];
						equipment.lhand = it;
					}
					break;
				case BOTH:
					[self loseStatsForItem:equipment.rhand];
					[self loseStatsForItem:equipment.lhand];
					[self gainStatsForItem:it];
					equipment.rhand = it;
					equipment.lhand = nil;
					break;
				default:
					[[[[UIAlertView alloc] initWithTitle:@"Can't Do That" 
												 message:[NSString stringWithFormat:@"%@ can't be equipped.", it.name]
												delegate:nil
									   cancelButtonTitle:@"Cancel"
									   otherButtonTitles:nil] autorelease] show];
					break;
			}
		}
	}
}

- (void) dequipItem:(Item*)it
{
	if (![self hasItemEquipped:it]) return;
	
	[self loseStatsForItem:it];
	switch (it.slot) {
		case HEAD:
			equipment.head = nil;
			break;
		case CHEST:
			equipment.chest = nil;
			break;
		case LEFT:
			equipment.lhand = nil;
			break;
		case RIGHT:
		case BOTH:
			equipment.rhand = nil;
			break;
		case EITHER:
			if (equipment.rhand == it) 
				equipment.rhand = nil;
			else if (equipment.lhand = it)
				equipment.lhand = nil;
			else 
				[[[[UIAlertView alloc] initWithTitle:@"Can't Do That"
											 message:[NSString stringWithFormat:@"%@ wasn't equipped.", it.name]
											delegate:nil
								   cancelButtonTitle:@"Cancel"
								   otherButtonTitles:nil] autorelease] show];

		default:
			break;
	}
}

- (BOOL) hasItemEquipped:(Item*)it
{
	return (	(equipment.rhand == it)
			||	(equipment.lhand == it)
			||	(equipment.head == it)
			||	(equipment.chest == it) );
}
	
- (float) getPhysDamage
{
	float dmg = 0;
	if (equipment.rhand) dmg+=equipment.rhand.damage;
	if (equipment.lhand) dmg+=equipment.lhand.damage * OFFHAND_DMG_PERCENTAGE;
	return dmg > 1? dmg : 1;	
}

- (float) getElemDamage
{
	int dmg = 0;
	if (equipment.rhand) dmg+=equipment.rhand.elementalDamage;
	if (equipment.lhand) dmg+=equipment.lhand.elementalDamage * OFFHAND_DMG_PERCENTAGE;
	return dmg;
}

- (BOOL) hasActionToTake
{
	return (target.skillToUse)||(target.spellToCast)||(target.itemForUse);
}

- (BOOL) hasMoveToMake
{
	return (target.moveLocation) != nil;
}

- (void) think:(Critter*)player
{
	target.critterForAction = player;
}

- (NSString*) useSkill
{
	NSString *actionResult = @"";
	if (target.critterForAction)
	{
		if (target.skillToUse) 
		{
			if ([Util point_distanceC1:location C2:target.critterForAction.location] <= equipment.rhand.range)
			{
				actionResult = [target.skillToUse useAbility:self target:target.critterForAction];
				turnPoints -= target.skillToUse.turnPointCost;
			}
			else 
			{
				actionResult = @"Not in Range!";
			}
			[self setSkillToUse:nil];
		}
	}
	
	return actionResult;
}

- (NSString*) useSpell
{
	NSString *actionResult = @"";
	if (target.critterForAction)
	{
		if (target.spellToCast) 
		{
			if ([Util point_distanceC1:location C2:target.critterForAction.location] <= 5)
			{
				actionResult = [target.spellToCast cast:self target:target.critterForAction];
				turnPoints -= target.spellToCast.turnPointCost;
			}
			else 
			{
				actionResult = @"Not in Range!";
			}
			[self setSpellToUse:nil];
		}
	}
	return actionResult;
}

- (NSString*) useItem
{
	NSString *actionResult = @"";
	if (target.critterForAction) 
	{
		if (target.itemForUse && target.itemForUse.charges > 0)
		{
			if ([Util point_distanceC1:location C2:target.critterForAction.location] <= target.itemForUse.range)
			{
				[target.itemForUse cast:self target:target.critterForAction];
				turnPoints -= TURN_POINTS_FOR_ITEM_USE;
				target.itemForUse.charges--;
				if (target.itemForUse.charges <= 0) 
					[inventory removeObject:target.itemForUse];
			}
			else 
			{
				actionResult = @"Not in Range!";
			}
			[self setItemToUse:nil];
		}
	}
	return actionResult;
}

- (void) moveToTarget
{
	self.location = [cachedPath lastObject];
	[cachedPath removeLastObject];
	if (inBattle)
		turnPoints -= TURN_POINTS_FOR_MOVEMENT_ACTION;
	if ([target.moveLocation equals:location])
		[self setMoveTarget:nil];
}

- (NSMutableArray*) inventoryItems
{
	return inventory;
}


- (void) setItemToUse:(Item*) it
{
	[target.itemForUse release];
	target.itemForUse = [it retain];
}

- (void) setMoveTarget:(Coord*) loc
{
	[target.moveLocation release];
	target.moveLocation = [loc retain];
}

- (void) setSkillToUse:(Skill*) skill
{
	target.skillToUse = skill;
}

- (void) setSpellToUse:(Spell*) spell
{
	target.spellToCast = spell;
}

- (int) score
{
	int score = level*1000 + money;
	for (Item *i in inventory)
		score += i.pointValue;
	score -= deathPenalty;
	return score;
}


#pragma mark -
#pragma mark Load Extensions
/*	These are for private use in load/save manager 
 Don't add these to the main header.
 If you think you need them, ask me for a better way. - Austin
 */
- (void) setHealth:(int)hp
{
	current.hp = max.hp = real.hp = hp;
}

- (void) setShield:(int)sp
{
	current.sp = max.sp = real.sp = sp;
}

- (void) setMana:(int)mp
{
	current.mp = max.mp = real.mp = mp;
}

- (void) setExperience:(int) exp
{
	experience = exp;
}

- (int) experience
{
	return experience;
}

@end

