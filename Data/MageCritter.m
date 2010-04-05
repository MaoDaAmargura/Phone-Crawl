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
		int dungeonLevel = level % 5;
		elemType elem = [Rand min:FIRE max: DARK];
		stringIcon = @"monster-iceman.png";
		stringName = @"Mage";
		for (int i = 0; i < NUM_PLAYER_SPELL_TYPES; ++i)
			abilities.spells[i] = dungeonLevel+1;
		for (int i = 0; i < NUM_PLAYER_SKILL_TYPES; ++i)
			abilities.skills[i] = 1; 
		[self equipItem:[[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:STAFF] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:LIGHT_HELM] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:LIGHT_CHEST] autorelease]];
	}
	return self;
}

- (void) think:(Critter *)player
{
	[super think:player];
	
}

@end
