#import "Engine.h"
#import "Dungeon.h"
#import "Creature.h"
#import "Tile.h"
#import "Item.h"
#import "Spell.h"
#import "Util.h"
#import "WorldView.h"
#import "PCPopupMenu.h"
#import "PCParticle.h"
#import "CombatAbility.h"

#import "Phone_CrawlAppDelegate.h"
#import "HomeTabViewController.h"

#import "BattleMenuManager.h"

#define GREATEST_ALLOWED_TURN_POINTS 100
#define TURN_POINTS_FOR_MOVEMENT_ACTION 50
#define LARGEST_ALLOWED_PATH 80

#define TELEPORT_ENABLED NO

@interface Engine (UIUpdates)

- (void) updateBackgroundImageForWorldView:(WorldView*)wView;
- (void) updateStatDisplayForWorldView:(WorldView *)wView;
- (void) drawMiniMapForWorldView: (WorldView*) wView;
- (void) drawItemsForWorldView: (WorldView*) wView;

@end

@interface Engine (TurnActions)

- (void) calculateCreaturesInBattle;
- (Creature *) nextCreatureToTakeTurn;
- (void) incrementCreatureTurnPointsBy:(int)amount;
- (void) determineActionForCreature:(Creature*)c;
- (void) performMoveActionForCreature:(Creature *)c;
- (void) checkIfCreatureIsDead: (Creature *) c;
- (void) bloodSprayWithAttacker: (Creature*) attacker;

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

@interface Engine (Tutorial)

- (void) finishTutorial;

@end

@interface Engine (DungeonLoading)

- (void) changeToDungeon:(levelType)type;
- (void) successfullyLoadedDungeon;
- (void) asynchronouslyLoadDungeon:(NSNumber*)type;

@end

@implementation Engine

@synthesize player, currentDungeon;
@synthesize tutorialMode;

@synthesize worldViewSingleton;

#pragma mark -
#pragma mark Life Cycle

- (id) init
{
	if(self = [super init])
	{
		tutorialMode = NO;
		[PCParticle initialize];

		[Spell fillSpellList];
		[CombatAbility fillAbilityList];
		liveEnemies = [[NSMutableArray alloc] init];
		deadEnemies = [[NSMutableArray alloc] init];

		loadDungeonLock = [NSLock new];
		
		showBattleMenu = NO;
		
		tilesPerSide = 11;
		
		self.player = [[[Creature alloc] initPlayerWithLevel:0] autorelease];
		[player ClearTurnActions];
		
		self.currentDungeon = [[[Dungeon alloc] init] autorelease];
		[self changeToDungeon:town];
		currentDungeon.liveEnemies = liveEnemies;
		
		player.inBattle = NO;
		selectedMoveTarget = nil;
		
	}
	return self;
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
#pragma mark Turn Actions

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
		[currentDungeon.items setObject:[Item generateRandomItem:c.level/5 elemType:FIRE] forKey:c.creatureLocation];
	}
}

