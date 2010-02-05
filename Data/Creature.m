//
//  Creature.m
//  Phone-Crawl
//
//  Created by Benjamin Sangster on 1/23/10. 
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Creature.h"


@implementation Creature

@synthesize turn_speed;
@synthesize name;
@synthesize ability_points;
@synthesize level;
@synthesize creatureLocation;
@synthesize inventory;
@synthesize curr_health;
@synthesize curr_shield;
@synthesize curr_mana;
@synthesize money;
@synthesize max_health;
@synthesize max_shield;
@synthesize max_mana;
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

#pragma mark -
#pragma mark Life Cycle

- (id) initWithLevel: (int) lvl {
	return [self initWithInfo:@"Bob" level: lvl];
}

- (id) initWithInfo: (NSString *) in_name level: (int) lvl
{
	if(self = [super init])
	{
		name = in_name;
		self.creatureLocation = [Coord withX:0 Y:0 Z:0];
		head = [[[Item alloc] init] autorelease];
		chest = [[[Item alloc] init] autorelease];
		r_hand = [[[Item alloc] init] autorelease];
		l_hand = [[[Item alloc] init] autorelease];
		[self Set_Base_Stats];
		level = lvl;
		money = 10000;
		ability_points = 10;
		condition = NO_CONDITION;
		return self;
	}
	return nil;
}

- (int) statBase
{
	return 100 + 25*level;
}

- (id) init
{
	return [self initWithLevel:0];
}


- (void) Reset_Stats {
	[self Clear_Condition];
	max_health = real_max_health;
	max_shield = real_max_shield;
	max_mana = real_max_mana;
	turn_speed = real_turn_speed;
	if (curr_health > max_health) curr_health = max_health;
	if (curr_mana > max_mana) curr_mana = max_mana;
	if (curr_shield > max_shield) curr_shield = max_shield;
}

#pragma mark -
#pragma mark Helpers

- (void) Set_Base_Stats {
	turn_speed = 1.05;
	max_health = max_shield = max_mana = 100 + level * 25;
	curr_health = curr_shield = curr_mana = max_health;
	fire = cold = lightning =	poison = dark = 20;
	armor = 0;
	[self Update_Stats_Item:head];
	[self Update_Stats_Item:chest];
	[self Update_Stats_Item:l_hand];
	[self Update_Stats_Item:r_hand];
}

- (void) Update_Stats_Item: (Item*) item {
	max_health += item.hp;
	max_shield += item.shield;
	max_mana += item.mana;
	if(curr_health > max_health)
		curr_health = max_health;
	if(curr_shield > max_shield)
		curr_shield = max_shield;
	if(curr_mana > max_mana)
		curr_mana = max_mana;
	//Resists
	fire += item.fire;
	cold += item.cold;
	lightning += item.lightning;
	poison += item.poison;
	dark += item.dark;
	armor += item.armor;
}

- (void) Take_Damage: (int) amount {
	curr_shield -= amount;
	if (curr_shield < 0) {
		curr_health += curr_shield;
		curr_shield = 0;
	}
	if (curr_health <= 0) {
		curr_health = 0;
		//return @"Death!";
	}
}

- (void) Heal: (int) amount {
	curr_health += amount;
	if (curr_health > max_health) {
		curr_shield += (curr_health - max_health);
		curr_health = max_health;
		if (curr_shield > max_shield)
			curr_shield = max_shield;
	}
}

- (void) Mana_Heal:(int)amount {
	curr_mana += amount;
	if (curr_mana > max_mana) {
		curr_mana = max_mana;
	}
}

- (void) Add_Condition: (conditionType) new_condition { condition |= (1 << new_condition); }
- (void) Remove_Condition: (conditionType) rem_condition { condition = condition &~ (1 << rem_condition); }
- (void) Clear_Condition { condition = NO_CONDITION; }

- (void) Add_Equipment: (Item *) new_item slot: (slotType) dest_slot {
	if (new_item.item_slot == dest_slot || (new_item.item_slot == EITHER && (dest_slot == LEFT || dest_slot == RIGHT)) ||
		new_item.item_slot == BOTH && dest_slot == RIGHT){
		//Item fits in slot
		if (new_item.item_slot == BOTH && dest_slot == RIGHT && l_hand != nil)
			[self Remove_Equipment: LEFT];

		[self Update_Stats_Item:new_item];
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
		};
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
	};
	max_health -= rem_item.hp;
	max_shield -= rem_item.shield;
	max_mana -= rem_item.mana;
	if(curr_health > max_health)
		curr_health = max_health;
	if(curr_shield > max_shield)
		curr_shield = max_shield;
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
			if ([inventory objectAtIndex:inv_slot] == nil)
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
	[inventory insertObject:new_item atIndex:inv_slot];
	//Remove item from cursor
};
	
- (void) Remove_Inventory: (int) inv_slot {
	if(inv_slot >= NUM_INV_SLOTS || inv_slot < 0) {
		//No free inventory slots
		return;
	}
//	Item *rem_item = [inventory objectAtIndex:inv_slot];
	[inventory insertObject:nil atIndex:inv_slot];
	//return rem_item;
};

@end
