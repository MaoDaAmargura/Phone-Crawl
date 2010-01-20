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

#import "Tile.h"

// Engine Tile Quick References
#define NoTileImage [UIImage imageNamed:@"BlackSquare.png"]


@interface Engine (Private)

- (void) initTileArray;

@end


@implementation Engine

#pragma mark -
#pragma mark Life Cycle
- (id) init
{
	if(self = [super init])
	{
		tileArray = [[NSMutableArray alloc] init];
		liveEnemies = [[NSMutableArray alloc] init];
		deadEnemies = [[NSMutableArray alloc] init];
		player = [[Creature alloc] init];
		currentDungeon = [[Dungeon alloc] initWithType:town];
		
		[self initTileArray];
		return self;
	}
	return nil;
}

- (void) releaseResources
{
	[tileArray release];
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
	Coord *center = [Coord newCoordWithX:2 Y:2 Z:0];
	int xInd, yInd;
	int squaresWide = 10, squaresHigh = 10;
	
	CGRect bounds = wView.mapImageView.bounds;
	int imageWidth = bounds.size.width/squaresWide;
	int imageHeight = bounds.size.height/squaresHigh;
	
	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	int halfWide = squaresWide/2, halfHigh = squaresHigh/2;
	
	for (xInd = center.X-halfWide; xInd < center.X+halfWide; ++xInd)
	{
		for(yInd = center.Y-halfHigh; yInd < center.Y+halfHigh; ++yInd)
		{
			UIImage *img;
			if(xInd < 0 || yInd < 0 || xInd >= kMapDimension || yInd >= kMapDimension)
			{
				img = [tileArray objectAtIndex:0];
			}
			else
			{
				Tile *t = [currentDungeon tileAtX:xInd Y:yInd Z:center.Z];
				img = [tileArray objectAtIndex:t.type];
			}
			//img = [UIImage imageNamed:@"pokeball2.png"];//Some tile name
			CGContextDrawImage(context, CGRectMake((xInd+halfWide-center.X)*imageWidth, (yInd+halfHigh-center.Y)*imageHeight, imageWidth, imageHeight), img.CGImage);
		}
	}
	
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	wView.mapImageView.image = result;
}

/*!
 @method		initTileArray
 @abstract		helper function initializes the tile array
 @discussion	IMPORTANT: Elements MUST be added IN CORRESPONDING ORDER 
				to that which they are declared in the tileType enum in Tile.h
 */
- (void) initTileArray
{
	[tileArray addObject:[UIImage imageNamed:@"BlackSquare.png"]];
	[tileArray addObject:[UIImage imageNamed:@"DirtFloor.png"]];
	[tileArray addObject:[UIImage imageNamed:@"BarkFloor.png"]];
}

@end
