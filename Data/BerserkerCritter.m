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
		int skillLevel = level / 5 + 1;
		elemType elem = [Rand min:FIRE max: DARK];
		stringIcon = @"monster-hornman.png";
		stringName = @"Berserker";			
		abilities.skills[REG_STRIKE] = skillLevel;
		abilities.skills[BRUTE_STRIKE] = skillLevel;
		Item *sword = [[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:SWORD_TWO_HAND] autorelease];
		[self gainItem:sword];
		[self equipItem:sword];
	}
	return self;
}

/*
 * Berserker AI logic:
 * -set move location
 * -randomly pick one of two different types of attacks
 */

- (void) think:(Critter *)player
{
	[super think:player];
	
	target.moveLocation = player.location;
	if ([Rand min:0 max:1])
		target.skillToUse = [Skill skillOfType:REG_STRIKE level:abilities.skills[REG_STRIKE]];
	else 
		target.skillToUse = [Skill skillOfType:REG_STRIKE level:abilities.skills[BRUTE_STRIKE]];
	
}

@end
