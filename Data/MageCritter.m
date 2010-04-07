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
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:STAFF] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:LIGHT_HELM] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:LIGHT_CHEST] autorelease]];
	}
	return self;
}

- (void) think:(Critter *)player
{
	[super think:player];
	
	//TODO: this should actually move to a nearby location good for casting 3-5 spaces away
	target.moveLocation = player.location; 
	
	
}

@end
