//
//  WarriorCritter.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WarriorCritter.h"
#import "Spell.h"
#import "Skill.h"
#import "Item.h"

@implementation WarriorCritter

- (id) initWithLevel:(int)lvl
{
	if (self = [super initWithLevel:lvl])
	{
		int skillLevel = level/5 + 1;
		elemType elem = [Rand min:FIRE max: DARK];
		stringIcon = @"monster-warrior.png";
		stringName = @"Warrior";
		
		abilities.skills[REG_STRIKE] = skillLevel;
		abilities.skills[QUICK_STRIKE] = skillLevel;
		abilities.skills[ELE_STRIKE] = skillLevel;
		
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:SWORD_ONE_HAND] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:SHIELD] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:HEAVY_HELM] autorelease]];
		[self equipItem:[[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:HEAVY_CHEST] autorelease]];
	}
	return self;
}

- (void) think:(Critter *)player
{
	[super think:player];
	
}

@end

