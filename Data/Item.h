//
//  Item.h
//  Phone-Crawl
// 
//  Created by Benjamin Sangster on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//Items can always go in Bag, need non-bag slot to go in more
typedef enum {
    HEAD,
    CHEST,
    LEFT,
    RIGHT,
    BOTH,
    EITHER,
    BAG
} slotType;

typedef enum {
	SWO, // 1 handed sword
	SWT, // 2 handed sword
	BOW, // Bow
	DAG, // Dagger
	STF, // Staff
	HVY, // Heavy armor
	LHT, // Light armor
	SHD, // Shield
	POT, // Potion
	WND, // Wand
	SCR  // Scroll
} itemType;

@interface Item : NSObject {
	NSString *item_name;
	int effect_amount;
	int range; //Ranged damage for bow, staff, damage wands/scrolls
	int point_val; //Sell value + high score point value
	
	
	slotType item_slot; //What slot can the item go in?
	elemType elem_type; //Elemental type of item
	itemType item_type; //Item type
	int spell_id; //Which spell the item casts
}

// Generate a random item based on the dungeon level and elemental type
+(Item *) generate_random_item: (int) dungeon_level
					 elem_type: (elemType) elem_type;

// Generate an exact item
+(Item *) generate_item: (NSString *) name
			  item_slot: (slotType) item_slot
			  elem_type: (elemType) elem_type
			  item_type: (itemType) item_type
		  effect_amount: (int) effect_amount
				  range: (int) range
				  stats: (struct Stats*) stats;

+(int) item_val : (Item *) item;

-(Item *)init:(NSString *)name :(item_type)type :(int)amount;
-(NSString *)getName;
-(itemType)getType;
-(int)getAmount;

@end
