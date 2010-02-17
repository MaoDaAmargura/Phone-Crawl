//
//  Creature.m
//  Phone-Crawl
//
//  Created by Benjamin Sangster on 1/23/10. 
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Creature.h"
#import "Item.h"

@implementation Creature

@synthesize current_turn_points;
@synthesize name;
@synthesize ability_points;
@synthesize level;
@synthesize creatureLocation;
@synthesize inventory;
@synthesize money;
@synthesize fire;
@synthesize cold;
@synthesize lightning;
@synthesize poison;
@synthesize dark;
@synthesize armor;
@synthesize equipment;
@synthesize current;
@synthesize max;


#pragma mark -
#pragma mark Life Cycle

- (id) initWithLevel: (int) lvl {
	return [self initWithInfo:@"Bob" level: lvl];
}

- (id) initWithInfo: (NSString *) in_name level: (int) lvl
{
	if(self = [super init])
	{
		name = [NSString stringWithString:in_name];
		self.creatureLocation = [Coord withX:0 Y:0 Z:0];
		[self Set_Base_Stats];
		equipment = [EquipSlots alloc];
		equipment.head = [[[Item alloc] init] autorelease];
		equipment.chest = [[[Item alloc] init] autorelease];
		equipment.r_hand = [[[Item alloc] init] autorelease];
		equipment.l_hand = [[[Item alloc] init] autorelease];
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
	max.health = real.health;
	max.shield = real.shield;
	max.mana = real.mana;
	current.turn_speed = max.turn_speed = real.turn_speed;
	if (current.health > max.health) current.health = max.health;
	if (current.mana > max.mana) current.mana = max.mana;
	if (current.shield > max.shield) current.shield = max.shield;
}

#pragma mark -
#pragma mark Helpers

- (void) Set_Base_Stats {
	current.turn_speed = 1.05;
	real.turn_speed = 1.05;
	max.turn_speed = 1.05;
	max.health = max.shield = max.mana = 100 + level * 25;
	current.health = current.shield = current.mana = max.health;
	fire = cold = lightning = poison = dark = 20;
	armor = 0;
	[self Update_Stats_Item:equipment.head];
	[self Update_Stats_Item:equipment.chest];
	[self Update_Stats_Item:equipment.l_hand];
	[self Update_Stats_Item:equipment.r_hand];
}

- (void) Update_Stats_Item: (Item*) item {
	max.health += item.hp;
	max.shield += item.shield;
	max.mana += item.mana;
	real.health += item.hp;
	real.shield += item.shield;
	real.mana += item.mana;
	if(current.health > max.health)
		current.health = max.health;
	if(current.shield > max.shield)
		current.shield = max.shield;
	if(current.mana > max.mana)
		current.mana = max.mana;
	//Resists
	fire += item.fire;
	cold += item.cold;
	lightning += item.lightning;
	poison += item.poison;
	dark += item.dark;
	armor += item.armor;
}

- (void) Take_Damage: (int) amount {
	current.shield -= amount;
	if (current.shield < 0) {
		current.health += current.shield;
		current.shield = 0;
	}
	if (current.health <= 0) {
		current.health = 0;
		//return @"Death!";
	}
}

- (void) Heal: (int) amount {
	current.health += amount;
	if (current.health > max.health) {
		current.shield += (current.health - max.health);
		current.health = max.health;
		if (current.shield > max.shield)
			current.shield = max.shield;
	}
}

- (void) Mana_Heal:(int)amount {
	current.mana += amount;
	if (current.mana > max.mana) {
		current.mana = max.mana;
	}
}

- (void) Add_Condition: (conditionType) new_condition { condition |= new_condition; }
- (void) Remove_Condition: (conditionType) rem_condition { condition = condition &~ rem_condition; }
- (void) Clear_Condition { condition = NO_CONDITION; }

- (void) Add_Equipment: (Item *) new_item slot: (slotType) dest_slot {
	if (new_item.item_slot == dest_slot || (new_item.item_slot == EITHER && (dest_slot == LEFT || dest_slot == RIGHT)) ||
		new_item.item_slot == BOTH && dest_slot == RIGHT){
		//Item fits in slot
		if (new_item.item_slot == BOTH && dest_slot == RIGHT && equipment.l_hand != nil)
			[self Remove_Equipment: LEFT];

		[self Update_Stats_Item:new_item];
		switch (dest_slot) {
			case HEAD:
				equipment.head = new_item;
				break;
			case CHEST:
				equipment.chest = new_item;
				break;
			case LEFT:
				equipment.l_hand = new_item;
				break;
			case RIGHT:
				equipment.r_hand = new_item;
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
			rem_item = equipment.head;
			equipment.head = nil;
			break;
		case CHEST:
			rem_item = equipment.chest;
			equipment.chest = nil;
			break;
		case LEFT:
			rem_item = equipment.l_hand;
			equipment.l_hand = nil;
			break;
		case RIGHT:
			rem_item = equipment.r_hand;
			equipment.r_hand = nil;
			break;				
	};
	max.health -= rem_item.hp;
	max.shield -= rem_item.shield;
	max.mana -= rem_item.mana;
	real.health -= rem_item.hp;
	real.shield -= rem_item.shield;
	real.mana -= rem_item.mana;
	if(current.health > max.health)
		current.health = max.health;
	if(current.shield > max.shield)
		current.shield = max.shield;
	if(current.mana > max.mana)
		current.mana = max.mana;
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

- (int) regular_weapon_damage {
	int dmg = 0;
	if (equipment.r_hand != NULL) dmg+=equipment.r_hand.damage;
	if (equipment.l_hand != NULL && (equipment.l_hand.item_type == SWORD_ONE_HAND || equipment.l_hand.item_type == DAGGER)) dmg+=equipment.l_hand.damage * OFFHAND_DMG_PERCENTAGE;
	return dmg;
}

- (int) elemental_weapon_damage {
	int dmg = 0;
	if (equipment.r_hand != NULL) dmg+=equipment.r_hand.elem_damage;
	if (equipment.l_hand != NULL && (equipment.l_hand.item_type == SWORD_ONE_HAND || equipment.l_hand.item_type == DAGGER)) dmg+=equipment.l_hand.elem_damage * OFFHAND_DMG_PERCENTAGE;
	return dmg;
}

@end

@implementation EquipSlots
@synthesize head;
@synthesize chest;
@synthesize l_hand;
@synthesize r_hand;
@end

@implementation Points
@synthesize health;
@synthesize shield;
@synthesize mana;
@synthesize turn_speed;
@end
