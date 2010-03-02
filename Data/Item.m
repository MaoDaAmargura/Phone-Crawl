#import "Spell.h"
#import "Item.h"

#define NUM_NAMES_PER_ITEM 2
static const NSString *itemNameString[8][NUM_NAMES_PER_ITEM] = {
	{@"Sword",@"Scimitar"},
	{@"Greatsword",@"Glaive",},
	{@"Bow",@"Crossbow"},
	{@"Dagger",@"Dirk"},
	{@"Staff", @"Stave"},
    {@"Tower Shield", @"Kite Shield"},
	{@"Plate",@"Chainmail"},
	{@"Cloth", @"Leather"},
};

static const NSString *elemString1[] = {@"Fiery",@"Icy",@"Shocking",@"Venomous",@"Dark"};
static const NSString *elemString2[] = {@"Fire",@"Ice",@"Lightning",@"Poison",@"Darkness"};
static const NSString *spellName[] = {@"Minor",@"Lesser",@"",@"Major",@"Superior"};
static const NSString *healPotionIcon[] = {
    @"potion-red-I.png",
    @"potion-red-II.png",
    @"potion-red-III.png",
    @"potion-red-IV.png",
    @"potion-red-V.png"
};
static const NSString *manaPotionIcon[] = {
    @"potion-blue-I.png",
    @"potion-blue-II.png",
    @"potion-blue-III.png",
    @"potion-blue-IV.png",
    @"potion-blue-V.png"
};

static const int baseItemStats[10][9] = {
  //{hp,shield,mana,resist,armor,damage,elemental damage,elemental stat adjustment}
    {8 , 5 , 0 , 5 , 0 , 40, 15, 7 , -2 }, //One handed Sword
    {10, 12, 0 , 5 , 5 , 50, 20, 15, -7 }, //Two handed Sword
    {5 , 10, 0 , 5 , -5, 35, 5 , 12, -2 }, //Bow
    {5 , 0 , 10, 3 , 0 , 25, 10, 3 , 0  }, //Dagger
    {8 , 10, 25, 7 , 5 , 15, 20, 15, -8 }, //Staff
    {6 , 6 , 0 , 5 , 6 , 0 , 0 , 2 , 3  }, //Shield
    {5 , 10, 0 , 5 , 7 , 0 , 0 , 10, -5 }, //Heavy Helm
    {20, 20, 10, 10, 12, 0 , 0 , 15, -5 }, //Heavy Chest
    {2 , 2 , 10, 2 , 1 , 0 , 0 , 10, -8 }, //Light Helm
    {10, 10, 30, 12, 2 , 0 , 0 , 15, -3 }, //Light Chest
};

@implementation Item

@synthesize isEquipable;
@synthesize effectSpellId;
@synthesize icon;
@synthesize name;
@synthesize slot;
@synthesize element;
@synthesize type;

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
@synthesize elementalDamage;
@synthesize range;
@synthesize charges;

+ (NSString*) iconNameForItemType:(itemType)desiredType slot:(slotType) slot 
{
    switch (desiredType) 
    {
        case SWORD_ONE_HAND: return @"swordsingle.png";
        case SWORD_TWO_HAND: return @"claymore.png";
        case BOW:            return @"bow.png";
        case DAGGER:         return @"dagger.png";
        case STAFF:          return @"staff.png";
        case SHIELD:         return @"shield.png";
        case HEAVY_HELM:     return @"helmet1.png";
        case HEAVY_CHEST:    return @"armor-heavy.png";
        case LIGHT_HELM:     return @"helm2.png";
        case LIGHT_CHEST:    return @"armor-light.png";

    }
    NSLog(@"Invalid Item Type %d", desiredType);
    return nil;
}

+ (NSString *) itemNameForItemType:(itemType)desiredType element:(elemType) elem{
    switch (desiredType) 
    {
        case SWORD_ONE_HAND:
        case SWORD_TWO_HAND: 
        case BOW:            
        case DAGGER:         
        case STAFF:
        case SHIELD:
            if (arc4random() % 2)
                return [NSString stringWithFormat:@"%@ %@",elemString1[elem],
                        itemNameString[desiredType][[Rand min:0 max:NUM_NAMES_PER_ITEM-1]]];
            else
                return [NSString stringWithFormat:@"%@ of %@",
                        itemNameString[desiredType][[Rand min:0 max:NUM_NAMES_PER_ITEM-1]],
                        elemString2[elem]];
        case HEAVY_HELM:
        case LIGHT_HELM:
            if (arc4random() % 2)
                return [NSString stringWithFormat:@"%@ %@ Helm",
                        elemString1[elem],
                        itemNameString[desiredType][[Rand min:0 max:NUM_NAMES_PER_ITEM-1]]];
            else
                return [NSString stringWithFormat:@"%@ Helm of %@",
                        itemNameString[desiredType][[Rand min:0 max:NUM_NAMES_PER_ITEM-1]],
                        elemString2[elem]];
        case HEAVY_CHEST:
        case LIGHT_CHEST:
            if (arc4random() % 2)
                return [NSString stringWithFormat:@"%@ %@ Breastplate",
                        elemString1[elem],
                        itemNameString[desiredType][[Rand min:0 max:NUM_NAMES_PER_ITEM-1]]];
            else
                return [NSString stringWithFormat:@"%@ Breastplate of %@",
                        itemNameString[desiredType][[Rand min:0 max:NUM_NAMES_PER_ITEM-1]],
                        elemString2[elem]];
            
    }
    DLog(@"Invalid Item Type %d", desiredType);
    return nil;
}

