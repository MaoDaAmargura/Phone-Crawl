
#import <Foundation/Foundation.h>

@class BattleMenuManager;
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
	
	BOOL tutorialMode;
	
	Creature *player;
	
	Dungeon *currentDungeon;
	
	int tilesPerSide;
	
	Coord *selectedMoveTarget;
	Item *selectedItemToUse;
	BOOL battleMode;
	
	BOOL showBattleMenu;
	
	BOOL hasAddedMenusToWorldView;
	
	NSLock *loadDungeonLock;
	
	BattleMenuManager *battleMenuMngr;

	// ugly, hackish workaround used only in moving the battleMenu to the correct spot
	// when attacking a monster.
	// - Nate
	WorldView *worldViewSingleton;
}

@property (nonatomic, retain) Creature *player;
@property (nonatomic, retain) Dungeon *currentDungeon;

@property (nonatomic, retain) WorldView *worldViewSingleton;

@property (nonatomic) BOOL tutorialMode;


- (id) init;

- (void) updateWorldView:(WorldView*) wView;

- (BOOL) tileAtCoordBlocksMovement:(Coord*) coord;
- (BOOL) canEnterTileAtCoord:(Coord*) coord;
- (void) moveCreature:(Creature *) c ToTileAtCoord:(Coord*)tileCoord;
- (CGSize) tileSizeForWorldView:(WorldView*) wView;

- (Coord*) convertToDungeonCoord:(CGPoint) touch inWorldView:(WorldView *)wView;
- (CGPoint) originOfTile:(Coord*) tile inWorldView:(WorldView *)wView;

- (void) gameLoopWithWorldView:(WorldView*)wView;

- (void) playerEquipItem:(Item*)i;
- (void) playerUseItem:(Item*)i;
- (void) playerDropItem:(Item*)i;

- (void) sellItem:(Item *)it;
- (void) buyItem:(Item *)it;

- (NSMutableArray*) getPlayerInventory;
- (EquipSlots*) getPlayerEquippedItems;

- (void) processTouch:(Coord *) coord;

- (void) ability_handler:(CombatAbility *)action;
- (void) spell_handler:(Spell *)spell;
- (void) item_handler:(Item *)item;

- (void) startNewGameWithPlayerName:(NSString*)name andIcon:(NSString*)icon;


- (void) drawHealthBar:(Creature *)m inWorld:(WorldView*) wView;

@end
