#import <Foundation/Foundation.h>
#import "Util.h"

#define ERR_NO_MANA -2
#define ERR_RESIST -3
#define SPELL_NO_DAMAGE -4
#define CAST_ERR -5

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

NSMutableArray *spellList;

@class Creature;
@interface Spell : NSObject {
	NSString *name;
	spellType type; //Hurt or Help
	targetType spellTarget; //Self, one target, all in range
	elemType element; //Elemental type of damage or buff
	int manaCost;
	int damage;
	int range;
	int level; //Minor,Lesser, (unnamed regular), Major, Superior
	int spellId; //Index in spell_list array of the spell
	SEL spellFn;
	int turnPointCost;
	//IMP spell_fn;
}

+ (void) fillSpellList;

+ (int) castSpellById: (int) desiredSpellId caster: (Creature *) caster target: (Creature *) target;
- (int) cast: (Creature *) caster target: (Creature *) target;

- (id) initSpellWithName: (NSString *) spellName spellType: (spellType) desiredSpellType targetType: (targetType) spellTargetType elemType: (elemType) elementalType
				manaCost: (int) mana damage: (int) dmg range: (int) spellRange spellLevel: (int) spellLevel spellId: (int) desiredSpellId
				 spellFn: (SEL) fn turnPointCost: (int) turnPntCost;

- (BOOL) resistCheck: (Creature *) caster target: (Creature *) target;

//Specialized spell functions

- (int) damageSpell: (Creature *) caster target: (Creature *) target;
- (int) healPotion: (Creature *) caster target: (Creature *) target;
- (int) manaPotion: (Creature *) caster target: (Creature *) target;
- (int) scroll: (Creature *) caster target: (Creature *) target;
- (int) haste: (Creature *) caster target: (Creature *) target;
- (int) freeze: (Creature *) caster target: (Creature *) target;
- (int) purge: (Creature *) caster target: (Creature *) target;
- (int) taint: (Creature *) caster target: (Creature *) target;
- (int) confusion: (Creature *) caster target: (Creature *) target;


@property (readonly) int range;
@property (readonly) NSString * name;
@property (readonly) targetType spellTarget;
@property (readonly) int spellId;
@property (readonly) int turnPointCost;

@end
