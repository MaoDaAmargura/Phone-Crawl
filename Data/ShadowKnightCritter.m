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
		int dungeonLevel = level % 5;
		elemType elem = [Rand min:FIRE max: DARK];
		stringIcon = @"monster-demon.png";
		stringName = @"Shadowknight";
		for (int i = 0; i < FIRECONDITION; ++i)
			abilities.spells[i] = dungeonLevel;
		for (int i = 0; i < NUM_PLAYER_SKILL_TYPES; ++i)
			abilities.skills[i] = level % 8 + 1;
		[self equipItem:[[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:SWORD_ONE_HAND] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:LIGHT_HELM] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:HEAVY_CHEST] autorelease]];
	}
	return self;
}

- (void) think:(Critter *)player
{
	[super think:player];
	
}

@end
