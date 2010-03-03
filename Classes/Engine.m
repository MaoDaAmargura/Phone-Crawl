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

#define POINTS_TO_TAKE_TURN 15

@interface Engine (Private)
- (void) updateBackgroundImageForWorldView:(WorldView*)wView;
- (void) updateStatDisplayForWorldView:(WorldView *)wView;

- (void) redetermineBattleMode;
- (Creature *) nextCreatureToTakeTurn;
- (void) incrementCreatureTurnPoints;
- (void) determineActionForCreature:(Creature*)c;
- (void) performMoveActionForCreature:(Creature *)c;
- (void) performItemActionForCreature:(Creature *)c;
- (void) performSpellActionForCreature:(Creature *)c;
- (void) performCombatAbilityActionForCreature:(Creature *)c;

- (Coord*) nextStepBetween:(Coord*) c1 and:(Coord*) c2;
- (Tile*) tileWithEstimatedShortestPath:(Coord*) c;
- (NSMutableArray*) getAdjacentNonBlockingTiles:(Coord*) c;
- (Coord*) arrayContains:(NSMutableArray*) arr Coord:(Coord*) c;
- (Coord*) coordWithShortestEstimatedPathFromArray:(NSMutableArray*) arrOfCoords toDest:(Coord*) dest;
- (void) drawMiniMapForWorldView: (WorldView*) wView;
- (void) drawItemsForWorldView: (WorldView*) wView;

@end

extern NSMutableDictionary *items; // from Dungeon

@implementation Engine

#pragma mark -
#pragma mark Life Cycle

- (void) createDevPlayer
{
	player = [[Creature alloc] initPlayerWithLevel:0];
	//[player Take_Damage:150];
	player.inventory = [NSMutableArray arrayWithObjects:[Item generateRandomItem:1 elemType:FIRE],
														[Item generateRandomItem:2 elemType:COLD],
														[Item generateRandomItem:1 elemType:LIGHTNING],
														[Item generateRandomItem:3 elemType:POISON],
														[Item generateRandomItem:2 elemType:DARK], 
														[Item generateRandomItem:4 elemType:FIRE], nil];
	player.iconName = @"human1.png";
	DLog(@"Created player successfully");

	// this is an incredibly hackish workaround to GET PEOPLE TO QUIT STEPPING ON MY TELEPORT.
	// so DON'T TOUCH IT.
	// almost commented this out, just to see Nathan bust a vein -Bucky
	NSError *error = nil;
	[NSString stringWithContentsOfFile: @"/Users/nathanking/classes/cs115/Phone-Crawl/YES" encoding: NSUTF8StringEncoding error: &error];
	DLog(@"%@", [error description]);
	LVL_GEN_ENV = !error;
}

- (id) initWithView:(UIView*)view
{
	if(self = [super init])
	{
		[Spell fillSpellList];
		[CombatAbility fillAbilityList];
		liveEnemies = [[NSMutableArray alloc] init];
		deadEnemies = [[NSMutableArray alloc] init];
		
		showBattleMenu = NO;
		
		// create enemy for battle testing
		Creature *creature = [[Creature alloc] initMonsterOfType:WARRIOR withElement:FIRE level:0 atX:4 Y:0 Z:0];
		[liveEnemies addObject:creature];
		
		tilesPerSide = 9;
		
		[self createDevPlayer];
		
		//currentDungeon = [[Dungeon alloc] initWithType: town];
		currentDungeon = [[Dungeon alloc] initWithType: orcMines];
		battleMode = NO;
		selectedMoveTarget = nil;

		CGPoint origin = CGPointMake(0, 300);
		battleMenu = [[PCPopupMenu alloc] initWithOrigin:origin];
		[battleMenu addMenuItem:@"Attack" delegate:self selector:@selector(showAttackMenu) context:nil];
		[battleMenu addMenuItem:@"Spell" delegate:self selector:@selector(showSpellMenu) context:nil];
		[battleMenu addMenuItem:@"Item" delegate:self selector:@selector(showItemMenu) context: nil];
		[battleMenu showInView:view];
		battleMenu.hideOnFire = NO;

		[battleMenu hide];
		
		
		//Both menus will eventually need to be converted to using methods that go through Creature in order to get spell and ability lists from there
		origin = CGPointMake(60, 300);
		attackMenu = [[PCPopupMenu alloc] initWithOrigin:origin];
		DLog(@"Filling attack menu");
		[self fillAttackMenuForCreature:player];
		[attackMenu showInView:view];
		[attackMenu hide];
		DLog(@"Filling item menu");
		itemMenu = [[[PCPopupMenu alloc] initWithOrigin:origin] autorelease];
		for (Item* it in player.inventory) 
			if (it.type == WAND || it.type == POTION)
				[itemMenu addMenuItem:it.name delegate:self selector:@selector(item_handler:) context:it];
		[itemMenu showInView:view];
		[itemMenu hide];
		DLog(@"Filling spell menu");
		spellMenu = [[PCPopupMenu alloc] initWithOrigin:origin];
		[spellMenu addMenuItem:@"Damage" delegate:self selector:@selector(showDamageSpellMenu) context:nil];
		[spellMenu addMenuItem:@"Condition" delegate:self selector:@selector(showConditionSpellMenu) context:nil];
		damageSpellMenu = [[PCPopupMenu alloc] initWithOrigin:origin];
		conditionSpellMenu = [[PCPopupMenu alloc] initWithOrigin:origin];
		[self fillSpellMenuForCreature: player];
		[spellMenu showInView:view];
		[conditionSpellMenu showInView:view];
		[damageSpellMenu showInView:view];
		[damageSpellMenu hide];
		[conditionSpellMenu hide];	
		[spellMenu hide];
		return self;
	}
	return nil;
}

