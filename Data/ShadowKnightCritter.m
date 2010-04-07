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
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:SWORD_ONE_HAND] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:LIGHT_HELM] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:HEAVY_CHEST] autorelease]];
	}
	return self;
}

- (void) think:(Critter *)player
{
	[super think:player];
	
	target.moveLocation = player.location;
}

@end
