//
//  PaladinCritter.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PaladinCritter.h"
#import "Spell.h"
#import "Skill.h"
#import "Item.h"

@implementation PaladinCritter

- (id) initWithLevel:(int)lvl
{
	if (self = [super initWithLevel:lvl])
	{
		int skillLevel = level / 6 + 1;
		elemType elem = [Rand min:FIRE max: DARK];
		stringIcon = @"monster-ogre.png";
		stringName = @"Paladin";
		abilities.spells[FIREDAMAGE] = skillLevel;
		abilities.spells[LIGHTNINGCONDITION] = skillLevel;
		abilities.skills[REG_STRIKE] = skillLevel;
		abilities.skills[BRUTE_STRIKE] = skillLevel;
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
	if (conditionBitSet&CONFUSION) {
		target.critterForAction = self;
		target.spellToCast = [Spell spellOfType:LIGHTNINGCONDITION level:abilities.spells[LIGHTNINGCONDITION]];
	} else 	switch ([Rand min:0 max:2]) {
		case 0:
			target.skillToUse = [Skill skillOfType:REG_STRIKE level:abilities.skills[REG_STRIKE]];
			break;
		case 1:
			target.skillToUse = [Skill skillOfType:QUICK_STRIKE level:abilities.skills[BRUTE_STRIKE]];
			break;
		case 2:
			target.skillToUse = [Skill skillOfType:ELE_STRIKE level:abilities.skills[FIREDAMAGE]];
			break;
			
			
		default:
			break;
	}
}

@end
