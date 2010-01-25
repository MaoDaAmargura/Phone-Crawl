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

#define NUM_SPELLS 100
#define ITEM_HEAL_SPELL_ID 100 //Temporary assignment
#define ITEM_MANA_SPELL_ID 101 //Temporary assignment
#define ITEM_BOOK_SPELL_ID 102 //Temporary assignment

typedef enum {DAMAGE, CONDITION} spellType;
typedef enum {SELF,SINGLE} targetType;

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
}

- (NSString *) detr_spell: (Creature *) caster target: (Creature *) target;
- (NSString *) cond_spell: (Creature *) caster target: (Creature *) target;

+(void) BuildSpellSet; //construct spell_list array

@end