- (id) initWithBaseStats: (int) dungeonLevel elemType: (elemType) dungeonElement
               itemType: (itemType) desiredType 
               itemSlot: (slotType) desiredSlot
{
    if (self = [super init]) {
        if(dungeonLevel > MAX_DUNGEON_LEVEL) dungeonLevel = MAX_DUNGEON_LEVEL;
        if(dungeonLevel < MIN_DUNGEON_LEVEL) dungeonLevel = MIN_DUNGEON_LEVEL;
        ++dungeonLevel; //Dungeon levels = [0,4], desired values = [1,5]
        if (desiredType == SWORD_ONE_HAND || desiredType == DAGGER || desiredType == SWORD_TWO_HAND)
            quality = [Rand min: DULL max: SHARP];
        else quality = REGULAR;
        
        icon = [Item iconNameForItemType:desiredType slot:desiredSlot];
        
        if(desiredType < POTION) isEquipable = TRUE;
        else isEquipable = FALSE;
        
        name = [Item itemNameForItemType:desiredType element:dungeonElement];
            
        hp = dungeonLevel * baseItemStats[desiredType][0];
        shield = dungeonLevel * baseItemStats[desiredType][1];
        mana = dungeonLevel * baseItemStats[desiredType][2];
        fire = cold = lightning = poison = dark = dungeonLevel * baseItemStats[desiredType][8];
        switch (dungeonElement) {
            case FIRE:
                fire = dungeonLevel * baseItemStats[desiredType][3];
                break;
            case COLD:
                cold = dungeonLevel * baseItemStats[desiredType][3];
                break;
            case LIGHTNING:
                lightning = dungeonLevel * baseItemStats[desiredType][3];
                break;
            case POISON:
                poison = dungeonLevel * baseItemStats[desiredType][3];
                break;
            case DARK:
                dark = dungeonLevel * baseItemStats[desiredType][3];
                break;
        }
        armor = dungeonLevel * baseItemStats[desiredType][4];
        damage = dungeonLevel * baseItemStats[desiredType][5];
        elementalDamage =dungeonLevel * baseItemStats[desiredType][6];
        range = (desiredType == BOW) ? (MIN_BOW_RANGE + dungeonLevel) : 
                                        (desiredType == STAFF)? STAFF_RANGE:1;
        charges = 0;
        slot = desiredSlot;
        element = dungeonElement;
        type = desiredType;
        effectSpellId = ITEM_NO_SPELL;
        pointValue = [Item getItemValue:self];
        return self;
    }
    return nil;
}

-(id)initExactItemWithName: (NSString *) itemName
             iconFileName: (NSString *) iconFileName
          itemQuality: (itemQuality) itemQual
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
              effectSpellId: (int) itemSpellId
{
	if (self = [super init]) {
        name = [itemName retain];
        icon = [iconFileName retain];
        if(desiredType < POTION) isEquipable = TRUE;
        else isEquipable = FALSE;
        quality = itemQual;
        damage = itemDamage;
        elemDamage = elemDamage;
        range = itemRange;
        slot = desiredSlot;
        type = desiredType;
        element = itemElement;
        charges = numberOfCharges;
        range = itemRange;
        hp = itemHP;
        shield = itemShield; 
        mana = itemMana; 
        fire = itemFire; 
        cold = itemCold; 
        lightning = itemLightning; 
        poison = itemPoison; 
        dark = itemDark; 
        armor = itemArmor;
        effectSpellId = itemSpellId;
        
        pointValue = [Item getItemValue:self];
		return self;
	}
	return nil;
};

- (NSString *) cast: (Creature *) caster target: (Creature *) target {
    if(effectSpellId == ITEM_NO_SPELL) {
        DLog(@"Tried to cast item: %@ which has no effect",self.name);
        return @"Item spell cast err!";
    }
    --charges;
    return [Spell castSpellById:effectSpellId caster:caster target:target];
    //return --charges;
}

// Generate a random item based on the dungeon level and elemental type

