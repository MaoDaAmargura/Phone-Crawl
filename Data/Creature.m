#import "Creature.h"
#import "CombatAbility.h"
#import "Spell.h"
#import "Item.h"
#import "Dungeon.h"

@implementation Critter

@synthesize abilities;
@synthesize creatureLocation;
@synthesize inventory;
@synthesize selectedCreatureForAction;
@synthesize selectedCombatAbilityToUse;
@synthesize selectedSpellToUse;
@synthesize selectedItemToUse;
@synthesize selectedMoveTarget;
@synthesize turnPoints;
@synthesize inBattle;
@synthesize name;
@synthesize abilityPoints;
@synthesize level;
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
@synthesize aggroRange;
@synthesize iconName;
@synthesize cachedPath;
@synthesize experiencePoints;
@synthesize deathPenalty;

#pragma mark -

- (NSString*) description {
	return [NSString stringWithFormat:
			@"%@ at %@:\nmax: %@\nnow:%@", name, creatureLocation, max, current];
}


#pragma mark -
#pragma mark Life Cycle

- (id) initMonsterOfType: (creatureType) monsterType withElement:(elemType)elem level: (int) inLevel atX:(int)x Y:(int)y Z:(int)z {
	if (self = [super init])
	{
		self.creatureLocation = [Coord withX:x Y:y Z:z];
		type = monsterType;
		level = inLevel;
		int dungeonLevel = level %4;
		[self setBaseStats];
		self.equipment = [[[EquipSlots alloc] init] autorelease];
		money = [Rand min:dungeonLevel * 25 max:dungeonLevel * 50];
		abilityPoints = 10;
		turnPoints = 0;
		inBattle = NO;
		condition = NO_CONDITION;

		/*
		 All monsters will have a default inventory of items specific to their element.
		 AI for each creature can choose to equip whichever of the items they wish. 
		 
		 Exceptions for this will have to be: shopkeeper and bosses. Can get them done later.
		 */

		self.inventory = [NSMutableArray arrayWithObjects:
						  [[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:SWORD_ONE_HAND] autorelease],
						  [[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:SWORD_TWO_HAND] autorelease],
						  [[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:BOW] autorelease],
						  [[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:DAGGER] autorelease],
						  [[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:STAFF] autorelease],
						  [[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:SHIELD] autorelease],
						  [[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:HEAVY_HELM] autorelease],
						  [[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:HEAVY_CHEST] autorelease],
						  [[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:LIGHT_HELM] autorelease],
						  [[[Item alloc] initWithBaseStats:dungeonLevel elemType:elem itemType:LIGHT_CHEST] autorelease],
						  
						  nil];
		self.abilities = [[[Abilities alloc] init] autorelease];
		int sb[NUM_PC_SPELL_TYPES] = {0,0,0,0,0,0,0,0,0,0};
		int c[NUM_COMBAT_ABILITY_TYPES] = {0,0,0,0,0,0};
		switch (monsterType) {
			case BERSERKER:
				iconName = @"monster-ogre.png";
				name = @"Berserker";
				for (int i = 0; i < NUM_PC_SPELL_TYPES; ++i)
					sb[i] = 0;
				for (int i = 0; i < NUM_COMBAT_ABILITY_TYPES; ++i)
					c[i] = 1;
				[self.abilities setSpellBookArray:sb];
				[self.abilities setCombatAbilityArray:c];	
				[self addEquipment:[self.inventory objectAtIndex:SWORD_TWO_HAND] slot:RIGHT];
				break;
			case WARRIOR:
				iconName = @"monster-warrior.png";
				name = @"Warrior";
				for (int i = 0; i < NUM_PC_SPELL_TYPES; ++i)
					sb[i] = 0;
				for (int i = 0; i < NUM_COMBAT_ABILITY_TYPES; ++i)
					c[i] = 1;	
				[self addEquipment:[self.inventory objectAtIndex:SWORD_ONE_HAND] slot:RIGHT];
				[self addEquipment:[self.inventory objectAtIndex:SHIELD] slot:LEFT];
				[self addEquipment:[self.inventory objectAtIndex:HEAVY_HELM] slot:HEAD];
				[self addEquipment:[self.inventory objectAtIndex:HEAVY_CHEST] slot: CHEST];
				break;
			case PALADIN:
				iconName = @"monster-paladin.bmp";
				name = @"Paladin";
				for (int i = FIRECONDITION; i < NUM_PC_SPELL_TYPES; ++i)
					sb[i] = dungeonLevel;
				for (int i = 0; i < NUM_COMBAT_ABILITY_TYPES; ++i)
					c[i] = 1;
				[self addEquipment:[self.inventory objectAtIndex:SWORD_ONE_HAND] slot:RIGHT];
				[self addEquipment:[self.inventory objectAtIndex:LIGHT_HELM] slot:HEAD];
				[self addEquipment:[self.inventory objectAtIndex:HEAVY_CHEST] slot:CHEST];
				break;
			case SHADOWKNIGHT:
				iconName = @"monster-shadowknight.bmp";
				name = @"Shadowknight";
				for (int i = 0; i < FIRECONDITION; ++i)
					sb[i] = dungeonLevel;
				for (int i = 0; i < NUM_COMBAT_ABILITY_TYPES; ++i)
					c[i] = 1;
				[self addEquipment:[self.inventory objectAtIndex:SWORD_ONE_HAND] slot:RIGHT];
				[self addEquipment:[self.inventory objectAtIndex:LIGHT_HELM] slot:HEAD];
				[self addEquipment:[self.inventory objectAtIndex:HEAVY_CHEST] slot:CHEST];
				break;
			case ROGUE:
				iconName = @"monster-rogue.bmp";
				name = @"Rogue";
				sb[POISONDAMAGE] = dungeonLevel+1;
				sb[COLDCONDITION] = dungeonLevel+1;
				sb[POISONCONDITION] = dungeonLevel+1;
				for (int i = 0; i < NUM_COMBAT_ABILITY_TYPES; ++i)
					c[i] = 1;
				[self addEquipment:[self.inventory objectAtIndex:DAGGER] slot:RIGHT];
				[self addEquipment:[self.inventory objectAtIndex:DAGGER] slot:LEFT];
				[self addEquipment:[self.inventory objectAtIndex:LIGHT_HELM] slot:HEAD];
				[self addEquipment:[self.inventory objectAtIndex:LIGHT_CHEST] slot:CHEST];
				break;
			case MAGE:
				iconName = @"monster-wizard.bmp";
				name = @"Mage";
				for (int i = 0; i < NUM_PC_SPELL_TYPES; ++i)
					sb[i] = dungeonLevel+1;
				for (int i = 0; i < NUM_COMBAT_ABILITY_TYPES; ++i)
					c[i] = 1;
				[self addEquipment:[self.inventory objectAtIndex:STAFF] slot:RIGHT];
				[self addEquipment:[self.inventory objectAtIndex:LIGHT_HELM] slot:HEAD];
				[self addEquipment:[self.inventory objectAtIndex:LIGHT_CHEST] slot:CHEST];
				break;
			default:
				iconName = @"monster-dragon-green.png";
				name = @"Default";
				for (int i = 0; i < NUM_PC_SPELL_TYPES; ++i)
					sb[i] = 5;
				for (int i = 0; i < NUM_COMBAT_ABILITY_TYPES; ++i)
					c[i] = 1;
				[self addEquipment:[self.inventory objectAtIndex:SWORD_ONE_HAND] slot:RIGHT];
		}
		[self.abilities setSpellBookArray:sb];
		[self.abilities setCombatAbilityArray:c];
		max.health = max.shield = max.mana = level * 25;
		current.health = current.shield = current.mana = max.health;

		[self ClearTurnActions];
		return self;
	}
	return nil;
}
		
