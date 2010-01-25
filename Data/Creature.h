//
//  Creature.h
//  Phone-Crawl
//
//  Created by Benjamin Sangster on 1/23/10. 
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Util.h"
#import "Item.h"
#import "Spell.h"

//#define NUM_EQUIP_SLOTS 4
#define NUM_INV_SLOTS 20
#define MAX_NUM_SPELLS 50
#define MAX_NUM_ABILITIES 100
#define STAT_MAX 100
#define STAT_MIN 0
#define FIRST_AVAIL_INV_SLOT -1

//Conditions
typedef uint32_t condition_bitset;
typedef enum {
	NO_CONDITION  = 0,
	BURNED        = 1,
	CHILLED		  = 2,
	HASTENED	  = 3,
	POISONED	  = 4,
	CURSED		  = 5,
	FIRE_HASTE    = 6, //Fire turn-speed buff
	COLD_SLOW     = 7, //Cold turn-speed debuff
	WEAKENED      = 8, //Max health debuff
	CONFUSION     = 9  //Confusion? Can't remember what this one was supposed to do. Stat debuff?
} conditionType;


@interface Creature : NSObject
{
    Coord *location;
	int aggro_range;
    int   level;
    float turn_speed;
    int   curr_hp;
    int   curr_shield;
    int   curr_mana;
	int   money;
	
	//Base stats
	condition_bitset condition;
	int max_hp;
	int max_shield;
	int max_mana;
	int strength;
	int dexterity;
	int willpower;
	//Resists
	int fire;
	int cold;
	int lightning;
	int poison;
	int dark;
	int armor;
    //currently 4 (Head, Chest, Right Hand, Left Hand)
    Item* head;
	Item* chest;
	Item* r_hand;
	Item* l_hand;
	
	NSMutableArray *inventory;
	
	//Spells aren't going to be randomly generated (not without creating a
	//much more complex spell system than we want to deal with), thus we
	//only need to store which spells in the pre-made block are unlocked
	
	//Spells stored in an NSArray, and a spellbook will be a list of the spell IDs
	int spellbook[MAX_NUM_SPELLS];
	
	
	//Combat abilities / passive abilities (Dodge, Counter-attack, Bash, etc)
	int abilities[MAX_NUM_ABILITIES];
}

- (void) Update_Stats_Item: (Item *);
- (void) Set_Base_Stats;

- (void) Take_Damage: (int) amount;
- (void) Heal: (int) amount;

- (void) Add_Condition: (conditionType) new_condition;
- (void) Remove_Condition: (conditionType) rem_condition;
- (void) Clear_Condition;

- (void) Add_Equipment: (Item *) new_item slot: (slotType) dest_slot;
- (void) Remove_Equipment: (slotType) dest_slot;
- (void) Add_Inventory: (Item *) new_item inv_slot: (int) inv_slot;
- (void) Remove_Inventory: (int) inv_slot;

@property (nonatomic, retain) Coord *location;
@property (nonatomic, retain) NSMutableArray inventory;

@property int money;
@property int curr_mana;
@property (readonly) int curr_hp;
@property (readonly) int curr_shield;
@property (readonly) int max_hp;
@property (readonly) int max_shield;
@property (readonly) int max_mana;
@property (readonly) int strength;
@property (readonly) int dexterity;
@property (readonly) int willpower;
@property (readonly) int fire;
@property (readonly) int cold;
@property (readonly) int lightning;
@property (readonly) int poison;
@property (readonly) int dark;
@property (readonly) int armor;
@property (nonatomic,retain) Item* head;
@property (nonatomic,retain) Item* chest;
@property (nonatomic,retain) Item* r_hand;
@property (nonatomic,retain) Item* l_hand;


@end
