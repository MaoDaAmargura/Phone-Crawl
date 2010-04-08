//
//  RogueCritter.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RogueCritter.h"
#import "Spell.h"
#import "Skill.h"
#import "Item.h"

@implementation RogueCritter

- (id) initWithLevel:(int)lvl
{
	if (self = [super initWithLevel:lvl])
	{
		int skillLevel = level / 6 + 1;
		elemType elem = [Rand min:FIRE max: DARK];
		stringIcon = @"monster-ghost.png";
		stringName = @"Rogue";
		abilities.spells[POISONDAMAGE] = skillLevel;
		abilities.spells[COLDCONDITION] = skillLevel;
		abilities.spells[POISONCONDITION] = skillLevel;
		abilities.skills[QUICK_STRIKE] = skillLevel;
		abilities.skills[ELE_STRIKE] = skillLevel;
		haveWeakened = FALSE;
		haveSlowed = FALSE;
		havePoisoned = FALSE;
		
		Item *dag1 = [[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:DAGGER] autorelease];
		Item *dag2 = [[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:DAGGER] autorelease];
		[self gainItem:dag1];
		[self gainItem:dag2];
		[self equipItem:dag1];
		[self equipItem:dag2];
		
		Item *helm = [[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:LIGHT_HELM] autorelease];
		[self gainItem:helm];
		[self equipItem:helm];
		Item *bp = [[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:LIGHT_CHEST] autorelease];
		[self gainItem:bp];
		[self equipItem:bp];
	}
	return self;
}

/*
 * Rogue AI logic:
 * -set move location
 * -First move should always be to weaken the player, which decreases his/her maximum hp.
 * -Second move should be to slow the player, which reduces the player's number of turn points gained each turn
 * -Third move should be to attempt to poison the player in order to cause damage over time
 * -If critter's hp is low, start hitting the player with its more powerful attack
 * -Otherwise, use quick attack on player to deal damage and attack before the player
 */
- (void) think:(Critter *)player
{
	[super think:player];
	
	target.moveLocation = player.location;
	
	if (!haveWeakened) {
		target.spellToCast = [Spell spellOfType:POISONCONDITION level:abilities.spells[POISONCONDITION]];
		haveWeakened = TRUE;
	} else if (!haveSlowed){
		target.spellToCast = [Spell spellOfType:COLDCONDITION level:abilities.spells[COLDCONDITION]];
		haveSlowed = TRUE;
	} else if (!havePoisoned) {
		target.spellToCast = [Spell spellOfType:POISONDAMAGE level:abilities.spells[POISONDAMAGE]];
		havePoisoned = TRUE;
	} else if (current.sp == 0 && current.hp < (max.hp * .60))
		target.skillToUse = [Skill skillOfType:ELE_STRIKE level:abilities.skills[ELE_STRIKE]];
	else
		target.skillToUse = [Skill skillOfType:QUICK_STRIKE level:abilities.skills[QUICK_STRIKE]];
}

@end
