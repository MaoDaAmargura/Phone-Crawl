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
		int skillLevel = level / 6 + 1;
		elemType elem = [Rand min:FIRE max: DARK];
		stringIcon = @"monster-ghost.png";
		stringName = @"Rogue";
		abilities.spells[POISONDAMAGE] = skillLevel;
		abilities.spells[COLDCONDITION] = skillLevel;
		abilities.spells[POISONCONDITION] = skillLevel;
		abilities.skills[QUICK_STRIKE] = skillLevel;
		abilities.skills[ELE_STRIKE] = skillLevel;
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:DAGGER] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:DAGGER] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:LIGHT_HELM] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:LIGHT_CHEST] autorelease]];
	}
	return self;
}

- (void) think:(Critter *)player
{
	[super think:player];
	
}

@end
