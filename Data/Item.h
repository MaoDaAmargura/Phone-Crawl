#import <Foundation/Foundation.h>
#import "Util.h"

#define ITEM_NO_SPELL -1
#define STAFF_RANGE 5
#define MIN_BOW_RANGE 2
#define MAX_BOW_RANGE 6
#define NUM_ITEM_TYPES 13
#define OFFHAND_DMG_PERCENTAGE 0.75

@class Creature;

typedef enum {
	SWORD_ONE_HAND = 0,
	SWORD_TWO_HAND = 1,
	BOW = 2,
	DAGGER = 3,
	STAFF = 4,
	SHIELD = 5,
	HEAVY_HELM = 6,
	HEAVY_CHEST = 7,
	LIGHT_HELM = 8,
	LIGHT_CHEST = 9,
	POTION = 10,
	WAND = 11,
	SCROLL = 12
} itemType;

typedef enum {DULL,REGULAR,SHARP} itemQuality;

@interface Item : NSObject {
	NSString *item_name;
	NSString *item_icon;
	BOOL is_equipable;
	int damage;
	int elem_damage;
	int range;
	int charges;
	int point_val; //Sell value + high score point value
	
	itemQuality item_quality; // Dull, Regular, Sharp, for critical hits
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

@property (nonatomic,readonly) NSString *item_name;
@property (nonatomic,readonly) NSString *item_icon;
@property (nonatomic) int hp;
@property (nonatomic) int shield;
@property (nonatomic) int mana;
@property (nonatomic) int fire;
@property (nonatomic) int cold;
@property (nonatomic) int lightning;
@property (nonatomic) int poison;
@property (nonatomic) int dark;
@property (nonatomic) int armor;
@property (nonatomic) int damage;
@property (nonatomic) int elem_damage;
@property (nonatomic) int range;
@property (nonatomic) int charges;
@property (nonatomic) int spell_id;
@property (nonatomic,readonly) BOOL is_equipable;

- (int) cast: (Creature *) caster target: (Creature *) target;

// Generate a random item based on the dungeon level and elemental type
+(Item *) generate_random_item: (int) dungeon_level elem_type: (elemType) elem_type;
// Determine an item's value for high score
+ (int) item_val : (Item *) item; 

- (id) initWithBaseStats: (int) dungeon_level elem_type: (elemType) dungeon_elem item_type: (itemType) in_item_type item_slot: (slotType) in_slot_type;
- (id) initWithStats: (NSString *) in_name
			 icon_name: (NSString *) in_icon_name
		  item_quality: (itemQuality) in_item_quality
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
			  spell_id: (int) in_spell_id;

@end
