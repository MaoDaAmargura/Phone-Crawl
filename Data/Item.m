//
//  Item.m
//  Phone-Crawl
//
//  Created by Benjamin Sangster on 1/23/10. 
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Item.h"

/*
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
 */
const NSString *name_string[8][2] = {
	{@"Sword",@"Scimitar"},
	{@"Greatsword",@"Glaive",},
	{@"Bow",@"Crossbow"},
	{@"Dagger",@"Dirk"},
	{@"Staff", @"Stave"},
	{@"Plate Armor",@"Chainmail Armor"},
	{@"Cloth Armor", @"Leather Armor"},
	{@"Tower Shield", @"Kite Shield"},
};

/*
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
 */

const NSString *elem_string1[] = {@"Fiery",@"Icy",@"Shocking",@"Venomous",@"Dark"};
const NSString *elem_string2[] = {@"Fire",@"Ice",@"Lightning",@"Poison",@"Darkness"};
const NSString *spell_name[] = {@"Lesser",@"Minor",@"",@"Major",@"Superior"};

const int base_item_stats[10][9] = {
  //{hp,shield,mana,resist,armor,damage,elemental damage,elemental stat adjustment}
    {8 , 5 , 0 , 5 , 0 , 40, 15, 7 , -2 }, //One handed Sword
    {10, 12, 0 , 5 , 5 , 50, 20, 15, -7 }, //Two handed Sword
    {5 , 10, 0 , 5 , -5, 35, 5 , 12, -2 }, //Bow
    {5 , 0 , 10, 3 , 0 , 25, 10, 3 , 0  }, //Dagger
    {8 , 10, 25, 7 , 5 , 15, 20, 15, -8 }, //Staff
    {20, 20, 10, 10, 12, 0 , 0 , 15, -5 }, //Heavy Chest
    {10, 10, 30, 12, 2 , 0 , 0 , 15, -3 }, //Light Chest
    {6 , 6 , 0 , 5 , 6 , 0 , 0 , 2 , 3  }, //Shield
    {5 , 10, 0 , 5 , 7 , 0 , 0 , 10, -5 }, //Heavy Helm
    {2 , 2 , 10, 2 , 1 , 0 , 0 , 10, -8 }, //Light Helm
};

@implementation Item

@synthesize item_slot;
@synthesize elem_type;
@synthesize item_type;

@synthesize hp;
@synthesize shield;
@synthesize mana;
@synthesize fire;
@synthesize cold;
@synthesize lightning;
@synthesize poison;
@synthesize dark;
@synthesize armor;
@synthesize damage;
@synthesize elem_damage;
@synthesize range;
@synthesize charges;

/*	//Name Generation:
 switch (item_type) {
 case SWO:
 case DAG:
 case SWT:
 case STF:
 case HVY:
 case LHT:
 case SHD:
 case BOW:
 if (arc4random() % 2) {
 //sprintf(item_name, "%s %s",elem_string1[elem_type],name_string[item_type][arc4random() % [name_string[item_type] count]]);
 } else {
 //sprintf(item_name, "%s of %s",name_string[item_type][arc4random() % [name_string[item_type] count]],elem_string2[elem_type]);
 }
 break;
 
 }
 */

-(Item *)initWithBaseStats: (int) dungeon_level elem_type: (elemType) dungeon_elem item_type: (itemType) in_item_type item_slot: (slotType) in_slot_type {
    if (self = [super init]) {
        item_name = @"Placeholder"; //Name format string here
        int base_stat_index = in_item_type + (in_slot_type == HEAD)? 3 : 0; //Offset needed because different base stats for helm and chest armor
        
        hp = dungeon_level * base_item_stats[base_stat_index][0];
        shield = dungeon_level * base_item_stats[base_stat_index][1];
        mana = dungeon_level * base_item_stats[base_stat_index][2];
        fire = cold = lightning = poison = dark = dungeon_level * base_item_stats[base_stat_index][8];
        switch (dungeon_elem) {
            case FIRE:
                fire = dungeon_level * base_item_stats[base_stat_index][3];
                break;
            case COLD:
                cold = dungeon_level * base_item_stats[base_stat_index][3];
                break;
            case LIGHTNING:
                lightning = dungeon_level * base_item_stats[base_stat_index][3];
                break;
            case POISON:
                poison = dungeon_level * base_item_stats[base_stat_index][3];
                break;
            case DARK:
                dark = dungeon_level * base_item_stats[base_stat_index][3];
                break;
        }
        armor = dungeon_level * base_item_stats[base_stat_index][4];
        damage = dungeon_level * base_item_stats[base_stat_index][5];
        elem_damage =dungeon_level * base_item_stats[base_stat_index][6];
        range = (in_item_type == BOW) ? (MIN_BOW_RANGE + dungeon_level) : (in_item_type == STAFF)? STAFF_RANGE : 1;
        charges = 0;
        item_slot = in_slot_type;
        elem_type = dungeon_elem;
        item_type = in_item_type;
        spell_id = ITEM_NO_SPELL;
        point_val = [Item item_val:self];
        return self;
    }
    return nil;
}

-(Item *)initWithStats: (NSString *) in_name 
    item_slot: (slotType) in_item_slot 
    elem_type: (elemType) in_elem_type 
    item_type: (itemType) in_item_type 
       damage: (int) in_damage
  elem_damage: (int) in_elem_damage
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
     spell_id: (int) in_spell_id
{
	if (self = [super init]) {
        item_name = [NSString stringWithString: in_name];
        damage = in_damage;
        elem_damage = in_elem_damage;
        range = in_range;
        item_slot = in_item_slot;
        elem_type = in_elem_type;
        item_type = in_item_type;
        
        charges = in_charges;
        range = in_range;
        hp = in_hp;
        shield = in_shield; 
        mana = in_mana; 
        fire = in_fire; 
        cold = in_cold; 
        lightning = in_lightning; 
        poison = in_poison; 
        dark = in_dark; 
        armor = in_armor;
        spell_id = in_spell_id;
        
        point_val = [Item item_val:self];
        
        /* Left to do:
         * - item_slot / item_type checking
         * - item_val formulae
         */
		return self;
	}
	return nil;
};

