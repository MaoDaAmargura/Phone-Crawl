//
//  Item.h
//  Phone-Crawl
// 
//  Created by Benjamin Sangster on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Spell.h"
#import "Util.h"



#define MIN_BOW_RANGE 2
#define NUM_ITEM_TYPES 11
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

@property (nonatomic) slotType item_slot;
@property (nonatomic) elemType elem_type;
@property (nonatomic) itemType item_type;

@property (nonatomic) int hp;
@property (nonatomic) int shield;
@property (nonatomic) int mana;
@property (nonatomic) int fire;
@property (nonatomic) int cold;
@property (nonatomic) int lightning;
@property (nonatomic) int poison;
@property (nonatomic) int dark;
@property (nonatomic) int armor;
@property (nonatomic) int effect_amount;
@property (nonatomic) int range;
@property (nonatomic) int charges;

// Generate a random item based on the dungeon level and elemental type
+(Item *) generate_random_item: (int) dungeon_level
					 elem_type: (elemType) elem_type;

+(int) item_val : (Item *) item;

-(Item *)initWithStats: (NSString *) in_name 
			 item_slot: (slotType) in_item_slot 
			 elem_type: (elemType) in_elem_type 
			 item_type: (itemType) in_item_type 
		 effect_amount: (int) in_effect_amount 
			   charges: (int) in_charges
				 range: (int) in_range
					hp: (int) in_hp 
				shield: (int) in_shield 
				  mana: (int) in_mana 
				  fire: (int) in_fire 
				  cold: (int) in_cold 
			 lightning: (int) in_lightning 
				poison: (int) in_poison 
				  dark: (int) in_dark 
				 armor: (int) in_armor
			  spell_id: (int) in_spell_id;

@end