- (void) fillSpellMenuForCreature: (Creature *) c {
	for (int i = 0 ; i < NUM_PC_SPELL_TYPES ; ++i) {
		if(c.abilities.spellBook[i] == 0) // No points trained in that spell
			continue;
		else {
			Spell *spell = [spellList objectAtIndex:START_PC_SPELLS + i * 5 + c.abilities.spellBook[i] - 1];
			if(i < FIRECONDITION) //Is a damage spell
				[damageSpellMenu addMenuItem:spell.name delegate:self selector:@selector(spell_handler:) context:spell];
			else
				[conditionSpellMenu addMenuItem:spell.name delegate:self selector:@selector(spell_handler:) context:spell];
		}
	}
}

- (void) fillAttackMenuForCreature: (Creature *) c {
	for (int i = 0 ; i < NUM_COMBAT_ABILITY_TYPES ; ++i) {
		if(c.abilities.combatAbility[i] == 0) // No points trained in that ability
			continue;
		else {
			//CombatAbility *ca = [abilityList objectAtIndex:i * 3 + c.abilities.combatAbility[i] - 1]; // For once we have combat ability levels done
			CombatAbility *ca = [abilityList objectAtIndex:i];
			[attackMenu addMenuItem:ca.name delegate:self selector:@selector(ability_handler:) context:ca];
		}
	}
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
	 
	if (battleMenu.hidden == YES) {
		player.selectedCreatureForAction = nil;
	}
	if (player.selectedCreatureForAction == nil) {
		[battleMenu hide];
		[attackMenu hide];
		[spellMenu hide];
		[itemMenu hide];
	}
	
	Creature *creature = [self nextCreatureToTakeTurn];
	
	
	if( creature == player
		&& creature.selectedMoveTarget == nil
		&& creature.selectedItemToUse == nil
		&& creature.selectedSpellToUse == nil
		&& creature.selectedCombatAbilityToUse == nil )
	{
		[self updateWorldView:wView];
		return;
	}
	
	// if the creature is a monster, call the AI code
	if( creature != player )
		[self determineActionForCreature:creature];
	
	NSString *actionResult = @"";
	if (creature.selectedItemToUse)
	{
		//use item on selected target
		//DLog(@"In item usage");
		actionResult = [creature.selectedItemToUse cast:creature target:creature.selectedCreatureForAction];
		//DLog(@"Used item, result: %@",actionResult);
		// If charges are used up, drop item from inventory and rebuild item menu
		if (creature.selectedItemToUse.charges <= 0) {
			[creature.inventory removeObject:creature.selectedItemToUse];
			if(creature == player) {
				itemMenu = [[[PCPopupMenu alloc] initWithOrigin:CGPointMake(60, 300)] autorelease];
				for (Item* it in player.inventory) 
					if (it.type == WAND || it.type == POTION)
						[itemMenu addMenuItem:it.name delegate:self selector:@selector(item_handler:) context:it];
				[itemMenu showInView:wView.view];
				[itemMenu hide];
			}
		}
		creature.selectedCreatureForAction = nil;
		creature.selectedItemToUse = nil;
	} 
	if (creature.selectedCombatAbilityToUse && creature.selectedCreatureForAction)
	{
		//todo: use the combat ability on the target
		actionResult = [creature.selectedCombatAbilityToUse useAbility:creature target:creature.selectedCreatureForAction];
		creature.selectedCreatureForAction = nil;
		creature.selectedCombatAbilityToUse = nil;
	}
	if (creature.selectedSpellToUse)
	{
		//use the spell on the target
		actionResult = [creature.selectedSpellToUse cast:creature target:creature.selectedCreatureForAction];				
		creature.selectedCreatureForAction = nil;
		creature.selectedSpellToUse = nil;
	} 
	if(creature.selectedMoveTarget)
	{
		[self performMoveActionForCreature:creature];
	}
	//if(battleMode)
		//[self incrementCreatureTurnPoints];
	
	if(creature == player)
		wView.actionResult.text = actionResult; //Set some result string from actions
	[self updateWorldView:wView];

}