- (NSString*) performActionForCreature:(Creature*) creature
{
	NSString *actionResult = @"";
	
	if(creature.selectedCreatureForAction)
	{
		if(creature.selectedCombatAbilityToUse)
		{
			if ([Util point_distanceC1:creature.creatureLocation C2:creature.selectedCreatureForAction.creatureLocation] <= [creature getRange]) {
			//todo: use the combat ability on the target
				actionResult = [creature.selectedCombatAbilityToUse useAbility:creature target:creature.selectedCreatureForAction];
				[self bloodSprayWithAttacker:creature];
				[self checkIfCreatureIsDead: creature.selectedCreatureForAction];
				creature.turnPoints -= creature.selectedCombatAbilityToUse.turnPointCost;
			} else {
				DLog(@"%d > %d",[Util point_distanceC1:creature.creatureLocation C2:creature.selectedCreatureForAction.creatureLocation], [creature getRange]);
				actionResult = @"Out of range!";
			}
			creature.selectedCreatureForAction = nil;
			creature.selectedCombatAbilityToUse = nil;
		}
		else if(creature.selectedSpellToUse)
		{
			
			if ([Util point_distanceC1:creature.creatureLocation C2:creature.selectedCreatureForAction.creatureLocation] <= creature.selectedSpellToUse.range) {
				//use the spell on the target
				actionResult = [creature.selectedSpellToUse cast:creature target:creature.selectedCreatureForAction];
				[self checkIfCreatureIsDead: creature.selectedCreatureForAction];
				creature.turnPoints -= creature.selectedSpellToUse.turnPointCost;
			} else {
				actionResult = @"Out of range!";
			}
			creature.selectedCreatureForAction = nil;
			creature.selectedSpellToUse = nil;
		}
		else if(creature.selectedItemToUse)
		{
			actionResult = [creature.selectedItemToUse cast:creature target:creature.selectedCreatureForAction];
			//DLog(@"Used item, result: %@",actionResult);
			// If charges are used up, drop item from inventory and rebuild item menu
			if (creature.selectedItemToUse.charges <= 0) 
				[creature.inventory removeObject:creature.selectedItemToUse];
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
	if(!worldViewSingleton) worldViewSingleton = wView;
	if (!battleMenuMngr) 
		battleMenuMngr = [[BattleMenuManager alloc] initWithTargetView:wView.view andDelegate:self];
	
	battleMenuMngr.playerRef = player;

	NSString *actionResult = @"";
	int oldLevel = player.level;
	
	//[loadDungeonLock lock];
	Creature *creature = [self nextCreatureToTakeTurn];
	
	if (creature == player)
	{
		if(!player.inBattle)
			player.current.shield += [Util minValueOfX:player.max.shield*0.05 andY:(player.max.shield-player.current.shield)];
		
		if([player hasActionToTake])
			actionResult = [self performActionForCreature:player]; 
			// For monsters to take turns when player is idling
			//player.turnPoints -= 1;
	}
	else
	{
		[self determineActionForCreature:creature];
		if ([creature hasActionToTake]) 
		{
			actionResult = [self performActionForCreature:creature];
		}
	}
	
	//[loadDungeonLock unlock];
	
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
		m.inBattle = ([self manhattanDistanceFromPlayer: m] <= 4) && (m.creatureLocation.Z == player.creatureLocation.Z);
		player.inBattle |= m.inBattle;
	}
	
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
	@discussion		Turn points work a little bit backwards now, but they behave exactly the same as we 
						discussed at the whiteboards a while ago.  The method we discussed increasing everybody's 
						turnpoints until one creature had 100, then that creature took a turn.
						This method works backwards, because it picks the creature that is going to take a turn, 
						then increments everybody's turnpoints by some amount such that the picked monster 
						ends up with 100 turn points.  The behavior is exactly the same, except that we don't 
						have to wait for a creature to reach 100 points - it happens instantly.  This is currently
						not correct for creatures with different turnPoint regen, but it can be if needed.
*/
- (Creature *) nextCreatureToTakeTurn
{
	/* This is not how we agreed we were going to do turn points. Is someone changing the system? */
	// changed it again, I think it's more similar to how we discussed it should be. -Eric
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
	
	// normalize turn points - add whatever amount is neccessary to make the chosen creature have TP of 100
	[self incrementCreatureTurnPointsBy: 100-greatest.turnPoints];

	return greatest;
}
	
- (void) incrementCreatureTurnPointsBy:(int)amount
{
	if(player.inBattle)
		player.turnPoints += amount;
	for(Creature *m in liveEnemies)
		if(m.inBattle)
			m.turnPoints += amount;
}

- (void) determineActionForCreature:(Creature*)c
{
	assert(c.inBattle);
	
	int mnhtnDist = [self manhattanDistanceFromPlayer: c];
	
	if( mnhtnDist > 1 && mnhtnDist < 10)
		c.selectedMoveTarget = player.creatureLocation;
	else if (mnhtnDist == 1)
	{
		c.selectedCreatureForAction = player;
		c.selectedCombatAbilityToUse = [abilityList objectAtIndex:SHITTY_STRIKE]; 
	}
}

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
			// FIXME: adjust this algorithm so that it builds a path TO the end, not FROM the end, so that we can
			// return a partial path immediately below instead of nothing.
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
	if (!currentDungeon || currentDungeon.dungeonType == NOT_INITIALIZED)
		return;
	
	if ([loadDungeonLock tryLock])
	{
		[self updateBackgroundImageForWorldView:wView];
		[self updateStatDisplayForWorldView:wView];
		[self drawMiniMapForWorldView: wView];
		[loadDungeonLock unlock];
	}
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

- (void) drawHealthBar:(Creature *)m inWorld:(WorldView*) wView
{
	Coord *loc = m.creatureLocation;
	if(![self coordIsVisible:loc]) return;
	
	CGSize tileSize = [self tileSizeForWorldView:wView];
	int halfTile = (tilesPerSide-1)/2;
	Coord *center = [player creatureLocation];
	
	CGPoint upperLeft = CGPointMake(center.X-halfTile, center.Y-halfTile);
	CGPoint tile = CGPointMake(loc.X - upperLeft.x, loc.Y - upperLeft.y);
	UIImage *img = [UIImage imageNamed:@"healthred.png"];
	[img drawInRect:CGRectMake(tile.x*tileSize.width, tile.y*tileSize.height-4, tileSize.width, 4)];
	[img drawInRect:CGRectMake(tile.x*tileSize.width, tile.y*tileSize.height, tileSize.width, 4)];
	img = [UIImage imageNamed:@"healthgreen.png"];
	float div = tileSize.width/m.max.health;
	[img drawInRect:CGRectMake(tile.x*tileSize.width, tile.y*tileSize.height-4, div*m.current.health, 4)];
	img = [UIImage imageNamed:@"healthgreen.png"];
	div = tileSize.width/m.max.shield;
	[img drawInRect:CGRectMake(tile.x*tileSize.width, tile.y*tileSize.height, div*m.current.shield, 4)];
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
	for (Creature *m in liveEnemies) {
		[self drawImageNamed:[m iconName] atTile:[m creatureLocation] inWorld:wView];
		[self drawHealthBar:m inWorld:wView];
	}
}

- (void) drawItemsInWorld:(WorldView*) wView
{
	NSMutableDictionary *items = currentDungeon.items;
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

- (void) bloodSprayWithAttacker: (Creature*) attacker {
	if (!worldViewSingleton.mapImageView) return;

	Coord *origin = attacker.selectedCreatureForAction.creatureLocation;
	CGPoint screenCoord = [self originOfTile: origin inWorldView: worldViewSingleton];
	CGSize tileSize = [self tileSizeForWorldView: worldViewSingleton];
	screenCoord = CGPointMake(screenCoord.x + tileSize.width / 2, screenCoord.y + tileSize.height / 2);

	// normalized vectors for the bloody arterial deathspray
	float sprayDeltaX = (float) origin.X - (float) attacker.creatureLocation.X;
	float sprayDeltaY = (float) origin.Y - (float) attacker.creatureLocation.Y;
	float totalDelta = fabs (sprayDeltaY) + fabs (sprayDeltaX);
	float sprayDirectionX = sprayDeltaX / totalDelta;
	float sprayDirectionY = sprayDeltaY / totalDelta;

	CGPoint sprayDirection = CGPointMake (sprayDirectionX, sprayDirectionY);

	PCEmitter *emitter = [PCEmitter startWithX: screenCoord.x Y: screenCoord.y
									 velocityX: 60 velocityY: 60
									 imagePath: @"blood.png"
									  lifeSpan: 1
										  freq: 60
										  bias: sprayDirection];
	[worldViewSingleton.mapImageView addSubview: emitter];
}


#pragma mark -
#pragma mark control

/*!
 @method		tileAtCoordBlocksMovement:
 @abstract		query function for whether the tile object blocks movement (blocked by environment, not monsters)
 */
- (BOOL) tileAtCoordBlocksMovement:(Coord*) coord
{
	//if (LVL_GEN_ENV) {
	//	NSLog(@"%@",[coord description]);
	//	return false;
	//}

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
	return ![self tileAtCoordBlocksMovement:coord] && ![self locationIsOccupied:coord];
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
					[self changeToDungeon:orcMines];
					break;
				case slopeToCrypt:
					[self changeToDungeon:crypts];
					break;					
				case slopeToTown:
					[self changeToDungeon:town];
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

		[battleMenuMngr showBattleMenu];
	}
	else 
	{
		if ([tileCoord equals:[player creatureLocation]]) {
			for (Coord *c in [currentDungeon.items allKeys])
			{
				if([c equals:tileCoord])
				{
					Item *i = [currentDungeon.items objectForKey:c];
					[player.inventory addObject:i];
					[currentDungeon.items removeObjectForKey:c];
				}
			}
		}
		else 
		{
			if (TELEPORT_ENABLED) 
			{
				[self moveCreature: player ToTileAtCoord: tileCoord];
			}
			else 
			{
				player.selectedMoveTarget = tileCoord;
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
#pragma mark Dungeon Loading 


- (void) changeToDungeon:(levelType)type
{
	Phone_CrawlAppDelegate *appDelg = (Phone_CrawlAppDelegate*) [[UIApplication sharedApplication] delegate];
	[liveEnemies removeAllObjects];
	[deadEnemies removeAllObjects];
	[appDelg showDungeonLoadingScreen];
	[loadDungeonLock lock];
	[NSThread detachNewThreadSelector:@selector(asynchronouslyLoadDungeon:)
							 toTarget:self
						   withObject:[NSNumber numberWithInt: type]];
	
}

- (void) successfullyLoadedDungeon
{
	if(tutorialMode) [self finishTutorial];
	player.creatureLocation = [currentDungeon.playerStartLocation copy];
	
	Phone_CrawlAppDelegate *appDelg = (Phone_CrawlAppDelegate*) [[UIApplication sharedApplication] delegate];
	[appDelg hideDungeonLoadingScreen];
	
	[loadDungeonLock unlock];
}

- (void) asynchronouslyLoadDungeon:(NSNumber*)type
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	levelType lvlType = [type intValue];
	[currentDungeon convertToType:lvlType];
	
	[self performSelectorOnMainThread:@selector(successfullyLoadedDungeon) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

#pragma mark -
#pragma mark Action Handlers
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
#pragma mark UI Refresh
/*!
 These are a hack. Don't do this unless you know what you're doing and you're me. -Austin
 This is terrible practice. Once I have time, I'm going to do this in a better way. 
 */
- (void) refreshInventoryScreen
{
	Phone_CrawlAppDelegate *appDlgt = (Phone_CrawlAppDelegate*) [[UIApplication sharedApplication] delegate];
	[appDlgt.homeTabController refreshInventoryView];
}

#pragma mark -
#pragma mark Tutorial

- (void) tutorialModeEquippedItem
{
	Phone_CrawlAppDelegate *appDlgt = (Phone_CrawlAppDelegate*) [[UIApplication sharedApplication] delegate];
	[appDlgt.homeTabController continueTutorialFromSwordEquipped];
}
									  
- (void) finishTutorial
{
	Phone_CrawlAppDelegate *appDlgt = (Phone_CrawlAppDelegate*) [[UIApplication sharedApplication] delegate];
	[appDlgt.homeTabController finishTutorial];
}


#pragma mark -
#pragma mark Player Commands


- (void) playerEquipItem:(Item*)i
{
	[player addEquipment:i slot:i.slot];
	
	if(tutorialMode)
		[self tutorialModeEquippedItem];
}

- (void) playerUseItem:(Item*)i
{
	if( i == nil ) return;
	[i cast:player target:player.selectedCreatureForAction];
	if(i.charges <= 0)
		[player.inventory removeObject:i];
	[self refreshInventoryScreen];
}

- (void) playerDropItem:(Item*)i
{	
	if (i == nil) return;
	[currentDungeon.items setObject:i forKey:[player creatureLocation]];
	[player.inventory removeObject:i];
	[self refreshInventoryScreen];
}

- (void) buyItem: (Item*) it
{
	int itemVal = [Item getItemValue:it];
	if (player.money >= itemVal)
	{
		[player.inventory addObject:it];
		player.money -= itemVal;
		[self refreshInventoryScreen];
	}
}

- (void) sellItem: (Item*) it
{
	[player.inventory removeObject: it];
	int val = [Item getItemValue:it];
	player.money += val >= 10 ? val : 10;
	[self refreshInventoryScreen];
}

#pragma mark -
#pragma mark Custom Accessors

- (NSMutableArray*) getPlayerInventory
{
	return player.inventory;
}

- (EquipSlots*) getPlayerEquippedItems
{
	return player.equipment;
}

#pragma mark -
#pragma mark Starting a New Game

- (void) startNewGameWithPlayerName:(NSString*)name andIcon:(NSString*)icon
{
	self.player = [[[Creature alloc] init] autorelease];
	player.name = name;
	player.iconName = icon;
	
	[currentDungeon convertToType:town];
}

@end
