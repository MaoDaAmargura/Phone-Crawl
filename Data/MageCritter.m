//
//  MageCritter.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MageCritter.h"
#import "Spell.h"
#import "Skill.h"
#import "Item.h"

@implementation MageCritter

- (id) initWithLevel:(int)lvl
{
	if (self = [super initWithLevel:lvl])
	{
		int skillLevel = level / 6 + 1;
		elemType elem = [Rand min:FIRE max: DARK];
		stringIcon = @"monster-iceman.png";
		stringName = @"Mage";
		for (int i = 0; i < NUM_PLAYER_SPELL_TYPES; ++i)
			abilities.spells[i] = skillLevel;
		abilities.skills[REG_STRIKE] = skillLevel;
		debuffMode = [Rand min:0 max:1];
		Item *staff = [[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:STAFF] autorelease];
		[self gainItem:staff];
		[self equipItem:staff];
		Item *helm = [[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:LIGHT_HELM] autorelease];
		[self gainItem:helm];
		[self equipItem:helm];
		Item *bp = [[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:LIGHT_CHEST] autorelease];
		[self gainItem:bp];
		[self equipItem:bp];
	}
	return self;
}

- (void) think:(Critter *)player
{
	[super think:player];
	
	//TODO: this should actually move to a nearby location good for casting 3-5 spaces away
	target.moveLocation = player.location; 
	if ([Util point_distanceC1:self.location C2:player.location] > [Rand min:3 max:5])
		return;
	if (current.sp == 0 && current.hp < (max.hp * 0.80))
		target.spellToCast = [Spell spellOfType:DARKDAMAGE level:abilities.spells[DARKDAMAGE]];
	else if (conditionBitSet&CONFUSION) {
		target.critterForAction = self;
		target.spellToCast = [Spell spellOfType:LIGHTNINGCONDITION level:abilities.spells[LIGHTNINGCONDITION]];
	} else if (debuffMode) {
		if (!haveWeakened) {
			target.spellToCast = [Spell spellOfType:POISONCONDITION level:abilities.spells[POISONCONDITION]];
			haveWeakened = TRUE;
			return;
		} else if (!haveSlowed) {
			target.spellToCast = [Spell	spellOfType:COLDCONDITION level:abilities.spells[COLDCONDITION]];
			haveSlowed = TRUE;
			return;
		} else if (player.target.critterForAction != self) {
			target.critterForAction = player.target.critterForAction;
			target.spellToCast = [Spell spellOfType:FIRECONDITION level:abilities.spells[FIRECONDITION]];
			return;
		}
	} else
		target.spellToCast = [Spell spellOfType:[Rand min:FIREDAMAGE max: POISONDAMAGE] level:abilities.spells[FIREDAMAGE]];
}

@end
