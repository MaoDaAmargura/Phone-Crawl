//
//  Creature.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Util.h"
#import "Item.h"

@interface Creature : NSObject 
{
	Coord *creatureLocation;
	
	NSMutableArray *inventory;

	int level;
	int health;
	int shield;
	int mana;
	
	Item *weaponLeft;
	Item *weaponRight;
	Item *armorHead;
	Item *armorBody;
}

@property (nonatomic, retain) Coord *creatureLocation;
@property (nonatomic, retain) NSMutableArray *inventory;

@property (nonatomic) int level;
@property (nonatomic) int health;
@property (nonatomic) int shield;
@property (nonatomic) int mana;
@property (nonatomic, retain) Item *weaponLeft;
@property (nonatomic, retain) Item *weaponRight;
@property (nonatomic, retain) Item *armorHead;
@property (nonatomic, retain) Item *armorBody;

- (id) initWithLevel:(int) lvl;
- (id) init;

- (int) statBase;
- (void) takeDamage:(int) amount;

@end
