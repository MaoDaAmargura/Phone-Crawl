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
const NSString **name_string{
	{"Sword", "Bastard Sword", "Blade", "Scimitar","Rapier"},
	{"Broadsword", "Greatsword", "Falchion","Claymore","Glaive",},
	{"Bow","Crossbow"},
	{"Dagger","Knife","Shank","Dirk","Stiletto"},
	{"Staff", "Rod", "Stave"},
	{"Plate Armor","Chainmail Armor","Steel Armor"},
	{"Cloth Armor", "Leather Armor","Useless Armor"},
	{"Shield", "Tower Shield", "Kite Shield", "Aegis", "Buckler"},
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

const NSString *elem_string1 = {"Fiery","Icy","Shocking","Venomous","Dark"};
const NSString *elem_string2 = {"Fire","Ice","Lightning","Poison","Darkness"};
const NSString *spell_name = {"Lesser","Minor","","Major","Superior"};

@implementation Item

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
{
	if (self = [super init]) {
        self.item_name = [NSString stringWithString: name];
        self.effect_amount = effect_amount;
        self.range = range;
        self.item_slot = item_slot;
        self.elem_type = elem_type;
        self.item_type = item_type;
        
        self.charges = charges;
        self.range = range;
        self.hp = hp;
        self.shield = shield; 
        self.mana = mana; 
        self.fire = fire; 
        self.cold = cold; 
        self.lightning = lightning; 
        self.poison = poison; 
        self.dark = dark; 
        self.armor = armor;
        self.spell_id = spell_id;
        
        self.point_val = [Item item_val:self];
        
        /* Left to do:
         * - item_slot / item_type checking
         * - item_val formulae
         */
		return self;
	}
	return nil;
}

-(NSString *)getName {
	return name;
}

-(item_type)getType {
	return type;
}

-(int)getAmount {
	return amount;
}

@implementation Item
// Generate a random item based on the dungeon level and elemental type
+(Item *) generate_random_item: (int) dungeon_level
					  elem_type: (elemType) elem_type {
    itemType item_type = arc4random() % NUM_ITEM_TYPES + SWO;
    slotType slot_type;
    switch(item_type) {
        case SWO:
        case DAG:
            slot_type = EITHER;
            break;
        case SWT:
        case BOW:
        case STF:
            slot_type = BOTH;
            break;
        case HVY:
        case LHT:
            slot_type = arc4random() % NUM_ARMOR_TYPES + HEAD;
            break;
        case SHD:
            slot_type = LEFT;
            break;
        case POT:
            if (arc4random()%2) {
                //sprintf(item_name,"%s Potion of Healing",spell_name[dungeon_level]);
                return [[Item alloc] init : item_name 
                                item_slot : BAG 
                                elem_type : DARK 
                                item_type : POT 
                            effect_amount : 1
                                  charges : 1
                                    range : 1 
                                       hp : 0 
                                   shield : 0 
                                     mana : 0 
                                     fire : 0 
                                     cold : 0 
                                lightning : 0
                                   poison : 0 
                                     dark : 0 
                                    armor : 0
                                 spell_id : ITEM_HEAL_SPELL_ID];
            } else {
                //sprintf(item_name,"%s Potion of Mana",spell_name[dungeon_level]);
                return [[Item alloc] init : item_name 
                                item_slot : BAG 
                                elem_type : DARK 
                                item_type : POT 
                            effect_amount : 1
                                    range : 1 
                                       hp : 0 
                                   shield : 0 
                                     mana : 0 
                                     fire : 0 
                                     cold : 0 
                                lightning : 0
                                   poison : 0 
                                     dark : 0 
                                    armor : 0
                                 spell_id : ITEM_MANA_SPELL_ID];
            }
            
        case WND:
			//sprintf(item_name,"%s Wand of %s Magic",spell_name[dungeon_level],elem_string1[dungeon_level]);
            return [[Item alloc] init : item_name
                            item_slot : BAG
                            elem_type : DARK
                            item_type : WND
                        effect_amount : 1
                              charges : arc4random() % (dungeon_level * 2) + 1
                                range : 1 
                                   hp : 0 
                               shield : 0 
                                 mana : 0 
                                 fire : 0 
                                 cold : 0 
                            lightning : 0
                               poison : 0 
                                 dark : 0 
                                armor : 0
                             spell_id : ITEM_MANA_SPELL_ID];
        case SCR:
			//sprintf(item_name,"Tome of Knowledge");
            return [[Item alloc] init: item_name
                            item_slot: BAG
                           elem_type : DARK
                           item_type : WND
                       effect_amount : 1
                             charges : 1
                               range : 1 
                                  hp : 0 
                              shield : 0 
                                mana : 0 
                                fire : 0 
                                cold : 0 
                           lightning : 0
                              poison : 0 
                                dark : 0 
                               armor : 0
                            spell_id : ITEM_MANA_SPELL_ID];	
		default:
			slot_type = BAG;
			break;
    };
    if(item_type == BOW)
        range = arc4random() % (MIN_BOW_RANGE + 2 * dungeon_level) + MIN_BOW_RANGE;
    else if(item_type == STF)
		range = arc4random % (4) + dungeon_level;
	else range = 1;
	
    NSString *item_name;
	//Name Generation:
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
	
	return [[Item alloc] init : item_name 
                    item_slot : slot_type 
					elem_type : elem_type 
					item_type : item_type 
                effect_amount : effect_amount 
                        range : range 
                           hp : hp 
                       shield : shield 
                         mana : mana 
                         fire : fire 
                         cold : cold 
                    lightning : lightning
                       poison : poison 
						 dark : dark 
						armor : armor];
	
    /* Left to do:
     *  - effect_amount generation (need to get spells / HP done first, combat system outlined)
     *  - stat generation (need to decide on numbers for stats -- formula for stats)
     *  - name generation
     *  - spell effects generation (need to get spells done first)
     */
	
}

+(int) item_val : (Item *) item {
    int point_val = 0;
    switch(item.item_slot){
        case HEAD: point_val += 10; break;
        case CHEST: point_val += 20; break;
        case LEFT: point_val += 15; break;
        case RIGHT: point_val += 15; break;
        case BAG: point_val += 5; break;
    };
    switch(item.item_type) {
        case SWO: // 1 handed sword
            point_val += item.effect_amount * 10;
        case SWT: // 2 handed sword
        case BOW: // Bow
        case DAG: // Dagger
        case STF: // Staff
        case HVY: // Heavy armor
        case LHT: // Light armor
        case SHD: // Shield
        case POT: // Potion
        case WND: // Wand
        case SCR:  // Scroll
			point_val = 2000;
    };
    return point_val;
	
    /* Left to do:
     * - Determine point values for stats / slots / types / range / effect_amnt
     * - Need to decide overall point system before this can be done
     */
}

@end
