#import "Engine.h"

#import "Dungeon.h"
#import "Creature.h"
#import "Tile.h"
#import "Item.h"
#import "Spell.h"

#import "Util.h"

#import "WorldView.h"

#import "PCPopupMenu.h"

#import "CombatAbility.h"


@interface Engine (Private)
- (void) updateBackgroundImageForWorldView:(WorldView*)wView;
- (void) updateStatDisplayForWorldView:(WorldView *)wView;

- (Coord*) nextStepBetween:(Coord*) c1 and:(Coord*) c2;

- (Tile*) tileWithEstimatedShortestPath:(Coord*) c;
- (NSMutableArray*) getAdjacentEnterableTiles:(Coord*) c;
- (Coord*) arrayContains:(NSMutableArray*) arr Coord:(Coord*) c;
- (Coord*) coordWithShortestEstimatedPathFromArray:(NSMutableArray*) arrOfCoords toDest:(Coord*) dest;
- (void) drawMiniMapForWorldView: (WorldView*) wView;

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
														[Item generate_random_item:9 elem_type:DARK], 
														[Item generate_random_item:4 elem_type:FIRE], nil];
	Item *heal_test = [[Item alloc] initWithStats : @"Test Healing Potion"
										 icon_name: @"potion-red.png"
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

	DLog(@"Attempting to cast heal item");
	[heal_test cast:player target:nil];
	//[Spell cast_id:heal_test.spell_id caster:player target:nil];
	
}

