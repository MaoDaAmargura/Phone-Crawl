//
//  Item.h
//  Phone-Crawl
// 
//  Created by Benjamin Sangster on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spell.h"

//Items can always go in Bag, need non-bag slot to go in more
typedef enum {
    HEAD = 0,
    CHEST = 1,
    LEFT = 2,
    RIGHT = 3,
    BOTH = 4,
    EITHER = 5,
    BAG = 6
} slotType;

typedef enum {
	SWO = 0, // 1 handed sword
	SWT = 1, // 2 handed sword
	BOW = 2, // Bow
	DAG = 3, // Dagger
	STF = 4, // Staff
	HVY = 5, // Heavy armor
	LHT = 6, // Light armor
	SHD = 7, // Shield
	POT = 8, // Potion
	WND = 9, // Wand
	SCR = 10 // Scroll
} itemType;

@interface Item : NSObject {
	NSString *item_name;
	int effect_amount;
	int range; //Ranged damage for bow, staff
	int charges;
	int point_val; //Sell value + high score point value
	
	slotType item_slot; //What slot can the item go in?
	elemType elem_type; //Elemental type of item
	itemType item_type; //Item type
	int spell_id; //Which spell the item casts
	
	int hp;
	int shield;
	int mana;
	int fire;
	int cold;
	int lightning;
	int poison;
	int dark;
	int armor;
}

// Generate a random item based on the dungeon level and elemental type
+(Item *) generate_random_item: (int) dungeon_level
					 elem_type: (elemType) elem_type;

+(int) item_val : (Item *) item;

-(Item *)init:(NSString *) name 
	item_slot: (slotType) item_slot 
	elem_type: (elemType) elem_type 
	item_type: (itemType) item_type 
effect_amount: (int) effect_amount 
		range: (int) range 
	 charges : (int) charges
		   hp: (int) hp 
	   shield: (int) shield 
		 mana: (int) mana 
		 fire: (int) fire 
		 cold: (int) cold 
	lightning: (int) lightning 
	   poison: (int) poison 
		 dark: (int) dark 
		armor: (int) armor
	 spell_id: (int) spell_id;

-(NSString *)getName;
-(itemType)getType;
-(int)getAmount;

@end
