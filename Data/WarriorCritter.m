//
//  WarriorCritter.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WarriorCritter.h"


@implementation WarriorCritter

- (id) initWithLevel:(int)lvl
{
	if (self = [super initWithLevel:lvl])
	{
		// Build his inventory
		stringIcon = @"monster-warrior.png";
	}
	return self;
}

- (void) think:(Critter *)player
{
	[super think:player];
	
}

@end