+(Item *) generateRandomItem: (int) dungeonLevel
					 elemType: (elemType) elementalType {
    if(dungeonLevel > MAX_DUNGEON_LEVEL) dungeonLevel = MAX_DUNGEON_LEVEL;
    if(dungeonLevel < MIN_DUNGEON_LEVEL) dungeonLevel = MIN_DUNGEON_LEVEL;
    itemType item_type = [Rand min:SWORD_ONE_HAND max:NUM_ITEM_TYPES + SWORD_ONE_HAND - 1];
    slotType itemSlot;
    switch(item_type) {
        case SWORD_ONE_HAND:
        case DAGGER:
            itemSlot = EITHER;
            break;
        case SWORD_TWO_HAND:
        case BOW:
        case STAFF:
            itemSlot = BOTH;
            break;
        case HEAVY_HELM:
        case LIGHT_HELM:
            itemSlot = HEAD;
            break;
        case HEAVY_CHEST:
        case LIGHT_CHEST:
            itemSlot = CHEST;
            break;
        case SHIELD:
            itemSlot = LEFT;
            break;
        // Define and return exact items (potions, wands, scrolls)
        case POTION:
            if (arc4random()%2)
                return [[[Item alloc] initExactItemWithName : [NSString stringWithFormat:@"%@ Potion of Healing",spellName[dungeonLevel]]
                                          iconFileName: [NSString stringWithFormat:@"%@",healPotionIcon[dungeonLevel]]
                                       itemQuality: REGULAR itemSlot: BAG 
                                          elemType: DARK    itemType: POTION
                                             damage: dungeonLevel elementalDamage:0
                                            charges:1 range:1 hp:0  shield:0 
                                               mana:0 fire:0 cold:0 lightning:0
                                             poison:0 dark:0 armor: 0
                                           effectSpellId: ITEM_HEAL_SPELL_ID + dungeonLevel] autorelease];
            else
                return [[[Item alloc] initExactItemWithName : [NSString stringWithFormat:@"%@ Potion of Mana",spellName[dungeonLevel]]
                                          iconFileName: [NSString stringWithFormat:@"%@",manaPotionIcon[dungeonLevel]]
                                       itemQuality: REGULAR itemSlot: BAG 
                                          elemType: DARK    itemType: POTION
                                             damage: dungeonLevel elementalDamage:0
                                            charges:1 range:1 hp:0  shield:0 
                                               mana:0 fire:0 cold:0 lightning:0
                                             poison:0 dark:0 armor: 0
                                           effectSpellId: ITEM_MANA_SPELL_ID + dungeonLevel] autorelease];
        case WAND:
            return [[[Item alloc] initExactItemWithName : [NSString stringWithFormat:@"%@ Wand of %@ Magic",spellName[dungeonLevel],elemString1[elementalType]]
                                      iconFileName: @"wand2.png"
                                   itemQuality: REGULAR itemSlot: BAG 
                                      elemType: DARK    itemType: WAND
                                         damage: dungeonLevel elementalDamage:0
                                        charges:[Rand min:1 max: ((dungeonLevel+1) * 2)]
                                          range:1 hp:0  shield:0 mana:0 fire:0
                                           cold:0 lightning:0 poison:0 dark:0 
                                          armor:0
                                       effectSpellId: START_WAND_SPELLS + elementalType * 5 + dungeonLevel] autorelease];
                            //Get to start of wand spells, then get to the
                            //correct element, then get to the spell level.
        case SCROLL:
            return [[[Item alloc] initExactItemWithName: @"Tome of Knowledge"
                                     iconFileName: @"scroll-book.png"
                                  itemQuality: REGULAR itemSlot: BAG 
                                     elemType: DARK    itemType: SCROLL
                                        damage:0 elementalDamage:0
                                       charges:1 range:1 hp:0  shield:0 
                                          mana:0 fire:0 cold:0 lightning:0
                                        poison:0 dark:0 armor: 0
                                      effectSpellId: ITEM_BOOK_SPELL_ID] autorelease];
        default:
            DLog("Error in random item generation");
            return nil;
    };
    return [[[Item alloc] initWithBaseStats:dungeonLevel
                                 elemType:elementalType
                                 itemType:item_type
                                 itemSlot:itemSlot] autorelease];
};

+(int) getItemValue : (Item *) item {
    if (item == nil) {
        return -1;
    }
    int pointVal = 0;
    switch(item.type) {
        case BOW:
            pointVal += item.range * 20;
        case SWORD_ONE_HAND:
        case SWORD_TWO_HAND:
        case DAGGER:
        case STAFF:
            pointVal += item.damage;
            pointVal += item.elementalDamage;
            break;
        case HEAVY_HELM:
        case HEAVY_CHEST:
        case LIGHT_HELM:
        case LIGHT_CHEST:
        case SHIELD:
            if (item.slot == CHEST) {
                pointVal += (item.hp + item.shield + item.mana) * 2;
            } else pointVal += (item.hp + item.shield + item.mana);
            break;
            
        //Item.damage overloaded to contain dungeon_level for potions
        case POTION: // Potion
            switch (item.damage) {
                case 0: return 10;
                case 1: return 50;
                case 2: return 100;
                case 3: return 500;
                case 4: return 1000;
            }
            
        //Item.damage overloaded to contain dungeon_level for wands
        case WAND: // Wand
            switch (item.damage) {
                case 0: return 10 * item.charges;
                case 1: return 50 * item.charges;
                case 2: return 100 * item.charges;
                case 3: return 500 * item.charges;
                case 4: return 1000 * item.charges;
            }
        case SCROLL:  // Scroll
			return 2000;
            break;
    };

    pointVal += (item.hp + item.shield + item.mana) * 2;
    pointVal += (item.fire + item.cold + item.lightning + item.poison + item.dark) * 1.5;
    pointVal += item.armor;
    return pointVal;
};


@end
