#import "Engine.h"

#import "Dungeon.h"
#import "Creature.h"
#import "Tile.h"
#import "Item.h"
#import "Spell.h"

#import "Util.h"

#import "WorldView.h"

@interface Engine (Private)
- (void) updateBackgroundImageForWorldView:(WorldView*)wView;
- (void) updateStatDisplayForWorldView:(WorldView *)wView;

- (Coord*) nextStepBetween:(Coord*) c1 and:(Coord*) c2;

- (Tile*) tileWithEstimatedShortestPath:(Coord*) c;
- (NSMutableArray*) getAdjacentEnterableTiles:(Coord*) c;
- (Coord*) arrayContains:(NSMutableArray*) arr Coord:(Coord*) c;
- (Coord*) coordWithShortestEstimatedPathFromArray:(NSMutableArray*) arrOfCoords toDest:(Coord*) dest;

@end


@implementation Engine

#pragma mark -
#pragma mark Life Cycle

- (void) createDevPlayer
{
	player = [[Creature alloc] init];
	[player Take_Damage:150];
	player.inventory = [NSMutableArray arrayWithObjects:[Item generate_random_item:1 elem_type:FIRE],
														[Item generate_random_item:2 elem_type:COLD],
														[Item generate_random_item:1 elem_type:LIGHTNING],
														[Item generate_random_item:3 elem_type:POISON],
						[Item generate_random_item:9 elem_type:DARK], nil];
	Item *heal_test = [[Item alloc] initWithStats : @"Test Healing Potion"
										 icon_name: @"../Images/Consumable/potion-red.png"
									  item_quality: REGULAR
										 item_slot: BAG 
										 elem_type: DARK 
										 item_type: POTION
											damage: 1
									   elem_damage: 0
										   charges: 1
											 range: 1 
												hp: 0 
											shield: 0 
											  mana: 0 
											  fire: 0 
											  cold: 0 
										 lightning: 0
											poison: 0 
											  dark: 0 
											 armor: 0
										  spell_id: ITEM_HEAL_SPELL_ID];
	[Spell fill_spell_list];
	DLog(@"Attempting to cast heal item");
	[Spell cast_id:heal_test.spell_id caster:player target:nil];
	
}

