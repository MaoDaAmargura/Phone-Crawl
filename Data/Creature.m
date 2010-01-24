//
//  Creature.m
//  Phone-Crawl
//
//  Created by Benjamin Sangster on 1/23/10. 
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Creature.h"


@implementation Creature

@synthesize location;
@synthesize curr_hp;
@synthesize curr_shield;
@synthesize curr_mana;
@synthesize money;
@synthesize max_hp;
@synthesize max_shield;
@synthesize max_mana;
@synthesize strength;
@synthesize dexterity;
@synthesize willpower;
@synthesize fire;
@synthesize cold;
@synthesize lightning;
@synthesize poison;
@synthesize dark;
@synthesize armor;
@synthesize head;
@synthesize chest;
@synthesize r_hand;
@synthesize l_hand;

- (id) init
{
	if(self = [super init])
	{
		location = [[[Coord alloc] init] autorelease];
		head = [[[Item alloc] init] autorelease];
		chest = [[[Item alloc] init] autorelease];
		r_hand = [[[Item alloc] init] autorelease];
		l_hand = [[[Item alloc] init] autorelease];
		
		level = 5;
		max_hp = 100 + level * 25;
		max_shield = max_hp;
		money = 10000;
		strength = 5;
		dexterity = 5;
		willpower = 5;
		fire = 20;
		cold = 20;
		lightning = 20;
		poison = 20;
		dark = 20;
		armor = 0;
		condition = NO_CONDITION;
		
		return self;
	}
	return nil;
}


- (void) Add_Condition: (conditionType) new_condition { condition |= (1 << new_condition); }
- (void) Remove_Condition: (conditionType) rem_condition { condition = condition &~ (1 << new_condition); }

- (void) Add_Equipment: (Item *) new_item slot: (slotType) dest_slot {
	if (new_item.item_slot == dest_slot || (new_item.item_slot == EITHER && (dest_slot == LEFT || dest_slot == RIGHT)) ||
		new_item.item_slot == BOTH && dest_slot == LEFT){
		//Item fits in slot
		if (new_item.item_slot == BOTH && dest_slot == LEFT && r_hand != nil)
			[self Remove_Equipment: RIGHT];

		max_hp += new_item.hp;
		max_shield += new_item.shield;
		max_mana += new_item.mana;
		//Resists
		fire += new_item.fire;
		cold += new_item.cold;
		lightning += new_item.lightning;
		poison += new_item.poison;
		dark += new_item.dark;
		armor += new_item.armor;
		switch (dest_slot) {
			case HEAD:
				head = new_item;
				break;
			case CHEST:
				chest = new_item;
				break;
			case LEFT:
				l_hand = new_item;
				break;
			case RIGHT:
				r_hand = new_item;
				break;				
		}
	} else {
		//Item slot error
	}
	//Item removed from cursor
	return;
}

- (void) Remove_Equipment: (slotType) dest_slot {
	Item *rem_item;
	switch (dest_slot) {
		case HEAD:
			rem_item = head;
			head = nil;
			break;
		case CHEST:
			rem_item = chest;
			chest = nil;
			break;
		case LEFT:
			rem_item = l_hand;
			l_hand = nil;
			break;
		case RIGHT:
			rem_item = r_hand;
			r_hand = nil;
			break;				
	}
	max_hp -= rem_item.hp;
	if(curr_hp > max_hp)
		curr_hp = max_hp;
	max_shield -= rem_item.shield;
	if(curr_shield > max_shield)
		curr_shield = max_shield;
	max_mana -= rem_item.mana;
	if(curr_mana > max_mana)
		curr_mana = max_mana;
	//Resists
	fire -= rem_item.fire;
	cold -= rem_item.cold;
	lightning -= rem_item.lightning;
	poison -= rem_item.poison;
	dark -= rem_item.dark;
	armor -= rem_item.armor;
	//Item needs to be moved to cursor
	//return rem_item;
};
	
- (void) Add_Inventory: (Item *) new_item inv_slot: (int) inv_slot {
	if (inv_slot == FIRST_AVAIL_INV_SLOT) {
		for (inv_slot = 0; inv_slot < NUM_INV_SLOTS; ++inv_slot) {
			if (inventory[inv_slot] == nil)
				break;
		}
		if (inv_slot >= NUM_INV_SLOTS) {
			//No free inventory slots
			return;
		}
	} else if (inv_slot >= NUM_INV_SLOTS || inv_slot < FIRST_AVAIL_INV_SLOT) {
		//Invalid inventory slot
		return;
	}
	inventory inv_slot = new_item;
	//Remove item from cursor
};
	
- (void) Remove_Inventory: (int) inv_slot {
	if(inv_slot >= NUM_INV_SLOTS || inv_slot < 0) {
		//No free inventory slots
		return;
	}
	Item *rem_item = inventory[inv_slot];
	//return rem_item;
};
	

@end
