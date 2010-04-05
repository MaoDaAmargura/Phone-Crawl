//
//  BerserkerCritter.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BerserkerCritter.h"
#import "Spell.h"
#import "Skill.h"
#import "Item.h"

@implementation BerserkerCritter

- (id) initWithLevel:(int)lvl
{
	if (self = [super initWithLevel:lvl])
	{
		int dungeonLevel = level % 5;
		elemType elem = [Rand min:FIRE max: DARK];
		stringIcon = @"monster-hornman.png";
		stringName = @"Berserker";			
		for (int i = 0; i < NUM_PLAYER_SPELL_TYPES; ++i)
			abilities.spells[i] = 0;
		for (int i = 0; i < NUM_PLAYER_SKILL_TYPES; ++i)
			abilities.skills[i] = level % 7 + 1;	
		[self equipItem:[[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:SWORD_TWO_HAND] autorelease]];
	}
	return self;
}

- (void) think:(Critter *)player
{
	[super think:player];
	
}

@end
