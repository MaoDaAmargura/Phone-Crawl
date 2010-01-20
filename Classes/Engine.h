//
//  Engine.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WorldView.h"

@class Creature;
@class Dungeon;

@interface Engine : NSObject 
{
	NSMutableArray *tileArray;
	
	NSMutableArray *liveEnemies; 
	NSMutableArray *deadEnemies;
	
	Creature *player;
	
	Dungeon *currentDungeon;
	
}

- (id) init;

- (void) updateWorldView:(WorldView*) wView;

@end