- (id) init
{
	if(self = [super init])
	{
		liveEnemies = [[NSMutableArray alloc] init];
		deadEnemies = [[NSMutableArray alloc] init];
		tilesPerSide = 9;
		
		[self createDevPlayer];
		
		// FIXME: why does this cast silence a compiler warning RE: assignment from distinct Ob-C type?
		// Fixed - Tile and Dungeon both had initWithType method and compiler found Tiles method instead.
		// I renamed tiles init method and refactored it. - Austin
		currentDungeon = [[Dungeon alloc] initWithType: orcMines];
		battleMode = NO;
		selectedMoveTarget = nil;

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

#pragma mark -
#pragma mark Control

- (void) gameLoopWithWorldView:(WorldView*)wView
{
	if (battleMode)
	{
		//draw menu
	}
	if (selectedItemToUse)
	{
		//use item
		selectedItemToUse = nil;
		return;
	}
	
	if(selectedMoveTarget)
	{
		Coord *next = [self nextStepBetween:[player creatureLocation] and:selectedMoveTarget];
		[self movePlayerToTileAtCoord:next];
		if([selectedMoveTarget equals:[player creatureLocation]])
			[self setSelectedMoveTarget:nil];
	}
	
	[self updateWorldView:wView];

}

#pragma mark -
#pragma mark Pathing

- (Coord*) nextStepBetween:(Coord*) c1 and:(Coord*) c2
{
   NSMutableArray *discovered = [NSMutableArray arrayWithCapacity:50];
   c2.distance = 0;
   [discovered addObject: (id)c2];
   NSMutableArray *evaluated = [NSMutableArray arrayWithCapacity:50];
   while( [discovered count] != 0 )
   {
      Coord *c = [self coordWithShortestEstimatedPathFromArray:discovered toDest:c1];
      [evaluated addObject:c];
      [discovered removeObject:c];
      NSMutableArray *arr = [self getAdjacentEnterableTiles:c];
      for( Coord *cadj in arr )
      {
         if( [cadj equals:c1] )
            return c;
         if( [self arrayContains:evaluated Coord:cadj] )
            continue;
         cadj.distance = c.distance + 1;
         Coord *existing = [self arrayContains:discovered Coord:cadj];
         if( existing )
            existing.distance = cadj.distance > existing.distance 
                                 ? existing.distance : cadj.distance;
         else
            [discovered addObject:(id)cadj];
      }
   
   }
   
	return c1;
}

- (NSMutableArray*) getAdjacentEnterableTiles:(Coord*) c
{
   NSMutableArray *ret = [NSMutableArray arrayWithCapacity:4];
   Coord *c1 = [Coord withX:c.X + 1 Y:c.Y Z:c.Z];
   if([self canEnterTileAtCoord: c1])
      [ret addObject: c1];
   c1 = [Coord withX:c.X - 1 Y:c.Y Z:c.Z];
   if([self canEnterTileAtCoord: c1])
      [ret addObject: c1];
   c1 = [Coord withX:c.X Y:c.Y + 1 Z:c.Z];
   if([self canEnterTileAtCoord: c1])
      [ret addObject: c1];
   c1 = [Coord withX:c.X Y:c.Y - 1 Z:c.Z];
   if([self canEnterTileAtCoord: c1])
      [ret addObject: c1];
   return ret;
}

- (Coord*) coordWithShortestEstimatedPathFromArray:(NSMutableArray*) arrOfCoords toDest:(Coord*) dest
{
   Coord *ret = [arrOfCoords objectAtIndex:0];
   for( Coord *c in arrOfCoords )
   {
      CGPoint diffnew = CGPointMake(dest.X-c.X, dest.Y-c.Y);
      CGPoint diffold = CGPointMake(dest.X-ret.X, dest.Y-ret.Y);
      if( abs(diffnew.x) + abs(diffnew.y) + c.distance 
          < abs(diffold.x) + abs(diffold.y) + ret.distance )
         ret = c;
   }
   return ret;
}

- (Coord*) arrayContains:(NSMutableArray*) arr Coord:(Coord*) c
{
   for( Coord *c1 in arr )
   {
      if( [c1 equals: c] )
      {
//         DLog(@"returning true");
         return c1;
      }
   }
   return nil;
}


#pragma mark -
#pragma mark Graphics

/*!
 @method		updateWorldView
 @abstract		main graphics loop for world view. 
 */
- (void) updateWorldView:(WorldView*) wView
{
	[self updateBackgroundImageForWorldView:wView];
	[self updateStatDisplayForWorldView:wView];
	
}

/*!
 @method		drawTiles
 @abstract		subroutine to draw tiles to the current graphics context
 */
- (void) drawTilesForWorldView:(WorldView*)wView
{
	int xInd, yInd;
	CGSize tileSize = [self tileSizeForWorldView:wView];
	int halfTile = (tilesPerSide-1)/2;
	Coord *center = [player creatureLocation];
	CGPoint lowerRight = CGPointMake(center.X + halfTile, center.Y + halfTile);
	CGPoint upperLeft = CGPointMake(center.X-halfTile, center.Y-halfTile);
	
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
}

- (void) drawPlayerForWorldView:(WorldView*)wView
{
	CGSize tileSize = [self tileSizeForWorldView:wView];
	int halfTile = (tilesPerSide-1)/2;
	Coord *center = [player creatureLocation];
	CGPoint upperLeft = CGPointMake(center.X-halfTile, center.Y-halfTile);
	
	// Draw the player on the proper tile.
	UIImage *playerSprite = [UIImage imageNamed:@"human1.png"];
	[playerSprite drawInRect:CGRectMake((center.X-upperLeft.x)*tileSize.width, (center.Y-upperLeft.y)*tileSize.height, tileSize.width, tileSize.height)];
	
}

/*!
 @method		updateBackgroundImage
 @abstract		draws background image and player. 
 @discussion	enemies kinda should be done with player. maybe i'll make an extra creature loop.
 */
- (void) updateBackgroundImageForWorldView:(WorldView*)wView
{
	CGRect bounds = wView.mapImageView.bounds;
	
	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIGraphicsPushContext(context);
	
	[self drawTilesForWorldView:wView];
	
	[self drawPlayerForWorldView:wView];
	
	UIGraphicsPopContext();
	
	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	wView.mapImageView.image = result;
}

/*!
 @method		updateStatDisplay
 @abstract		updates the stat displays based on the players vitals.
 */
- (void) updateStatDisplayForWorldView:(WorldView *)wView
{	
	[wView setDisplay:displayStatHealth withAmount:player.curr_health ofMax:player.max_health];
	[wView setDisplay:displayStatShield withAmount:player.curr_shield ofMax:player.max_shield];
	[wView setDisplay:displayStatMana withAmount:player.curr_mana ofMax:player.max_mana];
}


#pragma mark -
#pragma mark control
/*!
 @method		canEnterTileAtCoord:
 @abstract		query function for whether the player is allowed to move into a certain spot.
 */
- (BOOL) canEnterTileAtCoord:(Coord*) coord
{
	Tile *t = [currentDungeon tileAt:coord];
	
	if(t) 
		return !t.blockMove;
	else 
		return NO;
	
}

/*!
 @method		movePlayerToTileAtCoord:
 @abstract		public function to move the player. don't call it lightly. and if you want to see the movement,
				then call engines updateWorldView right after a call to this function.
				note that this will automatically toss the player up or down any stairs he lands on.
 */
- (void) movePlayerToTileAtCoord:(Coord*)tileCoord
{
	player.creatureLocation = tileCoord;
	slopeType currSlope = [currentDungeon tileAt: tileCoord].slope;
	if (currSlope) {
		player.creatureLocation.Z += (currSlope == slopeDown)? 1 : -1;
      [self setSelectedMoveTarget:nil];
	}
}

/*!
 @method		tileSizeForWorldView
 @abstract		calculates the size of a tile in the current world view with the current tilesPerSide configuration.
 */
- (CGSize) tileSizeForWorldView:(WorldView*) wView
{
	CGRect bounds = wView.mapImageView.bounds;
	int tileWidth = bounds.size.width/tilesPerSide;
	int tileHeight = bounds.size.height/tilesPerSide;
	
	return CGSizeMake(tileWidth, tileHeight);
}

/*!
 @method		convertToDungeonCoord
 @abstract		converts a point in pixels to an absolute dungeon coordinate.
 @discussion	coord returned is the actual location in dungeon that the screen was touched. no locality.
 */
- (Coord*) convertToDungeonCoord:(CGPoint) touch inWorldView:(WorldView *)wView
{
	Coord *center = player.creatureLocation;
	
	CGSize tileSize = [self tileSizeForWorldView:wView];
	int halfTile = (tilesPerSide-1)/2;
	
	CGPoint topleft = CGPointMake(center.X - halfTile, center.Y - halfTile);
	return [Coord withX:topleft.x + (int)(touch.x/tileSize.width) Y:topleft.y + (int)(touch.y/tileSize.height) Z:center.Z];
	
}

/*!
 @method		originOfTile
 @abstract		returns the pixel point on the screen that is the top left point where the tile at coord should be drawn.
 */
- (CGPoint) originOfTile:(Coord*) tileCoord inWorldView:(WorldView *)wView
{
	Coord *center = player.creatureLocation;
	CGSize tileSize = [self tileSizeForWorldView:wView];
	int halfTile = (tilesPerSide-1)/2;
	
	
	CGPoint topleft = CGPointMake(center.X - halfTile, center.Y - halfTile);
	
	return CGPointMake((tileCoord.X-topleft.x)*tileSize.width, (tileCoord.Y-topleft.y)*tileSize.height);
	
}

#pragma mark -
#pragma mark Custom Accessors

- (void) setSelectedMoveTarget:(Coord *)loc
{
	[selectedMoveTarget release];
	selectedMoveTarget = [loc retain];
}

- (NSArray*) getPlayerInventory
{
	return player.inventory;
}

@end
