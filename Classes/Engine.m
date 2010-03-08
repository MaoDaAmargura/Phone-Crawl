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

#define GREATEST_ALLOWED_TURN_POINTS 100
#define LARGEST_ALLOWED_PATH 80

@interface Engine (UIUpdates)

- (void) updateBackgroundImageForWorldView:(WorldView*)wView;
- (void) updateStatDisplayForWorldView:(WorldView *)wView;
- (void) drawMiniMapForWorldView: (WorldView*) wView;
- (void) drawItemsForWorldView: (WorldView*) wView;

@end

@interface Engine (TurnActions)

- (void) calculateCreaturesInBattle;
- (Creature *) nextCreatureToTakeTurn;
- (void) incrementCreatureTurnPoints;
- (void) determineActionForCreature:(Creature*)c;
- (void) performMoveActionForCreature:(Creature *)c;
- (void) checkIfCreatureIsDead: (Creature *) c;

@end


@interface Engine (MenuControl)

- (void) hideMenus;
- (void) showBattleMenu;
- (void) showAttackMenu;
- (void) showSpellMenu;
- (void) showItemMenu;
- (void) showDamageSpellMenu;
- (void) showConditionSpellMenu;

@end

@interface Engine (Movement)

- (NSMutableArray*) pathBetween:(Coord*) startC and:(Coord*) endC;
- (Tile*) tileWithEstimatedShortestPath:(Coord*) c;
- (NSMutableArray*) getAdjacentNonBlockingTiles:(Coord*) c;
- (Coord*) coordWithShortestEstimatedPathFromArray:(NSMutableArray*) arrOfCoords toDest:(Coord*) dest;
- (NSMutableArray*) buildPathFromEvaluatedDestinationCoord:(Coord *) c;
- (int) manhattanDistanceFromPlayer: (Creature *) m;
- (BOOL) isACreatureAtLocation:(Coord*)loc;

@end



extern NSMutableDictionary *items; // from Dungeon

@implementation Engine

@synthesize player;
@synthesize battleMenu, attackMenu, itemMenu, spellMenu, damageSpellMenu, conditionSpellMenu;

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
}

- (void) setupBattleMenu
{
	CGPoint origin = CGPointMake(0, 300);
	battleMenu = [[PCPopupMenu alloc] initWithOrigin:origin];
	[battleMenu addMenuItem:@"Attack" delegate:self selector:@selector(showAttackMenu) context:nil];
	[battleMenu addMenuItem:@"Spell" delegate:self selector:@selector(showSpellMenu) context:nil];
	[battleMenu addMenuItem:@"Item" delegate:self selector:@selector(showItemMenu) context: nil];
	battleMenu.hideOnFire = NO;
	[battleMenu hide];
}

- (void) setupAttackMenu
{
	DLog(@"Filling attack menu");
	CGPoint origin = CGPointMake(60, 300);
	attackMenu = [[PCPopupMenu alloc] initWithOrigin:origin];
	[self fillAttackMenuForCreature:player];
	[attackMenu hide];
}

- (void) setupItemMenu
{
	DLog(@"Filling item menu");
	CGPoint origin = CGPointMake(60, 300);
	itemMenu = [[[PCPopupMenu alloc] initWithOrigin:origin] autorelease];
	for (Item* it in player.inventory) 
		if (it.type == WAND || it.type == POTION)
			[itemMenu addMenuItem:it.name delegate:self selector:@selector(item_handler:) context:it];
	[itemMenu hide];
}

- (void) setupSpellMenus
{
	CGPoint origin = CGPointMake(60, 300);
	DLog(@"Filling spell menu");
	spellMenu = [[PCPopupMenu alloc] initWithOrigin:origin];
	[spellMenu addMenuItem:@"Damage" delegate:self selector:@selector(showDamageSpellMenu) context:nil];
	[spellMenu addMenuItem:@"Condition" delegate:self selector:@selector(showConditionSpellMenu) context:nil];
	[spellMenu hide];
	
	damageSpellMenu = [[PCPopupMenu alloc] initWithOrigin:origin];
	[damageSpellMenu hide];
	
	conditionSpellMenu = [[PCPopupMenu alloc] initWithOrigin:origin];
	[conditionSpellMenu hide];	
	
	[self fillSpellMenuForCreature: player];
}

