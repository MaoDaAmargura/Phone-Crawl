//
//  Engine.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Engine.h"

#import "Dungeon.h"
#import "Creature.h"
//#import "LevelGen.h"
#import "ItemGen.h"

@implementation Engine

#pragma mark -
#pragma mark Life Cycle
- (id) init
{
	if(self = [super init])
	{
		liveEnemies = [[NSMutableArray alloc] init];
		deadEnemies = [[NSMutableArray alloc] init];
		player = [[Creature alloc] init];
		currentDungeon = [[Dungeon alloc] initWithType:town];
		return self;
	}
	return nil;
}

- (void) dealloc
{
	[super dealloc];
	[liveEnemies release];
	[deadEnemies release];
	[player release];
	[currentDungeon release];
	
}

#pragma mark -
#pragma mark Delegate Callbacks

#pragma mark WorldView
/*!
 @method		worldTouchedAt
 @abstract		worldView callback for when world gets touched 
 @discussion	highlights the space the user touched, but allows them to change it.
				user hasn't stopped touching yet
 */
- (void) worldView:(WorldView*)wView touchedAt:(CGPoint)point
{
	
}

/*!
 @method		worldSelectedAt
 @abstract		worldView callback for when world gets selected
 @discussion	uses square as final choice for touch. Changes highlighted square
 */
- (void) worldView:(WorldView*) wView selectedAt:(CGPoint)point
{
	
}



@end
