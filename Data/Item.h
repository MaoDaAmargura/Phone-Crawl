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
	NSString *name;
	NSString *icon;
	BOOL isEquipable;
	int damage;
	int elementalDamage;
	int range;
	int charges;
	int pointValue; //Sell value + high score point value
	
	itemQuality quality; // Dull, Regular, Sharp, for critical hits
	slotType slot; //What slot can the item go in?
	elemType element; //Elemental type of item
	itemType type; //Item type
	int effectSpellId; //Which spell the item casts
	
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

@property (nonatomic) slotType slot;
@property (nonatomic) elemType element;
@property (nonatomic) itemType type;

@property (nonatomic,readonly) NSString *name;
@property (nonatomic,readonly) NSString *icon;
@property (nonatomic) itemQuality quality;
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
@property (nonatomic) int elementalDamage;
@property (nonatomic) int range;
@property (nonatomic) int charges;
@property (nonatomic) int pointValue;
@property (nonatomic) int effectSpellId;
@property (nonatomic,readonly) BOOL isEquipable;

- (NSString *) cast: (Creature *) caster target: (Creature *) target;

// Generate a random item based on the dungeon level and elemental type
+(Item *) generateRandomItem: (int) dungeonLevel elemType: (elemType) elementalType;
// Determine an item's value for high score
+ (int) getItemValue : (Item *) item; 

- (id) initWithBaseStats: (int) dungeonLevel elemType: (elemType) dungeonElement itemType: (itemType) desiredType;
- (id) initExactItemWithName: (NSString *) itemName
			 iconFileName: (NSString *) iconFileName
		  itemQuality: (itemQuality) quality
			 itemSlot: (slotType) desiredSlot 
			 elemType: (elemType) itemElement 
			 itemType: (itemType) desiredType 
				damage: (int) itemDamage 
		   elementalDamage: (int) elemDamage
			   charges: (int) numberOfCharges
				 range: (int) itemRange
					hp: (int) itemHP 
				shield: (int) itemShield 
				  mana: (int) itemMana 
				  fire: (int) itemFire 
				  cold: (int) itemCold 
			 lightning: (int) itemLightning 
				poison: (int) itemPoison 
				  dark: (int) itemDark 
				 armor: (int) itemArmor
			  effectSpellId: (int) itemSpellId;

@end
