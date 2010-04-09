
#import <Foundation/Foundation.h>

#import "Critter.h"	// Needs EquippedItems struct
#import "Dungeon.h"	// Needs levelType enum

@class BattleMenuManager;
@class WorldView;
@class Coord;
@class Item;
@class WorldView;
@class Spell;
@class Skill;
@class NPCDialogManager;

#define ENGINE_DICTIONARY_KEY "andi402mdu501ke75ncm39dj50s37fn3"

@interface Engine : NSObject 
{	
	BOOL tutorialMode;
	
	Critter *player;
	
	Dungeon *currentDungeon;
	NSLock *loadDungeonLock;
	
	int tilesPerSide;
	
	BattleMenuManager *battleMenuMngr;
	
	int oldPlayerLevel;

	// ugly, hackish workaround used only in moving the battleMenu to the correct spot
	// when attacking a monster.
	// - Nate
	WorldView *worldViewRef;
	NPCDialogManager *npcManager;
}

@property (nonatomic, retain) Critter *player;
@property (nonatomic, retain) Dungeon *currentDungeon;

@property (nonatomic, retain) WorldView *worldViewRef;

@property (nonatomic) BOOL tutorialMode;

@property (nonatomic, retain) NPCDialogManager *npcManager;

- (id) init;

- (void) updateWorldView;
- (void) gameLoop;
- (void) changeToDungeon:(levelType)type;
- (void) processTouch:(Coord *) coord;

- (BOOL) canEnterTileAtCoord:(Coord*) coord;
- (CGSize) tileSizeForWorldView;
- (Coord*) convertToDungeonCoord:(CGPoint) touch;
- (CGPoint) originOfTile:(Coord*) tile;


- (void) ability_handler:(Skill*)skill;
- (void) spell_handler:(Spell *)spell;
- (void) item_handler:(Item *)item;

- (void) playerEquipItem:(Item*)i;
- (void) playerDequipItem:(Item*)i;
- (void) playerUseItem:(Item*)i;
- (void) playerDropItem:(Item*)i;
- (void) sellItem:(Item *)it;
- (void) buyItem:(Item *)it;

- (BOOL) locationIsOccupied:(Coord*)loc;

- (NSMutableArray*) getPlayerInventory;
- (EquippedItems) getPlayerEquippedItems;

- (void) startNewGameWithPlayerName:(NSString*)name andIcon:(NSString*)icon;

@end