- (id) initWithView:(UIView*)view
{
	if(self = [super init])
	{
		[Spell fill_spell_list];
		[CombatAbility fill_ability_list];
		liveEnemies = [[NSMutableArray alloc] init];
		deadEnemies = [[NSMutableArray alloc] init];
		
		currentTarget = nil;
		
		showBattleMenu = NO;
		
		// create enemy for battle testing
		Creature *creature = [Creature alloc];
		[creature initWithLevel: 0];
		creature.creatureLocation = [Coord withX:4 Y:0 Z:0];
		[liveEnemies addObject:creature];
		
		tilesPerSide = 9;
		
		[self createDevPlayer];
		
		currentDungeon = [[Dungeon alloc] initWithType: orcMines];
		battleMode = NO;
		selectedMoveTarget = nil;

		
		
		CGPoint origin = CGPointMake(0, 300);
		battleMenu = [[PCPopupMenu alloc] initWithOrigin:origin];
		[battleMenu addMenuItem:@"Attack" delegate:self selector:@selector(showAttackMenu) context:nil];
		[battleMenu addMenuItem:@"Spell" delegate:self selector:@selector(showSpellMenu) context:nil];
		[battleMenu addMenuItem:@"Item" delegate:self selector:@selector(showItemMenu) context: nil];
		[battleMenu showInView:view];

		[battleMenu hide];
		
		
		//Both menus will eventually need to be converted to using methods that go through Creature in order to get spell and ability lists from there
		origin = CGPointMake(60, 300);
		attackMenu = [[PCPopupMenu alloc] initWithOrigin:origin];
		for (CombatAbility* ca in ability_list) {
			[attackMenu addMenuItem:ca.name delegate:self selector: @selector(ability_handler:) context:[[NSNumber alloc] initWithInt:ca.ability_id]];
		}
		[attackMenu showInView:view];
		[attackMenu hide];
		
		spellMenu = [[PCPopupMenu alloc] initWithOrigin:origin];
		for (Spell* spell in spell_list) {
			[spellMenu addMenuItem:spell.name delegate:self selector: @selector(spell_handler:) context:[[NSNumber alloc] initWithInt:spell.spell_id]];
		}
		[spellMenu showInView:view];
		[spellMenu hide];
		
		itemMenu = [[PCPopupMenu alloc] initWithOrigin:origin];
		for (Item* it in player.inventory) 
			if(!it.is_equipable)
				[itemMenu addMenuItem:it.item_name delegate:self selector:@selector(item_handler:) context:it];
		[itemMenu showInView:view];
		[itemMenu hide];
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
	NSMutableArray *discard = [NSMutableArray array];
	// remove all dead monsters
	for (Creature *m in liveEnemies) {
		if (m.current.health <= 0) {
			if (m == currentTarget) {
				currentTarget = nil;
			}
			[discard addObject:m];
		}
	}
	[liveEnemies removeObjectsInArray:discard];
	[deadEnemies addObjectsFromArray:discard];
	
	battleMode = FALSE;
	// check to see if we are in battle mode
	for (Creature *m in liveEnemies) {
		Coord *pc = [player creatureLocation];
		Coord *mc = [m creatureLocation];
		int dist = [Util point_distanceX1:pc.X Y1:pc.Y X2:mc.X Y2:mc.Y];
		if (dist <= player.aggro_range+m.aggro_range) {
			battleMode = TRUE;
			selectedMoveTarget = nil;
			break;
		}
	}
	
	if (currentTarget != nil) {
		[battleMenu show];
	} else {
		[battleMenu hide];
		[attackMenu hide];
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
 @method		drawMiniMap
 @abstract		presents the minimap
 @discussion	does this belong in this class?
 */
- (void) drawMiniMapForWorldView: (WorldView*) wView {
	UIGraphicsBeginImageContext(CGSizeMake(MAP_DIMENSION, MAP_DIMENSION));
	CGContextRef context = UIGraphicsGetCurrentContext();

	UIGraphicsPushContext(context);

	UIImage *white = [UIImage imageNamed: @"white-dot.png"];
	UIImage *green = [UIImage imageNamed: @"green-dot.png"];
	UIImage *black = [UIImage imageNamed: @"black-dot.png"];
	UIImage *orange = [UIImage imageNamed: @"orange-dot.png"];
	UIImage *blue = [UIImage imageNamed: @"blue-dot.png"];
//	UIImage *black = [UIImage imageNamed: @"black-dot.png"];

	Coord *playerLoc = [player creatureLocation];
	int z = playerLoc.Z;
	for (int x = 0; x < MAP_DIMENSION; x++) {
		for (int y = 0; y < MAP_DIMENSION; y++) {
			CGRect rect = CGRectMake(x, y, 1, 1);

			int delta = abs(x - playerLoc.X);
			delta += abs(y - playerLoc.Y);
			if (delta < 3) {
				[green drawInRect: rect];
				continue;
			}

			Tile *tile = [currentDungeon tileAtX: x Y: y Z: z];
			if (tile.blockMove) {
				[black drawInRect: rect];
				continue;
			}

			if (tile.slope == slopeUp) {
				[blue drawInRect: rect];
				continue;
			}

			if (tile.slope == slopeDown) {
				[orange drawInRect: rect];
				continue;
			}			

			[white drawInRect: rect];
		}
	}

	UIGraphicsPopContext();

	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	wView.miniMapImageView.image = result;
}

/*!
 @method		updateWorldView
 @abstract		main graphics loop for world view. 
 */
- (void) updateWorldView:(WorldView*) wView {
	[self updateBackgroundImageForWorldView:wView];
	[self updateStatDisplayForWorldView:wView];
	[self drawMiniMapForWorldView: wView];
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

- (void) drawMonsterForWorldView:(WorldView*)wView Monster:(Creature*)m
{
	CGSize tileSize = [self tileSizeForWorldView:wView];
	Coord *center = [m creatureLocation];
	Coord *c2 = [player creatureLocation];
	Coord *dist = [Coord withX:center.X-c2.X Y:center.Y-c2.Y Z:0];
	Coord *draw = [Coord withX:c2.X+dist.X*2 Y:c2.Y+dist.Y*2 Z:0];
	CGPoint upperLeft = CGPointMake(draw.X-(4+dist.X), draw.Y-(4+dist.Y));
	
	// Draw the monster on the proper tile.
	// this is just for testing-need to make proper image draw later
	UIImage *monsterSprite = [UIImage imageNamed:@"1elf-warrior-elvina-1.jpg"];
	[monsterSprite drawInRect:CGRectMake((draw.X-upperLeft.x)*tileSize.width, (draw.Y-upperLeft.y)*tileSize.height, tileSize.width, tileSize.height)];
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
	
	for (Creature *m in liveEnemies) {
		[self drawMonsterForWorldView:wView Monster:m];
	}

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
	[wView setDisplay:displayStatHealth withAmount:player.current.health ofMax:player.max.health];
	[wView setDisplay:displayStatShield withAmount:player.current.shield ofMax:player.max.shield];
	[wView setDisplay:displayStatMana withAmount:player.current.mana ofMax:player.max.mana];
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
	// check to make sure position is free of monsters
	BOOL touchMonster = NO;
	for (Creature *m in liveEnemies) {
		Coord *mp = [m creatureLocation];
		if (mp.X == tileCoord.X && mp.Y == tileCoord.Y) {
			touchMonster = YES;
			currentTarget = m;
			showBattleMenu = YES;
			break;
		}
	}
	if (touchMonster == NO) {
		player.creatureLocation = tileCoord;
		slopeType currSlope = [currentDungeon tileAt: tileCoord].slope;
		if (currSlope) {
			player.creatureLocation.Z += (currSlope == slopeDown)? 1 : -1;
			[self setSelectedMoveTarget:nil];
		}
	}
}

#define PLAYER_INSTANT_TRANSMISSION false

- (void) processTouch:(Coord *)tileCoord {
	BOOL touchMonster = NO;
	for (Creature *m in liveEnemies) {
		Coord *mp = [m creatureLocation];
		if (mp.X == tileCoord.X && mp.Y == tileCoord.Y) {
			touchMonster = YES;
			currentTarget = m;
			showBattleMenu = YES;
			break;
		}
	}
	if (touchMonster == NO) {
		if(PLAYER_INSTANT_TRANSMISSION) {
			[self movePlayerToTileAtCoord:tileCoord];
		} else {
			if (!battleMode) {
				[self setSelectedMoveTarget:tileCoord];
			} else {
				Coord *c = [self nextStepBetween:player.creatureLocation and: tileCoord];
				[self movePlayerToTileAtCoord: c];
			}
		}
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
#pragma mark Player Commands

- (void) playerEquipItem:(Item*)i
{
	[player Add_Equipment:i slot:i.item_slot];
	
}

- (void) playerUseItem:(Item*)i
{
	if( i == nil ) return;
	if([i cast:player target:currentTarget] == 0)
		[self playerDropItem:i];
}

- (void) playerDropItem:(Item*)i
{	
	if (i == nil) return;
	[player.inventory removeObject:i];
	//Currently does not update inventory view until press inventory screen's button again
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

- (EquipSlots*) getPlayerEquippedItems
{
	return player.equipment;
}

- (Creature*) player
{
	return player;
}

#pragma mark -
#pragma mark Menu functions

- (void) showAttackMenu {
	[attackMenu show];
}

- (void) showSpellMenu {
	[spellMenu show];
}

- (void) showItemMenu {
	[itemMenu show];
}

- (void) ability_handler: (NSNumber *) ability_id{
	//DLog(@"ability handler");
	[CombatAbility use_ability_id:[ability_id intValue] caster:player target:currentTarget];
}
	 
- (void) spell_handler: (NSNumber *) spell_id {
	//DLog(@"spell handler");
	[Spell cast_id:[spell_id intValue] caster:player target:currentTarget];
}
- (void) item_handler: (Item*) it{
	[self playerUseItem:it];
}
@end
