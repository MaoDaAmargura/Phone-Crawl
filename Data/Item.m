#import "Spell.h"
#import "Item.h"

#define NUM_NAMES_PER_ITEM 2
static const NSString *name_string[8][NUM_NAMES_PER_ITEM] = {
	{@"Sword",@"Scimitar"},
	{@"Greatsword",@"Glaive",},
	{@"Bow",@"Crossbow"},
	{@"Dagger",@"Dirk"},
	{@"Staff", @"Stave"},
    {@"Tower Shield", @"Kite Shield"},
	{@"Plate",@"Chainmail"},
	{@"Cloth", @"Leather"},
};

static const NSString *elem_string1[] = {@"Fiery",@"Icy",@"Shocking",@"Venomous",@"Dark"};
static const NSString *elem_string2[] = {@"Fire",@"Ice",@"Lightning",@"Poison",@"Darkness"};
static const NSString *spell_name[] = {@"Minor",@"Lesser",@"",@"Major",@"Superior"};
static const NSString *heal_pot_icon[] = {
    @"potion-red-I.png",
    @"potion-red-II.png",
    @"potion-red-III.png",
    @"potion-red-IV.png",
    @"potion-red-V.png"
};
static const NSString *mana_pot_icon[] = {
    @"potion-blue-I.png",
    @"potion-blue-II.png",
    @"potion-blue-III.png",
    @"potion-blue-IV.png",
    @"potion-blue-V.png"
};