// Generate a random item based on the dungeon level and elemental type

//-(Item *)initWithBaseStats: (int) dungeon_level elem_type: (elemType) dungeon_elem item_type: (itemType) in_item_type item_slot: (slotType) in_slot_type
+(Item *) generate_random_item: (int) dungeon_level
					 elem_type: (elemType) elem_type {
    itemType item_type = arc4random() % NUM_ITEM_TYPES + SWORD_ONE_HAND;
    switch(item_type) {
        case SWORD_ONE_HAND:
        case DAGGER:
            return [[Item alloc] initWithBaseStats:dungeon_level elem_type:elem_type item_type:item_type item_slot:EITHER];
        case SWORD_TWO_HAND:
        case BOW:
        case STAFF:
            return [[Item alloc] initWithBaseStats:dungeon_level elem_type:elem_type item_type:item_type item_slot:BOTH];
        case HEAVY:
        case LIGHT:
            return [[Item alloc] initWithBaseStats:dungeon_level elem_type:elem_type item_type:item_type item_slot:arc4random() % NUM_ARMOR_TYPES + HEAD];
        case SHIELD:
            return [[Item alloc] initWithBaseStats:dungeon_level elem_type:elem_type item_type:item_type item_slot:LEFT];
        case POTION:
            if (arc4random()%2) {
                //(NSString *) name;
                //sprintf(item_name,"%s Potion of Healing",spell_name[dungeon_level]);
                return [[Item alloc] initWithStats : @"Healpot" 
                                          item_slot: BAG 
                                          elem_type: DARK 
                                          item_type: POTION
                                             damage: 0
                                        elem_damage: 0
                                            charges: 1
                                              range: 1 
                                                 hp: 0 
                                             shield: 0 
                                               mana: 0 
                                               fire: 0 
                                               cold: 0 
                                          lightning: 0
                                             poison: 0 
                                               dark: 0 
                                              armor: 0
                                           spell_id: ITEM_HEAL_SPELL_ID];
            } else {
                //(NSString *) name;
                //sprintf(item_name,"%s Potion of Mana",spell_name[dungeon_level]);
                return [[Item alloc] initWithStats : @"Manapot" 
                                          item_slot: BAG 
                                          elem_type: DARK 
                                          item_type: POTION 
                                             damage: 0
                                        elem_damage: 0
                                            charges: 1
                                              range: 1 
                                                 hp: 0 
                                             shield: 0 
                                               mana: 0 
                                               fire: 0 
                                               cold: 0 
                                          lightning: 0
                                             poison: 0 
                                               dark: 0 
                                              armor: 0
                                           spell_id: ITEM_MANA_SPELL_ID];
            }
            
        case WAND:
            //(NSString *) name;
			//sprintf(item_name,"%s Wand of %s Magic",spell_name[dungeon_level],elem_string1[dungeon_level]);
            return [[Item alloc] initWithStats : @"Wand"
                                      item_slot: BAG
                                      elem_type: DARK
                                      item_type: WAND
                                         damage: 0
                                    elem_damage: 0
                                        charges: arc4random() % (dungeon_level * 2) + 1
                                          range: 1 
                                             hp: 0 
                                         shield: 0 
                                           mana: 0 
                                           fire: 0 
                                           cold: 0 
                                      lightning: 0
                                         poison: 0 
                                           dark: 0 
                                          armor: 0
                                       spell_id: ITEM_MANA_SPELL_ID];
        case SCROLL:
            return [[Item alloc] initWithStats: @"Tome of Knowledge"
                                     item_slot: BAG
                                     elem_type: DARK
                                     item_type: SCROLL
                                        damage: 0
                                   elem_damage: 0
                                       charges: 1
                                         range: 1 
                                            hp: 0 
                                        shield: 0 
                                          mana: 0 
                                          fire: 0 
                                          cold: 0 
                                     lightning: 0
                                        poison: 0 
                                          dark: 0 
                                         armor: 0
                                      spell_id: ITEM_MANA_SPELL_ID];
        default:
            //NSLog("Error in random item generation");
            return nil;
    };
	
    /* Left to do:
     *  - name generation
     *  - spell effects generation (need to get spells done first)
     */
	
};

+(int) item_val : (Item *) item {
    if (item == nil) {
        return -1;
    }
    int point_val = 0;
    switch(item.item_slot){
        case HEAD: point_val += 10; break;
        case CHEST: point_val += 20; break;
        case LEFT: point_val += 15; break;
        case RIGHT: point_val += 15; break;
        case BAG: point_val += 5; break;
    };
    switch(item.item_type) {
        case SWORD_ONE_HAND: // 1 handed sword
            point_val += item.damage * 10;
            point_val += item.elem_damage * 10;
        case SWORD_TWO_HAND: // 2 handed sword
        case BOW: // Bow
        case DAGGER: // Dagger
        case STAFF: // Staff
        case HEAVY: // Heavy armor
        case LIGHT: // Light armor
        case SHIELD: // Shield
        case POTION: // Potion
        case WAND: // Wand
        case SCROLL:  // Scroll
			point_val = 2000;
    };
    return point_val;
	
    /* Left to do:
     * - Determine point values for stats / slots / types / range / effect_amnt
     * - Need to decide overall point system before this can be done
     */
};


@end