- (void) redetermineBattleMode
{
	// calculate battle mode
	BOOL previousBattleMode = battleMode;
	battleMode = NO;
	for (Creature *m in liveEnemies) {
		Coord *pc = [player creatureLocation];
		Coord *mc = [m creatureLocation];
		int dist = [Util point_distanceX1:pc.X Y1:pc.Y X2:mc.X Y2:mc.Y];
		battleMode |= (dist <= player.aggroRange+m.aggroRange);
	}
	
	// a quick hack to prevent turn_points from becoming unruly.
	if(previousBattleMode == NO && battleMode == YES)
	{
		player.turnPoints = 0;
		for (Creature *m in liveEnemies)
			m.turnPoints = 0;
	}
}

/*!
	@method		nextCreatureToTakeTurn
	@abstract		Returns a creature (any living monster or the player) that should take the next turn.
*/
- (Creature *) nextCreatureToTakeTurn
{
	//if(!battleMode)
		//return player; //ideally, the monsters will get a few turns. I have yet to figure out exactly how the point balance works.
	
	int highestPoints = player.turnPoints;
	Creature *highestCreature = nil;
	while (highestCreature == nil) {
		for( Creature *m in liveEnemies ) {
			if (m.current.health == 0){
				[liveEnemies removeObject:m];
				[deadEnemies addObject:m];
			}
			if(m.turnPoints > highestPoints && m.turnPoints > 100) {
				highestPoints = m.turnPoints;
				highestCreature = m;
			}
		}
		if(player.turnPoints > highestPoints && player.turnPoints > 100) {
			highestPoints = player.turnPoints;
			highestCreature = player;
		}
		if (highestCreature == nil) {
			[self incrementCreatureTurnPoints];
		}
	}
	return highestCreature;
}

- (void) incrementCreatureTurnPoints {
	player.turnPoints += 30;
	for(Creature *m in liveEnemies)
		m.turnPoints += 30;
}

- (void) determineActionForCreature:(Creature*)c
{
	if(battleMode)
	{
		[self setSelectedMoveTarget:player.creatureLocation ForCreature:c];
	} else {
		[self setSelectedMoveTarget:c.creatureLocation ForCreature:c];
	}
}

#define TURN_POINTS_FOR_MOVEMENT_ACTION 25
- (void) performMoveActionForCreature:(Creature *)c
{
	Coord *next = [self nextStepBetween:[c creatureLocation] and:c.selectedMoveTarget];
	if(![self creature:c CanEnterTileAtCoord:next])
	{
		//something other than terrain is blocking the path (probably monster)
		//this is not an impossible situation to get into, but I dont know how to handle it nicely.
		//the player probably didnt want to do this anyways.
		NSLog(@"A Creature has tried to run through a monster.");
		[c ClearTurnActions];
		return;
	}
	[self moveCreature:c ToTileAtCoord:next];
	
	// creature has reached its destination
	if ([c.creatureLocation equals: c.selectedMoveTarget]) {
		[self setSelectedMoveTarget:nil ForCreature:c];
	}
	if(battleMode)
		[self setSelectedMoveTarget:nil ForCreature:c];
	c.turnPoints -= TURN_POINTS_FOR_MOVEMENT_ACTION;
}

/*!
	@method		performItemActionForCreature
	@abstract		given a creature with an item and target marked for use, this method will use the item. 
	@discussion		This should be handled by the spell handler instead.
*/
- (void) performItemActionForCreature:(Creature *)c
{
	//if the item has a spell associated with it
	{
		//use the spell
	}
	//else
	{
		//do nothing.  The player can't use a helmet as a turn action.  
		//Equiping and dropping items is done outside of the turn system.
		[c ClearTurnActions];
	}
		
}

