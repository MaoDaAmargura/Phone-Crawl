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
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:SWORD_ONE_HAND] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:LIGHT_HELM] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:HEAVY_CHEST] autorelease]];
	}
	return self;
}

- (void) think:(Critter *)player
{
	[super think:player];
	
}

@end
