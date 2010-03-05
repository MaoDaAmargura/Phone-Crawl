#import <Foundation/Foundation.h>
#import "Util.h"

@class Item,Spell,CombatAbility;
@class Dungeon;

//#define NUM_EQUIP_SLOTS 4
#define NUM_INV_SLOTS 20
#define MAX_NUM_SPELLS 50
#define MAX_NUM_ABILITIES 100
#define STAT_MAX 100
#define STAT_MIN 0
#define FIRST_AVAIL_INV_SLOT -1

//Examples -- we'll need a couple more, in all likelihood.
//I can add a new method to Creature like -initMonsterOfType: (creatureType) type level: (int) in_level
//which creates a default creature of a type with a specific set of equipment and inventory.
//That will likely be useful, as the two "create" functions that we use now will only be useful for
//creating NEW characters -- we'll need a new init that loads saved data.
typedef enum {
	WARRIOR,
	ARCHER,
	FIREBOSS,
	COLDBOSS,
	SHOCKBOSS,
	POISONBOSS,
	DARKBOSS,
	MERCHANT,
	PLAYER
} creatureType;


//Conditions
typedef uint32_t condition_bitset;
typedef enum {
	NO_CONDITION  = 0,
	BURNED        = 1,
	CHILLED		  = 2,
	HASTENED	  = 4,
	POISONED	  = 8,
	CURSED		  = 16,
	FIRE_HASTE    = 32, //Fire turn-speed buff
	COLD_SLOW     = 64, //Cold turn-speed debuff
	WEAKENED      = 128, //Max health debuff
	CONFUSION     = 256  //Messes with AI calls
} conditionType;

@interface Abilities : NSObject
{
	//Spell book currently has 10 indexes that will go from 1-5 indicating the level of the corresponding spell
	//See "PC_SPELL_TYPE" enum in util.h
	int *spellBook; //[NUM_PC_SPELL_TYPES]
	//Combat abilities / passive abilities (Dodge, Counter-attack, Bash, etc)
	int *combatAbility; //[NUM_COMBAT_ABILITY_TYPES]
}
@property (nonatomic) int* spellBook;
@property (nonatomic) int* combatAbility;
- (id) init;
- (void) setSpellBookArray:(int []) sb;
- (void) setCombatAbilityArray:(int []) cb;
@end

@interface Points : NSObject {
	int health;
	int shield;
	int mana;
	int turnSpeed;
}
@property (nonatomic) int health;
@property (nonatomic) int shield;
@property (nonatomic) int mana;
@property (nonatomic) int turnSpeed;
@end

@interface EquipSlots : NSObject {
	Item *head;
	Item *chest;
	Item *rHand;
	Item *lHand;
}
- (id) init;
@property (nonatomic, retain) Item* head;
@property (nonatomic, retain) Item* chest;
@property (nonatomic, retain) Item* rHand;
@property (nonatomic, retain) Item* lHand;
@end

@interface Creature : NSObject {
	NSString *name;
	creatureType type;
	Coord *creatureLocation;
	
	Creature *selectedCreatureForAction;
	
	CombatAbility *selectedCombatAbilityToUse;
	Spell *selectedSpellToUse;
	Item *selectedItemToUse;
	Coord *selectedMoveTarget;
	
	NSString *iconName;
	
	float experiencePoints;
	
	int aggroRange;
    int   level;
	int turnPoints;

	condition_bitset condition;
	Points *current;
	Points *max;

	int   money;
	int   abilityPoints;

	//Resists
	int fire;
	int cold;
	int lightning;
	int poison;
	int dark;
	int armor;
	
    //currently 4 (Head, Chest, Right Hand, Left Hand)
	EquipSlots *equipment;
	NSMutableArray *inventory;
	Abilities *abilities;

	
	@private
	Points *real;
}

- (id) initPlayerWithLevel: (int) lvl;
- (id) initPlayerWithInfo: (NSString *) inName level: (int) lvl;
- (id) initMonsterOfType: (creatureType) monsterType withElement:(elemType)elem level: (int) inLevel atX:(int)x Y:(int)y Z:(int)z;


//Reset stats modified by conditions during combat
- (void) resetStats;
- (int) statBase;
- (void) updateStatsItem: (Item *) item;
- (void) setBaseStats;

- (void) ClearTurnActions;

- (void) gainExperience: (float) amount;
- (void) takeDamage: (int) amount;
- (void) heal: (int) amount;
- (void) healMana: (int) amount;

- (void) addCondition: (conditionType) newCondition;
- (void) removeCondition: (conditionType) removeCondition;
- (void) clearCondition;

- (void) addEquipment: (Item *) item slot: (slotType) destSlot;
- (void) removeEquipment: (slotType) destSlot;
- (void) addInventory: (Item *) item inSlotNumber: (int) slotNumber;
- (void) removeItemFromInventoryInSlot: (int) slotNumber;

- (int) regularWeaponDamage;
- (int) elementalWeaponDamage;

- (BOOL) hasActionToTake;

+ (Creature*) newPlayerWithName:(NSString*) name andIcon:(NSString*)icon;

@property (nonatomic, retain) Coord *creatureLocation;
@property (nonatomic, retain) NSMutableArray *inventory;
@property (nonatomic, retain) Abilities *abilities;

@property (nonatomic, retain) Creature *selectedCreatureForAction;
@property (nonatomic, retain) CombatAbility *selectedCombatAbilityToUse;
@property (nonatomic, retain) Spell *selectedSpellToUse;
@property (nonatomic, retain) Item *selectedItemToUse;
@property (nonatomic, retain) Coord *selectedMoveTarget;

@property (nonatomic,retain) EquipSlots *equipment;
@property (nonatomic,retain) Points *current;
@property (nonatomic,retain) Points *max;
@property (nonatomic) int turnPoints;
@property (nonatomic, readonly, retain) NSString *name;
@property int money;
@property int abilityPoints;
@property (readonly) int level;
@property (nonatomic) int fire;
@property (nonatomic) int cold;
@property (nonatomic) int lightning;
@property (nonatomic) int poison;
@property (nonatomic) int dark;
@property (nonatomic) int armor;
@property (nonatomic) int aggroRange;
@property (nonatomic, retain) NSString *iconName;

@end
