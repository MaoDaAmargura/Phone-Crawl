//
//  Spell.h
//  Phone-Crawl
//
//  Created by Benjamin Sangster on 1/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Creature.h"
#import "Item.h"
#import "Util.h"

#define ITEM_HEAL_SPELL_ID 100 //Temporary assignment
#define ITEM_MANA_SPELL_ID 101 //Temporary assignment
#define ITEM_BOOK_SPELL_ID 102 //Temporary assignment
#define ITEM_NO_SPELL -1

typedef enum {DAMAGE, CONDITION, ITEM} spellType;
typedef enum {SELF,SINGLE} targetType;

NSMutableArray *spell_list;

@class Creature;
@interface Spell : NSObject {
	NSString *name;
	spellType spell_type; //Hurt or Help
	targetType target_type; //Self, one target, all in range
	elemType elem_type; //Elemental type of damage or buff
	int mana_cost;
	int damage;
	int range;
	int spell_level; //Minor,Lesser, (unnamed regular), Major, Superior
	int spell_id; //Index in spell_list array of the spell
	IMP spell_fn;
}

- (id) initWithInfo: (NSString *) in_name spell_type: (spellType) in_spell_type target_type: (targetType) in_target_type elem_type: (elemType) in_elem_type
		  mana_cost: (int) in_mana_cost damage: (int) in_damage range: (int) in_range spell_level: (int) in_spell_level spell_id: (int) in_spell_id
		   spell_fn: (IMP) in_spell_fn;

- (BOOL) Resist_Check: (Creature *) caster target: (Creature *) target;
- (NSString *) detr_spell: (Creature *) caster target: (Creature *) target;
- (NSString *) cond_spell: (Creature *) caster target: (Creature *) target;

//Specialized item functions

- (NSString *) heal_potion: (Creature *) caster target: (Creature *) target;
- (NSString *) mana_potion: (Creature *) caster target: (Creature *) target;
- (NSString *) wand: (Creature *) caster target: (Creature *) target;
- (NSString *) scroll: (Creature *) caster target: (Creature *) target;

+(void) BuildSpellSet; //construct spell_list array

@end