- (id) initPlayerWithLevel: (int) lvl {
	return [self initPlayerWithInfo:@"Bob" level: lvl];
}

- (id) initPlayerWithInfo: (NSString *) inName level: (int) lvl
{
	if(self = [super init])
	{
		self.name = [NSString stringWithString:inName];
		self.iconName = @"human.png";
		self.creatureLocation = [Coord withX:0 Y:0 Z:0];
		int sb[] = {1,1,1,1,1,1,1,1,1,1};
		int c[] = {1,1,1,1,1};
		self.abilities = [[[Abilities alloc] init] autorelease];
		[self.abilities setSpellBookArray: sb];
		[self.abilities setCombatAbilityArray: c];		
		self.selectedCreatureForAction = nil;
		self.selectedCombatAbilityToUse = nil;
		self.selectedSpellToUse = nil;
		self.selectedItemToUse = nil;
		self.selectedMoveTarget = nil;
		experiencePoints = 0;
		level = lvl;
		type = PLAYER;
		deathPenalty = 0;
		
		[self setBaseStats];
		self.equipment = [[[EquipSlots alloc] init] autorelease];
		self.inventory = [[[NSMutableArray alloc] init] autorelease];
		money = 0;
		abilityPoints = 10;
		turnPoints = 0;
		inBattle = NO;
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
	return [self initPlayerWithLevel:0];
}

- (void) gainExperience:(float)amount {
	experiencePoints += amount;
	while (experiencePoints >= 10) {
		experiencePoints -= 10;
		++level;
		abilityPoints+=2;
		max.health = max.shield = max.mana = 100 + level * 25;
		[self updateStatsItem:equipment.head];
		[self updateStatsItem:equipment.chest];
		[self updateStatsItem:equipment.lHand];
		[self updateStatsItem:equipment.rHand];
	}
}

- (void) resetStats {
	[self clearCondition];
	max.health = real.health;
	max.shield = real.shield;
	max.mana = real.mana;
	current.turnSpeed = max.turnSpeed = real.turnSpeed;
	if (current.health > max.health) current.health = max.health;
	if (current.mana > max.mana) current.mana = max.mana;
	if (current.shield > max.shield) current.shield = max.shield;
	
}

#pragma mark -
#pragma mark Helpers

- (void) setBaseStats {
	current = [[Points alloc] init];
	max = [[Points alloc] init];
	real = [[Points alloc] init];
	current.turnSpeed = 1.05;
	real.turnSpeed = 1.05;
	max.turnSpeed = 1.05;
	max.health = max.shield = max.mana = 100 + level * 25;
	current.health = current.shield = current.mana = max.health;
	fire = cold = lightning = poison = dark = 20;
	armor = 0;
	aggroRange = 2;
	[self updateStatsItem:equipment.head];
	[self updateStatsItem:equipment.chest];
	[self updateStatsItem:equipment.lHand];
	[self updateStatsItem:equipment.rHand];
}

- (void) updateStatsItem: (Item*) item {
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

- (void) takeDamage: (int) amount {
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

- (void) heal: (int) amount {
	current.health += amount;
	if (current.health > max.health) {
		current.shield += (current.health - max.health);
		current.health = max.health;
		if (current.shield > max.shield)
			current.shield = max.shield;
	}
}

- (void) healMana:(int)amount {
	current.mana += amount;
	if (current.mana > max.mana) {
		current.mana = max.mana;
	}
}

- (void) addCondition: (conditionType) newCondition { condition |= newCondition; }
- (void) removeCondition: (conditionType) removeCondition { condition = condition &~ removeCondition; }
- (void) clearCondition { condition = NO_CONDITION; }

- (slotType) destinationForEitherHandItem
{
	//some simple logic for now. can be modified later to launch menu
	if(equipment.rHand == nil)
	{
		return RIGHT;
	}
	else if(equipment.lHand == nil && equipment.rHand.slot != BOTH)
	{
		return LEFT;
	}
	else 
	{
		return RIGHT;
	}
}

- (void) addEquipment: (Item *) item slot: (slotType) destSlot 
{
	slotType destination = destSlot;
	slotType itemSlot = item.slot;
	
	if(itemSlot == BAG)
	{
		return;
	}
	else if(itemSlot == BOTH)
	{
		destination = RIGHT;
		if(equipment.lHand != nil)
			[self removeEquipment:LEFT];
	}
	else if(itemSlot ==  EITHER)
	{
		destination = [self destinationForEitherHandItem];
	}
	
	[self updateStatsItem:item];
	switch (destination) {
		case HEAD:
			equipment.head = item;
			break;
		case CHEST:
			equipment.chest = item;
			break;
		case LEFT:
			equipment.lHand = item;
			break;
		case RIGHT:
			equipment.rHand = item;
			break;				
	};
	
	//Item removed from cursor
	return;
}

- (void) removeEquipment: (slotType) destSlot {
	Item *rem_item;
	switch (destSlot) {
		case HEAD:
			rem_item = equipment.head;
			equipment.head = nil;
			break;
		case CHEST:
			rem_item = equipment.chest;
			equipment.chest = nil;
			break;
		case LEFT:
			rem_item = equipment.lHand;
			equipment.lHand = nil;
			break;
		case RIGHT:
			rem_item = equipment.rHand;
			equipment.rHand = nil;
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
	
- (void) addInventory: (Item *) item inSlotNumber: (int) slotNumber {
	if (slotNumber == FIRST_AVAIL_INV_SLOT) {
		for (slotNumber = 0; slotNumber < NUM_INV_SLOTS; ++slotNumber) {
			if ([inventory objectAtIndex:slotNumber] == nil)
				break;
		}
		if (slotNumber >= NUM_INV_SLOTS) {
			//No free inventory slots
			return;
		}
	} else if (slotNumber >= NUM_INV_SLOTS || slotNumber < FIRST_AVAIL_INV_SLOT) {
		//Invalid inventory slot
		return;
	}
	[inventory insertObject:item atIndex:slotNumber];
	//Remove item from cursor
};
	
- (void) removeItemFromInventoryInSlot: (int) slotNumber {
	if(slotNumber >= NUM_INV_SLOTS || slotNumber < 0) {
		//No free inventory slots
		return;
	}
//	Item *rem_item = [inventory objectAtIndex:inv_slot];
	[inventory insertObject:nil atIndex:slotNumber];
	//return rem_item;
};

- (int) regularWeaponDamage {
	int dmg = 0;
	if (equipment.rHand != NULL) dmg+=equipment.rHand.damage;
	if (equipment.lHand != NULL && (equipment.lHand.type == SWORD_ONE_HAND || equipment.lHand.type == DAGGER)) dmg+=equipment.lHand.damage * OFFHAND_DMG_PERCENTAGE;
	return dmg == 0 ? 1 : dmg;
}

- (int) elementalWeaponDamage {
	int dmg = 0;
	if (equipment.rHand != NULL) dmg+=equipment.rHand.elementalDamage;
	if (equipment.lHand != NULL && (equipment.lHand.type == SWORD_ONE_HAND || equipment.lHand.type == DAGGER)) dmg+=equipment.lHand.elementalDamage * OFFHAND_DMG_PERCENTAGE;
	return dmg;
}

- (void) ClearTurnActions
{
		self.selectedCombatAbilityToUse = nil;
		self.selectedSpellToUse = nil;
		self.selectedItemToUse = nil;
		self.selectedMoveTarget = nil;
}

- (BOOL) hasActionToTake
{
	if( selectedMoveTarget 
		 || ( selectedCreatureForAction
				&& ( selectedCombatAbilityToUse || selectedSpellToUse || selectedItemToUse))) 
	{
		return YES;
	}
	return NO;
}

- (int) getRange {
	return equipment.rHand.range;
}

- (int) getHighScore
{
	int score = 0;
	score += money;
	for (Item *it in self.inventory)
		score += (it.pointValue * 0.60);
	score += (experiencePoints / 10);
	score -= deathPenalty;
	return score;
}

@end

@implementation EquipSlots
@synthesize head;
@synthesize chest;
@synthesize lHand;
@synthesize rHand;
- (id) init
{
	if(self = [super init])
	{
		head = nil;
		chest = nil;
		lHand = nil;
		rHand = nil;
		return self;
	}
	return nil;
}
@end

@implementation Points
@synthesize health;
@synthesize shield;
@synthesize mana;
@synthesize turnSpeed;
- (NSString*) description {
	return [NSString stringWithFormat: @"HP %d SH %d MP %d TS %d", health, shield, mana, turnSpeed];
}
@end

@implementation Abilities
@synthesize spells;
@synthesize skills;
- (id) init
{
	if(self = [super init])
	{
		spells = (int*)malloc(sizeof(int) * NUM_PC_SPELL_TYPES);
		skills = (int*)malloc(sizeof(int) * NUM_COMBAT_ABILITY_TYPES);
		return self;
	}
	return nil;
}
- (void) setSpellBookArray:(int []) sb {
	int i = 0;
	for (; i < NUM_PC_SPELL_TYPES; ++i)
		spells[i] = sb[i];
}
- (void) setCombatAbilityArray:(int [])c {
	int i = 0;
	for (; i < NUM_COMBAT_ABILITY_TYPES; ++i)
		skills[i] = c[i];
}

@end