static const int base_item_stats[10][9] = {
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

@synthesize is_equipable;
@synthesize spell_id;
@synthesize item_icon;
@synthesize item_name;
@synthesize item_slot;
@synthesize elem_type;
@synthesize item_type;

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
@synthesize elem_damage;
@synthesize range;
@synthesize charges;

+ (NSString*) iconNameForItemType:(itemType)type slot:(slotType) slot 
{
    switch (type) 
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
    NSLog(@"Invalid Item Type %d", type);
    return nil;
}

+ (NSString *) itemNameForItemType:(itemType)type element:(elemType) elem{
    switch (type) 
    {
        case SWORD_ONE_HAND:
        case SWORD_TWO_HAND: 
        case BOW:            
        case DAGGER:         
        case STAFF:
        case SHIELD:
            if (arc4random() % 2)
                return [NSString stringWithFormat:@"%@ %@",elem_string1[elem],
                        name_string[type][[Rand min:0 max:NUM_NAMES_PER_ITEM-1]]];
            else
                return [NSString stringWithFormat:@"%@ of %@",
                        name_string[type][[Rand min:0 max:NUM_NAMES_PER_ITEM-1]],
                        elem_string2[elem]];
        case HEAVY_HELM:
        case LIGHT_HELM:
            if (arc4random() % 2)
                return [NSString stringWithFormat:@"%@ %@ Helm",
                        elem_string1[elem],
                        name_string[type][[Rand min:0 max:NUM_NAMES_PER_ITEM-1]]];
            else
                return [NSString stringWithFormat:@"%@ Helm of %@",
                        name_string[type][[Rand min:0 max:NUM_NAMES_PER_ITEM-1]],
                        elem_string2[elem]];
        case HEAVY_CHEST:
        case LIGHT_CHEST:
            if (arc4random() % 2)
                return [NSString stringWithFormat:@"%@ %@ Breastplate",
                        elem_string1[elem],
                        name_string[type][[Rand min:0 max:NUM_NAMES_PER_ITEM-1]]];
            else
                return [NSString stringWithFormat:@"%@ Breastplate of %@",
                        name_string[type][[Rand min:0 max:NUM_NAMES_PER_ITEM-1]],
                        elem_string2[elem]];
            
    }
    DLog(@"Invalid Item Type %d", type);
    return nil;
}

- (id) initWithBaseStats: (int) dungeon_level elem_type: (elemType) dungeon_elem
               item_type: (itemType) in_item_type 
               item_slot: (slotType) in_slot_type
{
    if (self = [super init]) {
        if(dungeon_level > MAX_DUNGEON_LEVEL) dungeon_level = MAX_DUNGEON_LEVEL;
        if(dungeon_level < MIN_DUNGEON_LEVEL) dungeon_level = MIN_DUNGEON_LEVEL;
        ++dungeon_level; //Dungeon levels = [0,4], desired values = [1,5]
        if (in_item_type == SWORD_ONE_HAND || in_item_type == DAGGER ||
            in_item_type == SWORD_TWO_HAND)
            item_quality = [Rand min: DULL max: SHARP];
        else item_quality = REGULAR;
        
        item_icon = [Item iconNameForItemType:in_item_type slot:in_slot_type];
        
        if(in_item_type < POTION) is_equipable = TRUE;
        else is_equipable = FALSE;
        
        item_name = [Item itemNameForItemType:in_item_type element:dungeon_elem];
            
        hp = dungeon_level * base_item_stats[in_item_type][0];
        shield = dungeon_level * base_item_stats[in_item_type][1];
        mana = dungeon_level * base_item_stats[in_item_type][2];
        fire = cold = lightning = poison = dark = dungeon_level * base_item_stats[in_item_type][8];
        switch (dungeon_elem) {
            case FIRE:
                fire = dungeon_level * base_item_stats[in_item_type][3];
                break;
            case COLD:
                cold = dungeon_level * base_item_stats[in_item_type][3];
                break;
            case LIGHTNING:
                lightning = dungeon_level * base_item_stats[in_item_type][3];
                break;
            case POISON:
                poison = dungeon_level * base_item_stats[in_item_type][3];
                break;
            case DARK:
                dark = dungeon_level * base_item_stats[in_item_type][3];
                break;
        }
        armor = dungeon_level * base_item_stats[in_item_type][4];
        damage = dungeon_level * base_item_stats[in_item_type][5];
        elem_damage =dungeon_level * base_item_stats[in_item_type][6];
        range = (in_item_type == BOW) ? (MIN_BOW_RANGE + dungeon_level) : 
                                        (in_item_type == STAFF)? STAFF_RANGE:1;
        charges = 0;
        item_slot = in_slot_type;
        elem_type = dungeon_elem;
        item_type = in_item_type;
        spell_id = ITEM_NO_SPELL;
        point_val = [Item item_val:self];
        return self;
    }
    return nil;
}

-(id)initWithStats: (NSString *) in_name
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
              spell_id: (int) in_spell_id
{
	if (self = [super init]) {
        item_name = [in_name retain];
        item_icon = [in_icon_name retain];
        if(in_item_type < POTION) is_equipable = TRUE;
        else is_equipable = FALSE;
        item_quality = in_item_quality;
        damage = in_damage;
        elem_damage = in_elem_damage;
        range = in_range;
        item_slot = in_item_slot;
        item_type = in_item_type;
        elem_type = in_elem_type;
        charges = in_charges;
        range = in_range;
        hp = in_hp;
        shield = in_shield; 
        mana = in_mana; 
        fire = in_fire; 
        cold = in_cold; 
        lightning = in_lightning; 
        poison = in_poison; 
        dark = in_dark; 
        armor = in_armor;
        spell_id = in_spell_id;
        
        point_val = [Item item_val:self];
		return self;
	}
	return nil;
};

//Each item with a spell effect has that spell ID stored in it.
//When the time comes to cast that spell, the spell does its effect internally
//Decrements the number of charges, then returns to engine. Engine should
//use the returned value to determine if an item needs to be dropped from inventory.
- (int) cast: (Creature *) caster target: (Creature *) target {
    if(spell_id == ITEM_NO_SPELL) {
        DLog(@"Tried to cast item: %@ which has no effect",self.item_name);
        return ITEM_NO_SPELL;
    }
    [Spell cast_id:spell_id caster:caster target:target];
    return --charges;
}

// Generate a random item based on the dungeon level and elemental type

+(Item *) generate_random_item: (int) dungeon_level
					 elem_type: (elemType) elem_type {
    if(dungeon_level > MAX_DUNGEON_LEVEL) dungeon_level = MAX_DUNGEON_LEVEL;
    if(dungeon_level < MIN_DUNGEON_LEVEL) dungeon_level = MIN_DUNGEON_LEVEL;
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
                return [[[Item alloc] initWithStats : [NSString stringWithFormat:@"%@ Potion of Healing",spell_name[dungeon_level]]
                                          icon_name: [NSString stringWithFormat:@"%@",heal_pot_icon[dungeon_level]]
                                       item_quality: REGULAR item_slot: BAG 
                                          elem_type: DARK    item_type: POTION
                                             damage: dungeon_level elem_damage:0
                                            charges:1 range:1 hp:0  shield:0 
                                               mana:0 fire:0 cold:0 lightning:0
                                             poison:0 dark:0 armor: 0
                                           spell_id: ITEM_HEAL_SPELL_ID + dungeon_level] autorelease];
            else
                return [[[Item alloc] initWithStats : [NSString stringWithFormat:@"%@ Potion of Mana",spell_name[dungeon_level]]
                                          icon_name: [NSString stringWithFormat:@"%@",mana_pot_icon[dungeon_level]]
                                       item_quality: REGULAR item_slot: BAG 
                                          elem_type: DARK    item_type: POTION
                                             damage: dungeon_level elem_damage:0
                                            charges:1 range:1 hp:0  shield:0 
                                               mana:0 fire:0 cold:0 lightning:0
                                             poison:0 dark:0 armor: 0
                                           spell_id: ITEM_MANA_SPELL_ID + dungeon_level] autorelease];
        case WAND:
            return [[[Item alloc] initWithStats : [NSString stringWithFormat:@"%@ Wand of %@ Magic",spell_name[dungeon_level],elem_string1[elem_type]]
                                      icon_name: @"wand2.png"
                                   item_quality: REGULAR item_slot: BAG 
                                      elem_type: DARK    item_type: WAND
                                         damage: dungeon_level elem_damage:0
                                        charges:[Rand min:1 max: ((dungeon_level+1) * 2)]
                                          range:1 hp:0  shield:0 mana:0 fire:0
                                           cold:0 lightning:0 poison:0 dark:0 
                                          armor:0
                                       spell_id: START_WAND_SPELLS + elem_type * 5 + dungeon_level] autorelease];
                            //Get to start of wand spells, then get to the
                            //correct element, then get to the spell level.
        case SCROLL:
            return [[[Item alloc] initWithStats: @"Tome of Knowledge"
                                     icon_name: @"scroll-book.png"
                                  item_quality: REGULAR item_slot: BAG 
                                     elem_type: DARK    item_type: SCROLL
                                        damage:0 elem_damage:0
                                       charges:1 range:1 hp:0  shield:0 
                                          mana:0 fire:0 cold:0 lightning:0
                                        poison:0 dark:0 armor: 0
                                      spell_id: ITEM_BOOK_SPELL_ID] autorelease];
        default:
            DLog("Error in random item generation");
            return nil;
    };
    return [[[Item alloc] initWithBaseStats:dungeon_level
                                 elem_type:elem_type
                                 item_type:item_type
                                 item_slot:itemSlot] autorelease];
};

+(int) item_val : (Item *) item {
    if (item == nil) {
        return -1;
    }
    int point_val = 0;
    switch(item.item_type) {
        case BOW:
            point_val += item.range * 20;
        case SWORD_ONE_HAND:
        case SWORD_TWO_HAND:
        case DAGGER:
        case STAFF:
            point_val += item.damage;
            point_val += item.elem_damage;
            break;
        case HEAVY_HELM:
        case HEAVY_CHEST:
        case LIGHT_HELM:
        case LIGHT_CHEST:
        case SHIELD:
            if (item.item_slot == CHEST) {
                point_val += (item.hp + item.shield + item.mana) * 2;
            } else point_val += (item.hp + item.shield + item.mana);
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

    point_val += (item.hp + item.shield + item.mana) * 2;
    point_val += (item.fire + item.cold + item.lightning + item.poison + item.dark) * 1.5;
    point_val += item.armor;
    return point_val;
};


@end
