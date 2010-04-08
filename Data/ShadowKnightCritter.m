//
//  ShadowKnightCritter.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ShadowKnightCritter.h"
#import "Spell.h"
#import "Skill.h"
#import "Item.h"

@implementation ShadowKnightCritter

- (id) initWithLevel:(int)lvl
{
	if (self = [super initWithLevel:lvl])
	{
		int skillLevel = level / 6 + 1;
		elemType elem = [Rand min:FIRE max: DARK];
		stringIcon = @"monster-demon.png";
		stringName = @"Shadowknight";
		abilities.spells[DARKDAMAGE] = skillLevel;
		abilities.spells[POISONCONDITION] = skillLevel;
		abilities.spells[FIREDAMAGE] = skillLevel;
		abilities.skills[REG_STRIKE] = skillLevel;
		havePoisoned = FALSE;
		Item *sword = [[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:SWORD_TWO_HAND] autorelease];
		[self gainItem:sword];
		[self equipItem:sword];
		Item *helm = [[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:LIGHT_HELM] autorelease];
		[self gainItem:helm];
		[self equipItem:helm];
		Item *bp = [[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:HEAVY_CHEST] autorelease];
		[self gainItem:bp];
		[self equipItem:bp];
	}
	return self;
}

- (void) think:(Critter *)player
{
	[super think:player];
	
	target.moveLocation = player.location;
	if (current.sp == 0 && current.hp < (max.hp * .50))
		//Low health, use Dark Damage spell
		target.spellToCast = [Spell spellOfType:DARKDAMAGE level:abilities.spells[DARKDAMAGE]];
	else if (!havePoisoned) {
		//Poison player to deal damage for entire fight
		target.spellToCast = [Spell spellOfType:POISONCONDITION level:abilities.spells[POISONCONDITION]];
		havePoisoned = TRUE;
	}
	else if ([Rand min:0 max:1])
		target.spellToCast = [Spell spellOfType:FIREDAMAGE level:abilities.spells[FIREDAMAGE]];
	else
		target.skillToUse = [Skill skillOfType:abilities.skills[REG_STRIKE] level:abilities.skills[REG_STRIKE]];

		

}

@end
