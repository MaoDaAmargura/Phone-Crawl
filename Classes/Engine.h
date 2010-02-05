#import <Foundation/Foundation.h>
#import "WorldView.h"

@class Creature;
@class Dungeon;
@class Coord;

@interface Engine : NSObject 
{
	
	NSMutableArray *liveEnemies; 
	NSMutableArray *deadEnemies;
	
	Creature *player;
	
	Dungeon *currentDungeon;
	
	int tilesPerSide;
	
}

- (id) init;

- (void) updateWorldView:(WorldView*) wView;

- (BOOL) canEnterTileAtCoord:(Coord*) coord;
- (void) movePlayerToTileAtCoord:(Coord*)tileCoord;
- (CGSize) tileSizeForWorldView:(WorldView*) wView;

- (Coord*) convertToDungeonCoord:(CGPoint) touch inWorldView:(WorldView *)wView;
- (CGPoint) originOfTile:(Coord*) tile inWorldView:(WorldView *)wView;



- (bool) validTileAtLocalCoord: (CGPoint) localCoord;

- (bool) movePlayerToLocalCoord: (CGPoint) localCoord;

@end