/*!
	@method		performSpellActionForCreature
	@abstract		given a creature with a spell and target marked for use, this method will cast the spell. 
*/
- (void) performSpellActionForCreature:(Creature *)c
{
		//maintenance
	c.turnPoints -= c.selectedSpellToUse.turnPointCost;
	[c ClearTurnActions];
}
- (void) performCombatAbilityActionForCreature:(Creature *)c
{
	//if creature is in range
		//do combatAction
		
		//c.turn_points -= c.selectedCombatAbilityToUse.required_turn_points;
		//[c ClearTurnActions];
	//else
	{
		Coord *moveTo = nil;
		//if equiped item has a minimum range
			//i dunno, crap out.  I really don't want to calculate moving backwards to get in range.
		//else
			moveTo = c.selectedCreatureForAction.creatureLocation;
		[self setSelectedMoveTarget:moveTo ForCreature:c];
		[self performMoveActionForCreature:c];
		[self setSelectedMoveTarget:nil ForCreature:c];
		
	}
}


#pragma mark -
#pragma mark Pathing

/*!
	@method		nextStepBetween:c1 and:c2
	@abstract		Runs an A* algorithm to find the next step on an optimal path towards the destination.
						Monsters are not considered.  They do not block the path.
	@discussion		This method does not save the path when it's generated.  It definitely should.
						Gets slow (>0.25 seconds) when paths are above 80 tiles or so.
*/
- (Coord*) nextStepBetween:(Coord*) c1 and:(Coord*) c2
{
	if([c1 equals:c2])
		return c1;
   NSMutableArray *discovered = [NSMutableArray arrayWithCapacity:50];
   c2.distance = 0;
   [discovered addObject: (id)c2];
   NSMutableArray *evaluated = [NSMutableArray arrayWithCapacity:50];
   while( [discovered count] != 0 )
   {
      Coord *c = [self coordWithShortestEstimatedPathFromArray:discovered toDest:c1];
      [evaluated addObject:c];
      [discovered removeObject:c];
      NSMutableArray *arr = [self getAdjacentNonBlockingTiles:c];
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

- (NSMutableArray*) getAdjacentNonBlockingTiles:(Coord*) c
{
   NSMutableArray *ret = [NSMutableArray arrayWithCapacity:4];
   Coord *c1 = [Coord withX:c.X + 1 Y:c.Y Z:c.Z];
   if(![self tileAtCoordBlocksMovement: c1])
      [ret addObject: c1];
   c1 = [Coord withX:c.X - 1 Y:c.Y Z:c.Z];
   if(![self tileAtCoordBlocksMovement: c1])
      [ret addObject: c1];
   c1 = [Coord withX:c.X Y:c.Y + 1 Z:c.Z];
   if(![self tileAtCoordBlocksMovement: c1])
      [ret addObject: c1];
   c1 = [Coord withX:c.X Y:c.Y - 1 Z:c.Z];
   if(![self tileAtCoordBlocksMovement: c1])
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
- (void) drawMiniMapForWorldView: (WorldView*) wView 
{
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
- (void) updateWorldView:(WorldView*) wView 
{
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

// FIXME massive code duplication, snip snip
- (void) drawItemsForWorldView: (WorldView*) wView {
	int xInd, yInd;
	CGSize tileSize = [self tileSizeForWorldView:wView];
	int halfTile = (tilesPerSide-1)/2;
	Coord *center = [player creatureLocation];
	CGPoint lowerRight = CGPointMake(center.X + halfTile, center.Y + halfTile);
	CGPoint upperLeft = CGPointMake(center.X-halfTile, center.Y-halfTile);

	NSArray *coords = [items allKeys];
	Coord *coord = [Coord withX: 0 Y: 0 Z: center.Z];

	for (xInd = upperLeft.x; xInd <= lowerRight.x; ++xInd)
	{
		for(yInd = upperLeft.y; yInd <= lowerRight.y; ++yInd)
		{
			if (yInd < 0 || yInd >= MAP_DIMENSION || xInd < 0 || xInd >= MAP_DIMENSION) continue;

			coord.X = xInd;
			coord.Y = yInd;

			if (![coords containsObject: coord]) {
				continue;
			}

			Item *item = nil;

			NSEnumerator *enumerator = [items keyEnumerator];
			Coord *key;
			while ((key = [enumerator nextObject])) {
				if ([key isEqual: coord]) {
					item = [items objectForKey: key];
					break;
				}
			}

			UIImage *img = [UIImage imageNamed: item.icon];
			if (!img) img = [UIImage imageNamed: @"BlackSquare.png"];

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
	UIImage *playerSprite = [UIImage imageNamed:[player iconName]];
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

	[self drawItemsForWorldView:wView];

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
 @method		tileAtCoordBlocksMovement:
 @abstract		query function for whether the tile object blocks movement (blocked by environment, not monsters)
 */
- (BOOL) tileAtCoordBlocksMovement:(Coord*) coord
{
	Tile *t = [currentDungeon tileAt:coord];
	if(t) 
		return t.blockMove;
	else 
		return YES;
}


/*!
 @method		creature:c CanEnterTileAtCoord:
 @abstract		query function for if anything prevents creature entrance to coord (blocked by environment or monsters)
					A creature doesn't block itself.
 */
- (BOOL) creature:(Creature *)c CanEnterTileAtCoord:(Coord*) coord
{
	BOOL blockedBySomething = [self tileAtCoordBlocksMovement: coord];
	if( !blockedBySomething )
		for (Creature *m in liveEnemies) 
			blockedBySomething |= (c != m && [coord equals:[m creatureLocation]] );
	return !blockedBySomething;
}

/*!
 @method		movePlayerToTileAtCoord:
 @abstract	Public function to move any creature. don't call it lightly.  
				This method has no checks, and problems will occur if you aren't sure the tile is OK for movement.
				If you want to see the movement, then call engines updateWorldView after a call to this function.
				Moving creatures is the only thing that changes battle mode, so it is recalculated here
 */
- (void) moveCreature:(Creature *)c ToTileAtCoord:(Coord*)tileCoord
{
	c.creatureLocation = tileCoord;

	if (c == player) {
		// duplicate check.  leave this here, because LVL_GEN_ENV bypasses the original check.
		if ([c.creatureLocation equals: c.selectedMoveTarget]) {
			[self setSelectedMoveTarget:nil ForCreature:c];
		}
		slopeType currSlope = [currentDungeon tileAt: c.creatureLocation].slope;
		if (currSlope) switch (currSlope) {
			case slopeDown:
				c.creatureLocation.Z++;
				break;
			case slopeUp:
				c.creatureLocation.Z--;
				break;
			default:
				c.creatureLocation.Z = 0;
				c.creatureLocation.X = 0;
				c.creatureLocation.Y = 0;
				if (currSlope == slopeToOrc) {
					[currentDungeon initWithType: orcMines];
					break;
				}
				if (currSlope == slopeToTown) {
					[currentDungeon initWithType: town];
					break;
				}
				break;
		}
	}

	[self redetermineBattleMode];
}

/*!
	@method		processTouch
	@abstract	method called when a tile is touched.
					Determines if the touch issues a move command or a different action.
*/
- (void) processTouch:(Coord *)tileCoord {
	BOOL touchMonster = NO;
	for (Creature *m in liveEnemies) {
		if( [tileCoord equals:[m creatureLocation]] ) {
			touchMonster = YES;
			player.selectedCreatureForAction = m;
			break;
		}
	}
	if (touchMonster == YES) {
		// The player has touched a monster.
		// The game should show a menu of actions and be ready for additional user input.
		//     -the menu should be triggered here.
		// After the player has selected the additional input, other code will be called
		// which will allow the character to take its turn.
		[battleMenu show];
	}
	else {
		if (LVL_GEN_ENV) {
			[self moveCreature: player ToTileAtCoord: tileCoord];
		}
		else {
			[self setSelectedMoveTarget:tileCoord ForCreature:player];
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

- (void) ability_handler:(CombatAbility *)action {
	player.selectedCombatAbilityToUse = action;
}

- (void) spell_handler:(Spell *)spell {
	player.selectedSpellToUse = spell;
}

- (void) item_handler:(Item *)item {
	player.selectedItemToUse = item;
}

#pragma mark -
#pragma mark Player Commands

- (void) playerEquipItem:(Item*)i
{
	[player addEquipment:i slot:i.slot];
	
}

- (void) playerUseItem:(Item*)i
{
	if( i == nil ) return;
	if([i cast:player target:player.selectedCreatureForAction] == 0)
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

- (void) setSelectedMoveTarget:(Coord *)loc ForCreature:(Creature *)c
{
	[c.selectedMoveTarget release];
	c.selectedMoveTarget = [loc retain];
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
	[spellMenu hide];
	[itemMenu hide];
}

- (void) showSpellMenu {
	[spellMenu show];
	[attackMenu hide];
	[itemMenu hide];
}

- (void) showItemMenu {
	[itemMenu show];
	[attackMenu hide];
	[spellMenu hide];
}

- (void) showDamageSpellMenu {
	[damageSpellMenu show];
	[conditionSpellMenu hide];
}
- (void) showConditionSpellMenu {
	[conditionSpellMenu show];
	[damageSpellMenu hide];
}
@end
