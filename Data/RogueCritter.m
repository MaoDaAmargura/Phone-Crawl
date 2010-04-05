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
		int dungeonLevel = level % 5;
		elemType elem = [Rand min:FIRE max: DARK];
		stringIcon = @"monster-ghost.png";
		stringName = @"Rogue";
		abilities.spells[POISONDAMAGE] = dungeonLevel+1;
		abilities.spells[COLDCONDITION] = dungeonLevel+1;
		abilities.spells[POISONCONDITION] = dungeonLevel+1;
		for (int i = 0; i < NUM_PLAYER_SKILL_TYPES; ++i)
			abilities.skills[i] = level % 9 + 1;
		[self equipItem:[[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:DAGGER] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:DAGGER] autorelease]];
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
