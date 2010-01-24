//
//  Creature.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Util.h"

@interface Creature : NSObject 
{
	Coord *creatureLocation;

	int level;
	int health;
	int shield;
	int mana;
}

@property (nonatomic, retain) Coord *creatureLocation;
@property (nonatomic) int level;
@property (nonatomic) int health;
@property (nonatomic) int shield;
@property (nonatomic) int mana;

- (id) initWithLevel:(int) lvl;
- (id) init;

- (int) statBase;
- (void) takeDamage:(int) amount;

@end
