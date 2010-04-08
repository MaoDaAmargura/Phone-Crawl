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
		haveHastened = FALSE;
		haveSlowed = FALSE;
		haveWeakened = FALSE;
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

/*
 * Mage AI logic:
 * -set move target, but only move if player is outside of 3-5 spaces away (to keep player in casting range)
 * -If mage's hp is low, cast dark-type damage spell on player, which deals damage to player and partially restores
 *  mage's hp.
 * -If mage is confused, use lightning-type condition spell to attempt to remove the effect
 * -When each mage-type critter is created, the variable "debuffMode" is randomly set to either TRUE or FALSE
 *     -- If debuffMode is TRUE, then the mage will attempt to cast spells to make the player weak and to strengthen
 *        the player's target (which is either the mage or one of its allies)
 *        --- The debuff mage first attempts to weaken the player, which decreases the player's
 *            maximum hp
 *        --- The debuff mage then attemps to slow the player, which decreases the number of turn points the player
 *            gains each round
 *        --- Once these two have been done, the mage attempts to hasten the player's current target, which increases
 *            the number of turn points that that critter gains each turn
 *        --- 
 *	   -- If debuffMode is FALSE or all of the debuffMode spells have been cast, then the mage will attempt to cast 
 *        damage spells on the player
 */

- (void) think:(Critter *)player
{
	[super think:player];
	
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
		} else if (player.target.critterForAction != nil && player.target.critterForAction != self && !haveHastened) {
			target.critterForAction = player.target.critterForAction;
			target.spellToCast = [Spell spellOfType:FIRECONDITION level:abilities.spells[FIRECONDITION]];
			haveHastened = TRUE;
			return;
		} else {
			//Each mage spell is given the same ability level, so even though a random spell type is being used, the ability
			//for the fire spell serves to represent any of them
			target.spellToCast = [Spell spellOfType:[Rand min:FIREDAMAGE max: POISONDAMAGE] level:abilities.spells[FIREDAMAGE]];
			return;
		}
	} else
		//Each mage spell is given the same ability level, so even though a random spell type is being used, the ability
		//for the fire spell serves to represent any of them
		target.spellToCast = [Spell spellOfType:[Rand min:FIREDAMAGE max: POISONDAMAGE] level:abilities.spells[FIREDAMAGE]];
}

@end
