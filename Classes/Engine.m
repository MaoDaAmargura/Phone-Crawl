#import "Engine.h"

#import "Dungeon.h"
#import "Creature.h"
#import "ItemGen.h"

#import "Tile.h"


@interface Engine (Private)
@end


@implementation Engine

#pragma mark -
#pragma mark Life Cycle
- (id) init
{
	if(self = [super init])
	{
		liveEnemies = [[NSMutableArray alloc] init];
		deadEnemies = [[NSMutableArray alloc] init];
		player = [[Creature alloc] init];
		[player Take_Damage:150];
		// FIXME: why does this cast silence a compiler warning RE: assignment from distinct Ob-C type?
		// Fixed - Tile and Dungeon both had initWithType method and compiler found Tiles method instead.
		// I renamed tiles init method and refactored it. - Austin
		currentDungeon = [[Dungeon alloc] initWithType: orcMines];

		return self;
	}
	return nil;
}

- (void) releaseResources
{
	[liveEnemies release];
	[deadEnemies release];
	[player release];
	[currentDungeon release];
}

- (void) dealloc
{
	[self releaseResources];
	[super dealloc];
	
}

- (void) loadDungeon:(Dungeon *)dungeon
{
	
}

- (void) updateWorldView:(WorldView*) wView
{
	Coord *center = currentDungeon.playerLocation;
//	Coord *center = [Coord withX:2 Y:2 Z:0];
	//Coord *center = [player location];
	int xInd, yInd;
	int squaresWide = 10, squaresHigh = 10;
	
	CGRect bounds = wView.mapImageView.bounds;
	int imageWidth = bounds.size.width/squaresWide;
	int imageHeight = bounds.size.height/squaresHigh;
	
	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	int halfWide = squaresWide/2, halfHigh = squaresHigh/2;
	
	CGPoint lowerRight = CGPointMake(center.X+halfWide-(squaresWide-1)%2, center.Y+halfHigh-(squaresHigh-1)%2);
	CGPoint upperLeft = CGPointMake(center.X-halfWide, center.Y-halfHigh);
	
	UIGraphicsPushContext(context);
	
	for (xInd = upperLeft.x; xInd <= lowerRight.x; ++xInd)
	{
		for(yInd = upperLeft.y; yInd <= lowerRight.y; ++yInd)
		{
			UIImage *img;
			Tile *t = [currentDungeon tileAtX:xInd Y:yInd Z:center.Z];
			if(t)
				img = [Tile imageForType:t.type]; //Get tile from array by index if it exists
			else
				img = [Tile imageForType:tileNone]; //Black square if the tile doesn't exist

			// Draw each tile in the proper place
			[img drawInRect:CGRectMake((xInd-upperLeft.x)*imageWidth, (yInd-upperLeft.y)*imageHeight, imageWidth, imageHeight)];
		}
	}
	
	// Draw the player on the proper tile.
	UIImage *playerSprite = [UIImage imageNamed:@"human1.png"];
	[playerSprite drawInRect:CGRectMake((center.X-upperLeft.x)*imageWidth, (center.Y-upperLeft.y)*imageHeight, imageWidth, imageHeight)];
	
	UIGraphicsPopContext();
	
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	wView.mapImageView.image = result;
	
//	int base = [player statBase];
	[wView setDisplay:displayStatHealth withAmount:player.curr_health ofMax:player.max_health];
	[wView setDisplay:displayStatShield withAmount:player.curr_shield ofMax:player.max_shield];
	[wView setDisplay:displayStatMana withAmount:player.curr_mana ofMax:player.max_mana];
	
	
}

#pragma mark -
#pragma mark control
/*!
 @abstract		convert a point in the local coordinate system to the global (dungeon wide) system.
 @discussion	'int offset' is a hack based on the player being at the center of the screen.
				(to be changed.)
 */

- (Coord*) absoluteCoord: (CGPoint) localCoord {
	Coord *playerCoord = currentDungeon.playerLocation;
	int offset = 5;	// FIXME
	localCoord.x -= offset, localCoord.y -= offset;
	int absoluteX = localCoord.x + playerCoord.X;
	int absoluteY = localCoord.y + playerCoord.Y;

	return [Coord withX:absoluteX Y:absoluteY Z:playerCoord.Z];
}

/*!
 @abstract		check the tile at the screen-relative given coordinates to see if it is reachable.
 @discussion	this DOES NOT CHECK with regards to missile attacks.  it is only for movement.
 */

- (bool) validTileAtLocalCoord: (CGPoint) localCoord {
	Coord *absoluteCoord = [self absoluteCoord: localCoord];

	if (absoluteCoord.X < 0 || absoluteCoord.X >= MAP_DIMENSION) return false;
	if (absoluteCoord.Y < 0 || absoluteCoord.Y >= MAP_DIMENSION) return false;

	Tile *tile = [currentDungeon tileAtX: absoluteCoord.X Y: absoluteCoord.Y Z: absoluteCoord.Z];
	return (tile.blockMove)? false : true;
}

- (bool) movePlayerToLocalCoord: (CGPoint) localCoord {
	if (![self validTileAtLocalCoord: localCoord]) return false;

	Coord *absoluteCoord = [self absoluteCoord: localCoord];
//	DLog(@"%@", [currentDungeon.playerLocation description]);
	currentDungeon.playerLocation = absoluteCoord;
//	DLog(@"%@", [currentDungeon.playerLocation description]);
	return true;
}







@end
