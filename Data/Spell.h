//	The Spell class contains data on the spells that the player (and enemies)
//	can use, as well as the functions required to use those spells

#import <Foundation/Foundation.h>

#import "Util.h"

#define NUM_PC_SPELLS 50
#define NUM_DMG_SPELLS 25
#define NUM_WAND_SPELLS NUM_DMG_SPELLS
#define NUM_COND_SPELLS 25

#define ITEM_BOOK_SPELL_ID 0 // 0
#define ITEM_HEAL_SPELL_ID ITEM_BOOK_SPELL_ID + 1 //0 + 1 = 1
#define ITEM_MANA_SPELL_ID ITEM_HEAL_SPELL_ID + 5 //1 + 5 = 6
#define START_PC_SPELLS ITEM_MANA_SPELL_ID + 5 //6 + 5 = 11
#define START_WAND_SPELLS START_PC_SPELLS + NUM_PC_SPELLS // 11 + 50 = 61

typedef enum {DAMAGE, CONDITION, ITEM} spellType;
typedef enum {SELF,SINGLE} targetType;

// conditions that may be inflicted when a target is hit
#define SPELL_HASTENED -1
#define SPELL_FROZEN -2
#define SPELL_PURGED -3
#define SPELL_TAINTED -4
#define SPELL_CONFUSED -5
#define SPELL_NO_MANA -6
#define SPELL_RESIST -7
#define SPELL_NO_DAMAGE -8
#define SPELL_CAST_ERR -9

#define NUM_PLAYER_SPELL_TYPES 10

// type of spell, used by critter class
typedef enum {
	FIREDAMAGE = 0,
	COLDDAMAGE = 1,
	LIGHTNINGDAMAGE = 2,
	POISONDAMAGE = 3,
	DARKDAMAGE = 4,
	FIRECONDITION = 5,
	COLDCONDITION = 6,
	LIGHTNINGCONDITION = 7,
	POISONCONDITION = 8,
	DARKCONDITION = 9,
} PC_SPELL_TYPE;

@class Critter;

// interface for Spell
@interface Spell : NSObject {
	// name of the spell
	NSString *name;
	// does the spell hurt enemies, or help caster
	spellType type;
	// type of target, single, range, ect
	targetType spellTarget;
	// elemental type of spell
	elemType element;
	// cost of spell
	int manaCost;
	// spell damage
	int damage;
	// spell range
	int range;
	// level of spell
	int level; //Minor,Lesser, Regular, Major, Superior
	int spellId; //Index in spell_list array of the spell
	// function called when spell is cast
	SEL spellFn;
	// turn point cost of spell
	int turnPointCost;
}

// casting functions
+ (NSString *) castSpellById: (int) desiredSpellId caster: (Critter *) caster target: (Critter *) target;
- (NSString *) cast: (Critter *) caster target: (Critter *) target;

// init functions
- (id) initSpellWithName: (NSString *) spellName spellType: (spellType) desiredSpellType targetType: (targetType) spellTargetType elemType: (elemType) elementalType
				manaCost: (int) mana damage: (int) dmg range: (int) spellRange spellLevel: (int) spellLevel spellId: (int) desiredSpellId
				 spellFn: (SEL) fn turnPointCost: (int) turnPntCost;
+ (void) initialize;
+ (Spell*) spellOfType:(PC_SPELL_TYPE)type level:(int)lvl;

// check if target is resistant to a spell
- (BOOL) resistCheck: (Critter *) caster target: (Critter *) target;

//Specialized spell functions
- (int) damageSpell: (Critter *) caster target: (Critter *) target;
- (int) healPotion: (Critter *) caster target: (Critter *) target;
- (int) manaPotion: (Critter *) caster target: (Critter *) target;
- (int) scroll: (Critter *) caster target: (Critter *) target;
- (int) haste: (Critter *) caster target: (Critter *) target;
- (int) freeze: (Critter *) caster target: (Critter *) target;
- (int) purge: (Critter *) caster target: (Critter *) target;
- (int) taint: (Critter *) caster target: (Critter *) target;
- (int) confusion: (Critter *) caster target: (Critter *) target;

// getter and setter methods
@property (readonly) int range;
@property (readonly, retain) NSString * name;
@property (readonly) targetType spellTarget;
@property (readonly) int spellId;
@property (readonly) int turnPointCost;

@end
