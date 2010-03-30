//
//  Critter.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Critter;
@class Item;
@class Spell;
@class CombatAbility;
@class Coord;


typedef enum {
	NO_CONDITION  = 0,
	BURNED        = 1,
	CHILLED		  = 2,
	HASTENED	  = 4,
	POISONED	  = 8,
	CURSED		  = 16,
	FIRE_HASTE    = 32, //Fire turn-speed buff
	COLD_SLOW     = 64, //Cold turn-speed debuff
	WEAKENED      = 128, //Max health debuff
	CONFUSION     = 256  //Messes with AI calls
} conditionType;

typedef struct {
	int hp;
	int sp;
	int mp;
	int ts;
} CritterStats;

typedef struct {
	Coord *moveLocation;
	Item *itemForUse;
	Spell *spellToCast;
	CombatAbility *skillToUse;
	Critter *critterForAction;
} ActionTargets;

typedef struct {
	Item *lhand;
	Item *rhand;
	Item *chest;
	Item *head;
} EquippedItems;

typedef struct {
	int fire;
	int frost;
	int shock;
	int dark;
	int poison;
	int armor;
} DefenseStats;

@interface Critter : NSObject 
{
	NSString *stringName;
	NSString *stringIcon;
	
	Coord *location;
	
	int conditionBitSet;
	
	EquippedItems equipment;
	ActionTargets target;
	
	CritterStats current;
	CritterStats total;
	
	DefenseStats defense;
	
	NSMutableArray *inventory;
	int money;
	
	int experience;
	int level;
	int abilityPoints;
	int deathPenalty;

	BOOL alive;
	@private
	CritterStats real;
}

- (id) initWithLevel:(int)lvl;

- (void) gainCondition:(conditionType)cond;
- (void) loseCondition:(conditionType)cond;

- (void) takeDamage:(int)amount;
- (void) gainHealth:(int)amount;

- (void) gainItem:(Item*)it;
- (void) loseItem:(Item*)it;
- (void) equipItem:(Item*)it;
- (void) dequipItem:(Item*)it;
- (BOOL) hasItemEquipped:(Item*)it;

- (float) getPhysDamage;
- (float) getElemDamage;

@end


