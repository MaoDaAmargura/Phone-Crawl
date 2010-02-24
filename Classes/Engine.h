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
	
	Creature *currentTarget;
	BOOL showBattleMenu;
	
	PCPopupMenu *battleMenu;
	PCPopupMenu *attackMenu;
	PCPopupMenu *spellMenu;
	PCPopupMenu *itemMenu;
	
}

- (id) initWithView:(UIView*)view;

- (void) setSelectedMoveTarget:(Coord*) loc;

- (void) updateWorldView:(WorldView*) wView;

- (BOOL) canEnterTileAtCoord:(Coord*) coord;
- (void) movePlayerToTileAtCoord:(Coord*)tileCoord;
- (CGSize) tileSizeForWorldView:(WorldView*) wView;

- (Coord*) convertToDungeonCoord:(CGPoint) touch inWorldView:(WorldView *)wView;
- (CGPoint) originOfTile:(Coord*) tile inWorldView:(WorldView *)wView;

- (void) gameLoopWithWorldView:(WorldView*)wView;

- (void) playerEquipItem:(Item*)i;
- (void) playerUseItem:(Item*)i;
- (void) playerDropItem:(Item*)i;

- (NSArray*) getPlayerInventory;
- (EquipSlots*) getPlayerEquippedItems;

- (Creature*) player;

- (void) processTouch:(Coord *) coord;

- (void) showAttackMenu;

- (void) showSpellMenu;

- (void) showItemMenu;

- (void) ability_handler: (NSNumber *) ability_id;
- (void) spell_handler: (NSNumber *) spell_id;
- (void) item_handler:(Item *)it;

- (void) doTurnLoop;
- (void) doCreatureTurn:(Creature *)monster;

@end
