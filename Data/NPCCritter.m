//
//  NPCCritter.m
//  Phone-Crawl
//
//  Created by Bucky24 on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NPCCritter.h"


@implementation NPCCritter

- (id) initWithLevel:(int)lvl
{
	if (self = [super initWithLevel:lvl])
	{
		//int dungeonLevel = level % 5;
		//elemType elem = [Rand min:FIRE max: DARK];
		stringIcon = @"shopkeeper.png";
		stringName = @"NPC";
	}
	return self;
}

- (void) think:(Critter *)player
{
	[super think:player];
	
}

@end
