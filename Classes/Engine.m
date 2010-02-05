#import "Engine.h"

#import "Dungeon.h"
#import "Creature.h"
#import "ItemGen.h"

#import "Tile.h"
#import "Util.h"


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
		tilesPerSide = 9;
		// FIXME: why does this cast silence a compiler warning RE: assignment from distinct Ob-C type?
		// Fixed - Tile and Dungeon both had initWithType method and compiler found Tiles method instead.
		// I renamed tiles init method and refactored it. - Austin
		currentDungeon = [[Dungeon alloc] initWithType: orcMines];
		//player.creatureLocation = [Coord withX:2 Y:2 Z:0];

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

- (void) updateWorldView:(WorldView*) wView
{
	//Coord *center = currentDungeon.playerLocation;
//	Coord *center = [Coord withX:2 Y:2 Z:0];
	Coord *center = [player creatureLocation];
	int xInd, yInd;
	
	CGRect bounds = wView.mapImageView.bounds;
	
	CGSize tileSize = [self tileSizeForWorldView:wView];
	
	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	int halfTile = (tilesPerSide-1)/2;
	
	CGPoint lowerRight = CGPointMake(center.X + halfTile, center.Y + halfTile);
	CGPoint upperLeft = CGPointMake(center.X-halfTile, center.Y-halfTile);
	
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
			[img drawInRect:CGRectMake((xInd-upperLeft.x)*tileSize.width, (yInd-upperLeft.y)*tileSize.height, tileSize.width, tileSize.height)];
		}
	}
	
	// Draw the player on the proper tile.
	UIImage *playerSprite = [UIImage imageNamed:@"human1.png"];
	[playerSprite drawInRect:CGRectMake((center.X-upperLeft.x)*tileSize.width, (center.Y-upperLeft.y)*tileSize.height, tileSize.width, tileSize.height)];
	
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

- (BOOL) canEnterTileAtCoord:(Coord*) coord
{
	Tile *t = [currentDungeon tileAt:coord];
	
	if(t) 
		return !t.blockMove;
	else 
		return NO;
	
}

- (void) movePlayerToTileAtCoord:(Coord*)tileCoord
{
	player.creatureLocation = tileCoord;
}

- (CGSize) tileSizeForWorldView:(WorldView*) wView
{
	CGRect bounds = wView.mapImageView.bounds;
	int tileWidth = bounds.size.width/tilesPerSide;
	int tileHeight = bounds.size.height/tilesPerSide;
	
	return CGSizeMake(tileWidth, tileHeight);
}

- (Coord*) convertToDungeonCoord:(CGPoint) touch inWorldView:(WorldView *)wView
{
	Coord *center = player.creatureLocation;
	
	CGSize tileSize = [self tileSizeForWorldView:wView];
	int halfTile = (tilesPerSide-1)/2;
	
	CGPoint topleft = CGPointMake(center.X - halfTile, center.Y - halfTile);
	return [Coord withX:topleft.x + touch.x/tileSize.width Y:topleft.y + touch.y/tileSize.height Z:center.Z];
	
}

- (CGPoint) originOfTile:(Coord*) tile inWorldView:(WorldView *)wView
{
	Coord *center = player.creatureLocation;
	CGSize tileSize = [self tileSizeForWorldView:wView];
	int halfTile = (tilesPerSide-1)/2;
	
	
	CGPoint topleft = CGPointMake(center.X - halfTile, center.Y - halfTile);
	
	return CGPointMake((tile.X-topleft.x)*tileSize.width, (tile.Y-topleft.y)*tileSize.height);
	
}


@end
