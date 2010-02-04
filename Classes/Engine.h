#import <Foundation/Foundation.h>
#import "WorldView.h"

@class Creature;
@class Dungeon;

@interface Engine : NSObject 
{
	
	NSMutableArray *liveEnemies; 
	NSMutableArray *deadEnemies;
	
	Creature *player;
	
	Dungeon *currentDungeon;
	
}

- (id) init;

- (void) updateWorldView:(WorldView*) wView;

- (bool) validTileAtLocalCoord: (CGPoint) localCoord;

- (bool) movePlayerToLocalCoord: (CGPoint) localCoord;


@end
