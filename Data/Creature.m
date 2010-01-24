//
//  Creature.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Creature.h"


@implementation Creature

@synthesize creatureLocation;
@synthesize inventory;
@synthesize level, health, shield, mana;

#pragma mark -
#pragma mark Life Cycle

- (id) initWithLevel:(int) lvl
{
	if(self = [super init])
	{
		level = lvl;
		health = shield = mana = [self statBase];
		return self;
	}
	return nil;
}

- (id) init
{
	return [self initWithLevel:0];
}

#pragma mark -
#pragma mark Helpers

- (int) statBase
{
	return 100 + 25*level;
}

- (void) takeDamage:(int) amount
{
	int localAMT = amount;
	if(shield > localAMT)
	{ 
		shield -= localAMT;
	}
	else
	{
		localAMT -= shield;
		shield = 0;
		health -= localAMT;
	}
	
	if(health <= 0)
	{
		//die
	}
}

@end
