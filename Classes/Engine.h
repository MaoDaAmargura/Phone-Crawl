
#import <Foundation/Foundation.h>


@class WorldView;
@class Creature;
@class Dungeon;
@class Coord;
@class Item;
@class EquipSlots;
@class PCPopupMenu;
@class WorldView;
@class CombatAbility;
@class Spell;

#define ENGINE_DICTIONARY_KEY "andi402mdu501ke75ncm39dj50s37fn3"

@interface Engine : NSObject 
{
	
	NSMutableArray *liveEnemies; 
	NSMutableArray *deadEnemies;
	
	Creature *player;
	
	Dungeon *currentDungeon;
	
	int tilesPerSide;
	
	Coord *selectedMoveTarget;
	Item *selectedItemToUse;
	BOOL battleMode;
	
	BOOL showBattleMenu;
	
	BOOL hasAddedMenusToWorldView;
	
	PCPopupMenu *battleMenu;
	PCPopupMenu *attackMenu;
	PCPopupMenu *spellMenu;
	PCPopupMenu *itemMenu;
	PCPopupMenu *damageSpellMenu;
	PCPopupMenu *conditionSpellMenu;
}

@property (nonatomic, retain) Creature *player;

- (id) initWithView:(UIView*)view;

- (void) setSelectedMoveTarget:(Coord*) loc ForCreature:(Creature *)c;

- (void) updateWorldView:(WorldView*) wView;

- (void) fillSpellMenuForCreature: (Creature *) c;
- (void) fillAttackMenuForCreature: (Creature *) c;


- (BOOL) tileAtCoordBlocksMovement:(Coord*) coord;
- (BOOL) creature:(Creature *)c CanEnterTileAtCoord:(Coord*) coord;
- (void) moveCreature:(Creature *) c ToTileAtCoord:(Coord*)tileCoord;
- (CGSize) tileSizeForWorldView:(WorldView*) wView;

- (Coord*) convertToDungeonCoord:(CGPoint) touch inWorldView:(WorldView *)wView;
- (CGPoint) originOfTile:(Coord*) tile inWorldView:(WorldView *)wView;

- (void) gameLoopWithWorldView:(WorldView*)wView;

- (void) playerEquipItem:(Item*)i;
- (void) playerUseItem:(Item*)i;
- (void) playerDropItem:(Item*)i;

- (NSArray*) getPlayerInventory;
- (EquipSlots*) getPlayerEquippedItems;

- (void) processTouch:(Coord *) coord;

- (void) ability_handler:(CombatAbility *)action;
- (void) spell_handler:(Spell *)spell;
- (void) item_handler:(Item *)item;

- (void) startNewGameWithPlayerName:(NSString*)name andIcon:(NSString*)icon;

@end