- (id) init
{
	if(self = [super init])
	{
		[Spell fillSpellList];
		[CombatAbility fillAbilityList];
		liveEnemies = [[NSMutableArray alloc] init];
		deadEnemies = [[NSMutableArray alloc] init];
		
		showBattleMenu = NO;
		hasAddedMenusToWorldView = NO;
		// create enemy for battle testing
		//for (int i = 0; i < 3; ++i) {
//			Creature *creature = [[Creature alloc] initMonsterOfType:WARRIOR withElement:FIRE level:20 atX:4 Y:0 Z:0];
//			[creature ClearTurnActions];
//			[liveEnemies addObject:creature];
		//}
		
		tilesPerSide = 11;
		
		[self createDevPlayer];
		[player ClearTurnActions];
		
		//currentDungeon = [[Dungeon alloc] initWithType: town];
		currentDungeon = [Dungeon alloc];
		currentDungeon.liveEnemies = liveEnemies;
		[currentDungeon initWithType: crypts];
		DLog(@"%@",[currentDungeon.playerLocation description]);
		
		player.inBattle = NO;
		selectedMoveTarget = nil;

		[self setupBattleMenu];
		[self setupAttackMenu];
		[self setupItemMenu];
		[self setupSpellMenus];
		//Both menus will eventually need to be converted to using methods that go through Creature in order to get spell and ability lists from there

		// put the player on the top leftmost square that can take him
		for (int delta = 0;; delta++) {
			for (int x = delta; x >= 0; x--) {
				if (![currentDungeon tileAtX: x Y: delta - x Z: 0].blockMove) {
					player.creatureLocation.X = x;
					player.creatureLocation.Y = delta - x;
					player.creatureLocation.Z = 0;
					goto OUTSIDE;
				}			
			}
		}
		OUTSIDE:;

		DLog(@"%@",[player.creatureLocation description]);

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

- (void) addMenusToWorldView:(WorldView*)wView
{
	[battleMenu showInView:wView.view];
	[spellMenu showInView:wView.view];
	[conditionSpellMenu showInView:wView.view];
	[damageSpellMenu showInView:wView.view];
	[attackMenu showInView:wView.view];
	[itemMenu showInView:wView.view];
	hasAddedMenusToWorldView = YES;
	
}

- (void) checkIfCreatureIsDead: (Creature *) c
{
	if(c.current.health <= 0)
	{
		[liveEnemies removeObject:c];
		[deadEnemies addObject:c];
		float experienceGained = 1.0;
		int levelDifference = player.level - c.level;
		experienceGained *= pow(1.2, levelDifference);
		[player gainExperience:experienceGained];
	}
}

- (NSString*) performActionForCreature:(Creature*) creature
{
	NSString *actionResult = @"";
	
	if(creature.selectedCreatureForAction)
	{
		if(creature.selectedCombatAbilityToUse)
		{
			//todo: use the combat ability on the target
			actionResult = [creature.selectedCombatAbilityToUse useAbility:creature target:creature.selectedCreatureForAction];
			[self checkIfCreatureIsDead: creature.selectedCreatureForAction];
			creature.turnPoints -= creature.selectedCombatAbilityToUse.turnPointCost;
			creature.selectedCreatureForAction = nil;
			creature.selectedCombatAbilityToUse = nil;
		}
		else if(creature.selectedSpellToUse)
		{
			//use the spell on the target
			actionResult = [creature.selectedSpellToUse cast:creature target:creature.selectedCreatureForAction];
			[self checkIfCreatureIsDead: creature.selectedCreatureForAction];
			creature.turnPoints -= creature.selectedSpellToUse.turnPointCost;		
			creature.selectedCreatureForAction = nil;
			creature.selectedSpellToUse = nil;
		}
		else if(creature.selectedItemToUse)
		{
			actionResult = [creature.selectedItemToUse cast:creature target:creature.selectedCreatureForAction];
			//DLog(@"Used item, result: %@",actionResult);
			// If charges are used up, drop item from inventory and rebuild item menu
			if (creature.selectedItemToUse.charges <= 0) 
			{
				[creature.inventory removeObject:creature.selectedItemToUse];
				if(creature == player) 
				{
					[itemMenu removeMenuItemNamed:creature.selectedItemToUse.name];
				}
			}
			[self checkIfCreatureIsDead: creature.selectedCreatureForAction];
			//not implemented because the spell of an item is innaccessable
			//creature.turnPoints -= creature.selectedItemToUse.spell.turnPointCost;
			creature.selectedCreatureForAction = nil;
			creature.selectedItemToUse = nil;
		}
	}
	else if(creature.selectedMoveTarget)
	{
		[self performMoveActionForCreature:creature];
	}
	
	return actionResult;
}

- (void) gameLoopWithWorldView:(WorldView*)wView
{
	if(!hasAddedMenusToWorldView) [self addMenusToWorldView:wView];
	
	if (battleMenu.hidden == YES) 
	{
		player.selectedCreatureForAction = nil;
	}
	if (player.selectedCreatureForAction == nil) 
	{
		[self hideMenus];
	}
	
	NSString *actionResult = @"";
	int oldLevel = player.level;
	Creature *creature = [self nextCreatureToTakeTurn];
	
	if (creature == player)
	{
		if(creature.current.health <= 0)
		{
			
		}
		
		if([creature hasActionToTake])
			actionResult = [self performActionForCreature:creature]; 
		// Why do we want this? If the player hasn't given any input yet, shouldnt the game freeze until they do?
		//else
			//player.turnPoints -= 5;
	}
	else //if(creature != nil) //nextCreatureToTakeTurn will always return a creature.
	{
		[self determineActionForCreature:creature];
		if ([creature hasActionToTake]) 
		{
			actionResult = [self performActionForCreature:creature];
		}
	}
	//else
	//{
	//	[self incrementCreatureTurnPoints];		
	//}
	
	if (player.level > oldLevel)
		actionResult = [NSString stringWithFormat:@"%@ %@", actionResult, @"You have gained a level!"];
	
	if(creature == player)
		wView.actionResult.text = actionResult; //Set some result string from actions
	
	[self updateWorldView:wView];
}

- (int) manhattanDistanceFromPlayer: (Creature *) m
{
	return abs(m.creatureLocation.X - player.creatureLocation.X)
			+ abs(m.creatureLocation.Y - player.creatureLocation.Y);
}

- (void) calculateCreaturesInBattle
{
	BOOL previousBattleMode = player.inBattle;
	
	player.inBattle = NO;
	for (Creature *m in liveEnemies) {
		m.inBattle = ([self manhattanDistanceFromPlayer: m] <= 10) && (m.creatureLocation.Z == player.creatureLocation.Z);
		player.inBattle |= m.inBattle;
	}
	
	// prevents turn_points from becoming unruly.
	// entering battle mode zeroes all turn points.
	if(previousBattleMode == NO && player.inBattle == YES)
	{
		player.turnPoints = 0;
		for (Creature *m in liveEnemies)
			m.turnPoints = 0;
	}
}

/*!
	@method		nextCreatureToTakeTurn
	@abstract		ALWAYS returns a creature (any living monster or the player) that will take the next turn.
	@discussion		This method chooses the highest turnPoint creature, normalizes turnpoints, then returns that creature.
						This allows engine to always have 1 creature calculated per turn, no matter the mix of fast or slow creatures.
						turn points can't leave the range of 0-100 because then new monsters that enter the battle later will have grossly different turnpoints						
*/
- (Creature *) nextCreatureToTakeTurn
{
	if(!player.inBattle)
		return player;
	
	//get the creature with the most turnPoints (even if it's negative or above 100)
	Creature *greatest = player;
	for (Creature *m in liveEnemies)
	{
		if (!m.inBattle)
			continue;
		else
			greatest = (greatest.turnPoints >= m.turnPoints ? greatest : m);
	}
	
	// normalize turn points - they should be between 0 and 100
	
	// if the largest # of turn points is negative, then all of the creatures in battle are fucking slow.
	// boost all turn points until it gets to 0
	while( greatest.turnPoints < 0 )
	{	
		DLog(@"Boosting turnpoints, cause the highest is %i", greatest.turnPoints);
		[self incrementCreatureTurnPoints];
	}
	
	// if the largest # of turn points is too big, then all of the creatures in battle are fucking fast
	// let the turnpoints fall to below 100.
	if(greatest.turnPoints < GREATEST_ALLOWED_TURN_POINTS)
		[self incrementCreatureTurnPoints];
	else
		DLog(@"Not incrementing turnpoints because the highest is %i", greatest.turnPoints);
	
	return greatest;
}
	
- (void) incrementCreatureTurnPoints 
{
	if(player.inBattle)
		player.turnPoints += 30;
	for(Creature *m in liveEnemies)
		if(m.inBattle)
			m.turnPoints += 30;
}

- (void) determineActionForCreature:(Creature*)c
{
	assert(c.inBattle);
	
	if( [self manhattanDistanceFromPlayer: c] > 1)
		c.selectedMoveTarget = player.creatureLocation;
	else
	{
		c.selectedCreatureForAction = player;
		c.selectedCombatAbilityToUse = [abilityList objectAtIndex:3]; 
	}
}

#define TURN_POINTS_FOR_MOVEMENT_ACTION 25
- (void) performMoveActionForCreature:(Creature *)c
{
	if (![c.cachedPath count] || ![[c.cachedPath objectAtIndex:0] equals: c.selectedMoveTarget])
		c.cachedPath = [self pathBetween:c.creatureLocation and:c.selectedMoveTarget];

	Coord *next = [[c.cachedPath lastObject] retain];
	if ([currentDungeon tileAt: next].smashable) {
		[[currentDungeon tileAt: next] smash];
		[next release];
		c.turnPoints -= TURN_POINTS_FOR_MOVEMENT_ACTION;
		return;
	}

	[c.cachedPath removeLastObject];
	
	if(![self canEnterTileAtCoord:next])
	{
		//something other than terrain is blocking the path (probably monster)
		//this is not an impossible situation to get into, but I dont know how to handle it nicely.
		//the player probably didnt want to do this anyways.
		NSLog(@"A Creature has tried to run through a monster.");
		c.turnPoints -= TURN_POINTS_FOR_MOVEMENT_ACTION;
		[c ClearTurnActions];
		return;
	}
	
	[self moveCreature:c ToTileAtCoord:next];
	[next release];

	// creature has reached its destination
	if ([c.creatureLocation equals: c.selectedMoveTarget] || player.inBattle)
		c.selectedMoveTarget = nil;

	c.turnPoints -= TURN_POINTS_FOR_MOVEMENT_ACTION;
}



#pragma mark -
#pragma mark Pathing

/*!
	@method		pathBetween:startC and:endC
	@abstract		Runs an A* algorithm to find the next step on an optimal path towards the destination.
						Monsters are not considered.  They do not block the path.
						The last Coord in the returned array is the next step.  The first object is the end point.
	@discussion		This method does not save the path when it's generated.  It definitely should.
						Gets slow (>0.25 seconds) when paths are above 80 tiles or so.
*/
- (NSMutableArray*) pathBetween:(Coord*) startC and:(Coord*) endC
{
	
	if([startC equals:endC])
		return [NSMutableArray arrayWithObject: startC];
	NSMutableArray *discovered = [NSMutableArray arrayWithCapacity:50];
	
	startC.pathing_distance = 0;
	startC.pathing_parentCoord = nil;
	[discovered addObject: (id)startC];
	NSMutableArray *evaluated = [NSMutableArray arrayWithCapacity:50];
	while( [discovered count] != 0 )
	{
		Coord *closest = [self coordWithShortestEstimatedPathFromArray:discovered toDest:endC];
		[evaluated addObject: closest];
		[discovered removeObject: closest];
		NSMutableArray *potentialCoords = [self getAdjacentNonBlockingTiles: closest]; // coord parents must be set with this method.
		for( Coord *discovering in potentialCoords )
		{
			if( [discovering equals:endC] )
				// it's done.  Build a path and return it.
				return [self buildPathFromEvaluatedDestinationCoord: discovering];
			
			if( [evaluated containsObject: discovering] )
				// this coord has been evaluated earlier.  The earlier evaluation must have had a shorter distance, so ignore it now.  
				continue;
			
			discovering.pathing_distance = closest.pathing_distance + 1;
			// FIXME: consult other people and determine if it's ok to crap out when the path is too long
			if(discovering.pathing_distance > LARGEST_ALLOWED_PATH)
			{
				[discovered removeAllObjects];
				break;
			}
			
			if( [discovered containsObject:discovering] ) {
				Coord *previouslyDiscovered = [discovered objectAtIndex:[discovered indexOfObject:discovering]];
				previouslyDiscovered.pathing_distance = (discovering.pathing_distance > previouslyDiscovered.pathing_distance 
															? previouslyDiscovered.pathing_distance : discovering.pathing_distance);
			} else
				[discovered addObject:discovering];
		}
	} 
   // if the code falls out of the while, there is no possible path.  
	return [NSMutableArray arrayWithObject: startC];
}

/*!
	@discussion		simple helper method for the pathfinder.  It just moves some boring code away from the main algorithm.
*/
- (NSMutableArray*) buildPathFromEvaluatedDestinationCoord:(Coord *) c
{
	assert(c.pathing_parentCoord);
	
	NSMutableArray *path = [NSMutableArray arrayWithCapacity:c.pathing_distance];
	while( c.pathing_parentCoord )
	{
		[path addObject: c];
		c = c.pathing_parentCoord;
	}
	return path;
}

/*!
	@method		getAdjacentNonBlockingTiles: c
	@abstract		returns an array of tiles adjacent to argument
						Sets the parent of this tile to the argument
*/
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
		
	for (Coord *temp in ret)
		temp.pathing_parentCoord = c;
   return ret;
}

- (Coord*) coordWithShortestEstimatedPathFromArray:(NSMutableArray*) arrOfCoords toDest:(Coord*) dest
{
   Coord *ret = [arrOfCoords objectAtIndex:0];
   for( Coord *c in arrOfCoords )
   {
      int diffnew = [Util point_distanceC1:c C2:dest];
      int diffold = [Util point_distanceC1:ret C2:dest];
      if( diffnew + c.pathing_distance 
          < diffold + ret.pathing_distance )
         ret = c;
   }
   return ret;
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
	UIImage *pink = [UIImage imageNamed: @"pink-dot.png"];

	Coord *playerLoc = [player creatureLocation];
	Coord *here = [Coord withX: 0 Y: 0 Z: playerLoc.Z];

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

			here.X = x, here.Y = y;
			if ([self isACreatureAtLocation: here]) {
				[pink drawInRect: rect];
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


- (BOOL) coordIsVisible:(Coord*) coord
{
	Coord *center = [player creatureLocation];
	if(coord.Z != center.Z) return NO;
	
	int offScreenDist = (tilesPerSide-1)/2 + 1;
	if(coord.X >= center.X + offScreenDist) return NO;
	if(coord.X <= center.X - offScreenDist) return NO;
	if(coord.Y >= center.Y + offScreenDist) return NO;
	if(coord.Y <= center.Y - offScreenDist) return NO;
	
	return YES;
}

- (void) drawImage:(UIImage*) img atTile:(Coord*) loc inWorld:(WorldView*) wView
{
	if(![self coordIsVisible:loc]) return;
	
	CGSize tileSize = [self tileSizeForWorldView:wView];
	int halfTile = (tilesPerSide-1)/2;
	Coord *center = [player creatureLocation];
	
	CGPoint upperLeft = CGPointMake(center.X-halfTile, center.Y-halfTile);
	CGPoint tile = CGPointMake(loc.X - upperLeft.x, loc.Y - upperLeft.y);
	
	[img drawInRect:CGRectMake(tile.x*tileSize.width, tile.y*tileSize.height, tileSize.width, tileSize.height)];
}

- (void) drawImageNamed:(NSString*) imgName atTile:(Coord*) loc	inWorld:(WorldView*) wView
{
	UIImage *img = [UIImage imageNamed:imgName];
	[self drawImage:img atTile:loc inWorld:wView];
}

/*!
 @method		drawTiles
 @abstract		subroutine to draw tiles to the current graphics context
 */
- (void) drawTilesForWorldView:(WorldView*)wView
{
	int xInd, yInd;
	int halfTile = (tilesPerSide-1)/2;
	Coord *center = [player creatureLocation];
	
	for (xInd = center.X - halfTile; xInd <= center.X + halfTile; ++xInd)
	{
		for(yInd = center.Y - halfTile; yInd <= center.Y + halfTile; ++yInd)
		{
			UIImage *img;
			Coord *loc = [Coord withX:xInd Y:yInd Z:center.Z];
			Tile *t = [currentDungeon tileAtX:xInd Y:yInd Z:center.Z];
			if(t)
				img = [Tile imageForType:t.type]; //Get tile from array by index if it exists
			else
				img = [Tile imageForType:tileNone]; //Black square if the tile doesn't exist
			
			[self drawImage:img atTile:loc inWorld:wView];
		}
	}
}

- (void) drawPlayerInWorld:(WorldView*) wView
{
	[self drawImageNamed:[player iconName] atTile:[player creatureLocation] inWorld:wView];
}

- (void) drawEnemiesInWorld:(WorldView*) wView
{
	for (Creature *m in liveEnemies)
		[self drawImageNamed:[m iconName] atTile:[m creatureLocation] inWorld:wView];
}

- (void) drawItemsInWorld:(WorldView*) wView
{
	for(Coord *c in [items allKeys])
	{
		Item *i = [items objectForKey:c];
		[self drawImageNamed:[i icon]  atTile:c inWorld:wView];
	}
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
	[self drawItemsInWorld:wView];
	[self drawEnemiesInWorld:wView];
	[self drawPlayerInWorld:wView];	
	
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
	if (LVL_GEN_ENV) {
		NSLog([coord description]);
		return false;
	}

	Tile *t = [currentDungeon tileAt:coord];
	if(t) {
		return !t.smashable && t.blockMove;
	}
	else {
		return YES;
	}
}

- (Creature*) creatureAtLocation:(Coord*)loc
{
	for (Creature *c in liveEnemies)
		if ([c.creatureLocation equals:loc])
			return c;
	return nil;
}

- (BOOL) isACreatureAtLocation:(Coord*)loc
{
	for (Creature *c in liveEnemies)
		if ([c.creatureLocation equals:loc])
			return YES;
	
	return NO;
}

- (BOOL) locationIsOccupied:(Coord*)loc
{
	if ([player.creatureLocation equals:loc]) 
		return YES;
	return [self isACreatureAtLocation:loc];
}

/*!
 @method		creature:c CanEnterTileAtCoord:
 @abstract		query function for if anything prevents creature entrance to coord (blocked by environment or monsters)
					A creature doesn't block itself.
 */
- (BOOL) canEnterTileAtCoord:(Coord*) coord
{
	return ![self tileAtCoordBlocksMovement:coord] || [self locationIsOccupied:coord];
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

	if (c == player) 
	{
		// duplicate check.  leave this here, because LVL_GEN_ENV bypasses the original check.
		if ([c.creatureLocation equals: c.selectedMoveTarget]) {
			c.selectedMoveTarget = nil;
		}
		slopeType currSlope = [currentDungeon tileAt: c.creatureLocation].slope;
		if (currSlope) 
		{
			switch (currSlope) 
			{
				case slopeDown:
					c.creatureLocation.Z++;
					break;
				case slopeUp:
					c.creatureLocation.Z--;
					break;
				case slopeToOrc:
					[currentDungeon initWithType:orcMines];
					c.creatureLocation = currentDungeon.playerLocation;
					break;
				case slopeToCrypt:
					[currentDungeon initWithType:crypts];
					c.creatureLocation = currentDungeon.playerLocation;
					break;					
				case slopeToTown:
					[currentDungeon initWithType:town];
					c.creatureLocation = currentDungeon.playerLocation;
					break;
				default:
					break;
			}
		}
	}

	[self calculateCreaturesInBattle];
}

/*!
	@method		processTouch
	@abstract	method called when a tile is touched.
					Determines if the touch issues a move command or a different action.
*/
- (void) processTouch:(Coord *)tileCoord 
{
	player.selectedCreatureForAction = [self creatureAtLocation:tileCoord];
	if (player.selectedCreatureForAction) 
	{
		// The player has touched a monster.
		// The game should show a menu of actions and be ready for additional user input.
		//     -the menu should be triggered here.
		// After the player has selected the additional input, other code will be called
		// which will allow the character to take its turn.
		[battleMenu show];
	}
	else 
	{
		if (LVL_GEN_ENV) 
		{
			[self moveCreature: player ToTileAtCoord: tileCoord];
		}
		else 
		{
			player.selectedMoveTarget = tileCoord;
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

- (void) ability_handler:(CombatAbility *)action 
{
	player.selectedCombatAbilityToUse = action;
}

- (void) spell_handler:(Spell *)spell 
{
	player.selectedSpellToUse = spell;
}

- (void) item_handler:(Item *)item 
{
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

- (NSArray*) getPlayerInventory
{
	return player.inventory;
}

- (EquipSlots*) getPlayerEquippedItems
{
	return player.equipment;
}

#pragma mark -
#pragma mark Menu functions

- (void) hideMenus
{
	[battleMenu hide];
	[attackMenu hide];
	[itemMenu hide];
	[spellMenu hide];
	[damageSpellMenu hide];
	[conditionSpellMenu hide];
}

- (void) showBattleMenu
{
	[self hideMenus];
	[battleMenu show];
}

- (void) showAttackMenu 
{
	[self hideMenus];
	[attackMenu show];
	[battleMenu show];
}

- (void) showSpellMenu 
{
	[self hideMenus];
	[spellMenu show];
	[battleMenu show];
}

- (void) showItemMenu
{
	[self hideMenus];
	[itemMenu show];
	[battleMenu show];
}

- (void) showDamageSpellMenu 
{
	[self hideMenus];
	[damageSpellMenu show];
	[spellMenu show];
	[battleMenu show];
}

- (void) showConditionSpellMenu 
{
	[self hideMenus];
	[conditionSpellMenu show];
	[spellMenu show];
	[battleMenu show];
}


#pragma mark -
#pragma mark Starting a New Game

- (void) startNewGameWithPlayerName:(NSString*)name andIcon:(NSString*)icon
{
	Creature *newPlayer = [Creature newPlayerWithName:name andIcon:icon];
	self.player = newPlayer;
	
	[currentDungeon initWithType:town];
}

@end
