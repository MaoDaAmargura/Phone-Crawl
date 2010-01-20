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

- (void) releaseResources
{
	[liveEnemies release];
	[deadEnemies release];
	[player release];
	[currentDungeon release];
}

- (void) dealloc
{
	[self releaseResources];
	[super dealloc];
	
}

- (void) loadDungeon:(Dungeon *)dungeon
{
	
}

- (void) updateWorldView:(WorldView*) wView
{
	Coord *center = [Coord newCoordWithX:5 Y:5 Z:1];
	int xInd, yInd;
	int windowWidth = 10, windowHeight = 10;
	
	CGRect bounds = wView.mapImageView.bounds;
	int imageWidth = bounds.size.width/windowWidth;
	int imageHeight = bounds.size.height/windowHeight;
	
	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	
	for (xInd = center.X-windowWidth/2; xInd < center.X+windowWidth/2; ++xInd)
	{
		for(yInd = center.Y-windowHeight/2; yInd < center.Y+windowHeight/2; ++yInd)
		{
			UIImage *img = [UIImage imageNamed:@"pokeball2.png"];//Some tile name
			CGContextDrawImage(context, CGRectMake(xInd*imageWidth, yInd*imageHeight, imageWidth, imageHeight), img.CGImage);
		}
	}
	
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	wView.mapImageView.image = result;
}

@end
