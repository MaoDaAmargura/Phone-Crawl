#import <Foundation/Foundation.h>
#import "WorldView.h"

@class Creature;
@class Dungeon;
@class Coord;

#define ENGINE_DICTIONARY_KEY "andi402mdu501ke75ncm39dj50s37fn3"

@interface Engine : NSObject 
{
	
	NSMutableArray *liveEnemies; 
	NSMutableArray *deadEnemies;
	
	Creature *player;
	
	Dungeon *currentDungeon;
	
	int tilesPerSide;
	
	Coord *selectedMoveTarget;
	BOOL battleMode;
	
}

- (id) init;

- (void) setSelectedMoveTarget:(Coord*) loc;

- (void) updateWorldView:(WorldView*) wView;

- (BOOL) canEnterTileAtCoord:(Coord*) coord;
- (void) movePlayerToTileAtCoord:(Coord*)tileCoord;
- (CGSize) tileSizeForWorldView:(WorldView*) wView;

- (Coord*) convertToDungeonCoord:(CGPoint) touch inWorldView:(WorldView *)wView;
- (CGPoint) originOfTile:(Coord*) tile inWorldView:(WorldView *)wView;

- (void) gameLoopWithWorldView:(WorldView*)wView;

@end
