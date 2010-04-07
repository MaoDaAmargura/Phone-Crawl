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
		
		Item *sword = [[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:SWORD_ONE_HAND] autorelease];
		[self gainItem:sword];
		[self equipItem:sword];
		Item *shield = [[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:SHIELD] autorelease];
		[self gainItem:shield];
		[self equipItem:shield];
		Item *helm = [[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:HEAVY_HELM] autorelease];
		[self gainItem:helm];
		[self equipItem:helm];
		Item *plate = [[[Item alloc] initWithBaseStats:skillLevel-1 elemType:elem itemType:HEAVY_CHEST] autorelease];
		[self gainItem:plate];
		[self equipItem:plate];
	}
	return self;
}

- (void) think:(Critter *)player
{
	[super think:player];
	
	target.moveLocation = player.location;
	
	switch ([Rand min:0 max:2])
	{
		case 0:
			target.skillToUse = [Skill skillOfType:REG_STRIKE level:abilities.skills[REG_STRIKE]];
			break;
		case 1:
			target.skillToUse = [Skill skillOfType:QUICK_STRIKE level:abilities.skills[QUICK_STRIKE]];
			break;
		case 2:
			target.skillToUse = [Skill skillOfType:ELE_STRIKE level:abilities.skills[ELE_STRIKE]];
			break;


		default:
			break;
	}
}

@end

