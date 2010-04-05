



#import "Engine.h"
#import "Tile.h"
#import "Item.h"
#import "Spell.h"
#import "Skill.h"
#import "Util.h"
#import "WorldView.h"
#import "PCParticle.h"

#import "Phone_CrawlAppDelegate.h"
#import "HomeTabViewController.h"

#import "BattleMenuManager.h"
#import "NPCDialogManager.h"

#define GREATEST_ALLOWED_TURN_POINTS 100
#define TURN_POINTS_FOR_MOVEMENT_ACTION 50
#define LARGEST_ALLOWED_PATH 80

#define TELEPORT_ENABLED NO

@interface Engine (UIUpdates)

- (void) updateBackgroundImageForWorldView:(WorldView*)wView;
- (void) updateStatDisplayForWorldView:(WorldView *)wView;
- (void) drawMiniMapForWorldView: (WorldView*) wView;
- (void) drawItemsForWorldView: (WorldView*) wView;
- (void) drawHealthBar:(Critter *)m inWorld:(WorldView*) wView;

@end

@interface Engine (TurnActions)

- (void) calculateCreaturesInBattle;
- (Critter *) nextCreatureToTakeTurn;
- (void) incrementCreatureTurnPointsBy:(int)amount;
- (void) determineActionForCreature:(Critter*)c;
- (void) performMoveActionForCreature:(Critter *)c;
- (void) bloodSprayWithAttacker: (Critter*) attacker;
- (void) processDeathOfCritter:(Critter*) critter;

@end

@interface Engine (Movement)

- (NSMutableArray*) pathBetween:(Coord*) startC and:(Coord*) endC;
- (Tile*) tileWithEstimatedShortestPath:(Coord*) c;
- (NSMutableArray*) getAdjacentNonBlockingTiles:(Coord*) c;
- (Coord*) coordWithShortestEstimatedPathFromArray:(NSMutableArray*) arrOfCoords toDest:(Coord*) dest;
- (NSMutableArray*) buildPathFromEvaluatedDestinationCoord:(Coord *) c;
- (int) manhattanDistanceFromPlayer: (Critter *) m;
- (BOOL) isACreatureAtLocation:(Coord*)loc;

- (void) confirmLevelChange;

@end

@interface Engine (Tutorial)
- (void) tutorialModeSword;
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

@synthesize npcManager;

#pragma mark -
#pragma mark Life Cycle

- (id) init
{
	if(self = [super init])
	{
		tutorialMode = NO;

		liveEnemies = [[NSMutableArray alloc] init];
		deadEnemies = [[NSMutableArray alloc] init];
		tilesPerSide = 11;
		
		self.player = nil;
		self.currentDungeon = [[[Dungeon alloc] init] autorelease];
		currentDungeon.liveEnemies = liveEnemies;
		loadDungeonLock = [NSLock new];		
	}
	return self;
}

- (void) dealloc
{
	[liveEnemies release];
	[deadEnemies release];
	[super dealloc];
	
}

#pragma mark -
#pragma mark Turn Actions

- (void) processDeathOfCritter:(Critter*) critter
{
	[deadEnemies addObject:critter];
	[liveEnemies removeObject:critter];
	float experienceGained = 1.0;
	int levelDifference = player.level - critter.level;
	experienceGained *= pow(1.2, levelDifference);
	[player gainExperience:experienceGained];
	[currentDungeon.items setObject:[Item generateRandomItem:critter.level/5 elemType:FIRE] forKey:critter.location];
}

- (NSString*) performActionForCreature:(Critter*) critter
{
	NSString *actionResult = @"";
	
	if(critter.target.skillToUse)
	{
		actionResult = [critter useSkill];
		if(![actionResult isEqualToString:@"Not in Range!"])
			[self bloodSprayWithAttacker:critter];
	} 
	else if(critter.target.spellToCast)
	{
		actionResult = [critter useSpell];
	}
	else if(critter.target.itemForUse)
	{
		actionResult = [critter useItem];
	}

	if (![critter.target.critterForAction isAlive]) 
	{
		[self processDeathOfCritter:critter.target.critterForAction];
		[critter think:nil];
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
	
	Critter *critter = [self nextCreatureToTakeTurn];
	
	if (critter == player)
	{
		if(!player.inBattle)
			[player regenShield];
	}
	else
	{
		[critter think:player]; 
	}
	
	if ([critter hasActionToTake])
	{
		actionResult = [self performActionForCreature:critter];
	}
	else if ([critter hasMoveToMake])
	{
		[self performMoveActionForCreature:critter];
		if (critter == player)
			[self confirmLevelChange];
	}
	
	if (player.level > oldLevel)
		actionResult = [NSString stringWithFormat:@"%@ %@", actionResult, @"You have gained a level!"];
	
	if(critter == player)
		wView.actionResult.text = actionResult; //Set some result string from actions
	
	[self updateWorldView:wView];
}

- (int) manhattanDistanceFromPlayer: (Critter *) m
{
	return abs(m.location.X - player.location.X)
			+ abs(m.location.Y - player.location.Y);
}

- (void) calculateCreaturesInBattle
{
	BOOL previousBattleMode = player.inBattle;
	
	player.inBattle = NO;
	for (Critter *m in liveEnemies) {
		m.inBattle = ([self manhattanDistanceFromPlayer: m] <= 4) && (m.location.Z == player.location.Z);
		player.inBattle |= m.inBattle;
	}
	
	// entering battle mode zeroes all turn points.
	if(previousBattleMode == NO && player.inBattle == YES)
	{
		player.turnPoints = 0;
		for (Critter *m in liveEnemies)
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
- (Critter *) nextCreatureToTakeTurn
{
	/* This is not how we agreed we were going to do turn points. Is someone changing the system? */
	// changed it again, I think it's more similar to how we discussed it should be. -Eric
	if(!player.inBattle)
		return player;
	
	//get the creature with the most turnPoints (even if it's negative or above 100)
	Critter *greatest = player;
	for (Critter *m in liveEnemies)
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
	for(Critter *m in liveEnemies)
		if(m.inBattle)
			m.turnPoints += amount;
}

- (void) performMoveActionForCreature:(Critter *)c
{
	if (![c.cachedPath count] || ![[c.cachedPath objectAtIndex:0] equals: c.target.moveLocation])
		c.cachedPath = [self pathBetween:c.location and:c.target.moveLocation];

	Coord *next = [c.cachedPath lastObject];
	if ([currentDungeon tileAt: next].smashable) 
	{
		[[currentDungeon tileAt: next] smash];
		[c.cachedPath removeLastObject];
		c.turnPoints -= TURN_POINTS_FOR_MOVEMENT_ACTION;
		return;
	}
	else if ([self canEnterTileAtCoord:next]) 
	{
		[c moveToTarget];
	}
	else 
	{
		//TODO: Can't go there, so...
	}
	
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

	Coord *playerLoc = player.location;
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
	Coord *center = player.location;
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
	Coord *center = player.location;
	
	CGPoint upperLeft = CGPointMake(center.X-halfTile, center.Y-halfTile);
	CGPoint tile = CGPointMake(loc.X - upperLeft.x, loc.Y - upperLeft.y);
	
	[img drawInRect:CGRectMake(tile.x*tileSize.width, tile.y*tileSize.height, tileSize.width, tileSize.height)];
}

- (void) drawHealthBar:(Critter *)m inWorld:(WorldView*) wView
{
	Coord *loc = m.location;
	if(![self coordIsVisible:loc]) return;
	
	CGSize tileSize = [self tileSizeForWorldView:wView];
	int halfTile = (tilesPerSide-1)/2;
	Coord *center = player.location;
	
	CGPoint upperLeft = CGPointMake(center.X-halfTile, center.Y-halfTile);
	CGPoint tile = CGPointMake(loc.X - upperLeft.x, loc.Y - upperLeft.y);
	UIImage *img = [UIImage imageNamed:@"healthred.png"];
	[img drawInRect:CGRectMake(tile.x*tileSize.width, tile.y*tileSize.height-4, tileSize.width, 4)];
	[img drawInRect:CGRectMake(tile.x*tileSize.width, tile.y*tileSize.height, tileSize.width, 4)];
	img = [UIImage imageNamed:@"healthgreen.png"];
	float div = tileSize.width/m.max.hp;
	[img drawInRect:CGRectMake(tile.x*tileSize.width, tile.y*tileSize.height-4, div*m.current.hp, 4)];
	img = [UIImage imageNamed:@"healthgreen.png"];
	div = tileSize.width/m.max.sp;
	[img drawInRect:CGRectMake(tile.x*tileSize.width, tile.y*tileSize.height, div*m.current.sp, 4)];
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
	Coord *center = player.location;
	
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
	[self drawImageNamed:player.stringIcon atTile:player.location inWorld:wView];
}

- (void) drawEnemiesInWorld:(WorldView*) wView
{
	for (Critter *m in liveEnemies) {
		[self drawImageNamed:m.stringIcon atTile:m.location inWorld:wView];
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
	[wView setDisplay:displayStatHealth withAmount:player.current.hp ofMax:player.max.hp];
	[wView setDisplay:displayStatShield withAmount:player.current.sp ofMax:player.max.sp];
	[wView setDisplay:displayStatMana withAmount:player.current.mp ofMax:player.max.mp];
}

- (void) bloodSprayWithAttacker: (Critter*) attacker {
	if (!worldViewSingleton.mapImageView) return;

	Coord *origin = attacker.target.critterForAction.location;
	CGPoint screenCoord = [self originOfTile: origin inWorldView: worldViewSingleton];
	CGSize tileSize = [self tileSizeForWorldView: worldViewSingleton];
	screenCoord = CGPointMake(screenCoord.x + tileSize.width / 2, screenCoord.y + tileSize.height / 2);

	// normalized vectors for the bloody arterial deathspray
	float sprayDeltaX = (float) origin.X - (float) attacker.location.X;
	float sprayDeltaY = (float) origin.Y - (float) attacker.location.Y;
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
	Tile *t = [currentDungeon tileAt:coord];
	if(t)
		return !t.smashable && t.blockMove;
	else 
		return YES;
}

- (Critter*) creatureAtLocation:(Coord*)loc
{
	for (Critter *c in liveEnemies)
		if ([c.location equals:loc])
			return c;
	return nil;
}

- (BOOL) isACreatureAtLocation:(Coord*)loc
{
	for (Critter *c in liveEnemies)
		if ([c.location equals:loc])
			return YES;
	
	return NO;
}

- (BOOL) locationIsOccupied:(Coord*)loc
{
	if ([player.location equals:loc]) 
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

- (void) confirmLevelChange
{
	Tile *t = [currentDungeon tileAt:player.location];
	//TODO: action confirmations
	switch (t.slope) 
	{
		case slopeDown:
			player.location.Z++;
			break;
		case slopeUp:
			player.location.Z--;
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

/*!
	@method		processTouch
	@abstract	method called when a tile is touched.
					Determines if the touch issues a move command or a different action.
*/
- (void) processTouch:(Coord *)tileCoord 
{
	if ([self isACreatureAtLocation:tileCoord]) 
	{
		// The player has touched a monster.
		// The game should show a menu of actions and be ready for additional user input.
		//     -the menu should be triggered here.
		Critter *c = [self creatureAtLocation:tileCoord];
		if (c.npc) {
			
		} else {
			[player think:[self creatureAtLocation:tileCoord]];
			[battleMenuMngr showBattleMenu];
		}
	}
	else 
	{
		if ([tileCoord equals:[player location]]) {
			for (Coord *c in [currentDungeon.items allKeys])
			{
				if([c equals:tileCoord])
				{
					Item *i = [currentDungeon.items objectForKey:c];
					[player gainItem:i];
					[currentDungeon.items removeObjectForKey:c];
					if (tutorialMode)
						[self tutorialModeSword];
				}
			}
		}
		else 
		{
			if (TELEPORT_ENABLED) 
			{
				player.location = tileCoord;
			}
			else 
			{
				[player setMoveTarget:tileCoord];
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
	Coord *center = player.location;
	
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
	Coord *center = player.location;
	CGSize tileSize = [self tileSizeForWorldView:wView];
	int halfTile = (tilesPerSide-1)/2;
	
	CGPoint topleft = CGPointMake(center.X - halfTile, center.Y - halfTile);
	
	return CGPointMake((tileCoord.X-topleft.x)*tileSize.width, (tileCoord.Y-topleft.y)*tileSize.height);
	
}

#pragma mark -
#pragma mark Dungeon Loading 


- (void) changeToDungeon:(levelType)type
{
	if(tutorialMode && type != town)
		[self finishTutorial];
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
	player.location = [currentDungeon.playerStartLocation copy];
	
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
- (void) ability_handler:(Skill *)skill
{
	[player setSkillToUse:skill];
}

- (void) spell_handler:(Spell *)spell 
{
	[player setSpellToUse:spell];
}

- (void) item_handler:(Item *)item 
{
	[player setItemToUse:item];
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

- (void) tutorialModeSword
{
	Phone_CrawlAppDelegate *appDlgt = (Phone_CrawlAppDelegate*) [[UIApplication sharedApplication] delegate];
	[appDlgt.homeTabController continueTutorialFromSword];
}

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
	[player equipItem:i];
	
	if(tutorialMode)
		[self tutorialModeEquippedItem];
}

- (void) playerUseItem:(Item*)i
{
	if( i == nil ) return;
	[player setItemToUse:i];
	[self refreshInventoryScreen];
}

- (void) playerDropItem:(Item*)i
{	
	if (i == nil) return;
	[currentDungeon.items setObject:i forKey:[player location]];
	[player loseItem:i];
	[self refreshInventoryScreen];
}

- (void) buyItem: (Item*) it
{
	int itemVal = [Item getItemValue:it];
	if (player.money >= itemVal)
	{
		[player gainItem:it];
		player.money -= itemVal;
		[self refreshInventoryScreen];
	}
}

- (void) sellItem: (Item*) it
{
	[player loseItem:it];
	int val = [Item getItemValue:it];
	player.money += val >= 10 ? val : 10;
	[self refreshInventoryScreen];
}

#pragma mark -
#pragma mark Custom Accessors

- (NSMutableArray*) getPlayerInventory
{
	return [player inventoryItems];
}

- (EquippedItems) getPlayerEquippedItems
{
	return player.equipment;
}

#pragma mark -
#pragma mark Starting a New Game

- (void) startNewGameWithPlayerName:(NSString*)name andIcon:(NSString*)icon
{
	self.player = [[[Critter alloc] initWithLevel:1] autorelease];
	player.stringName = name;
	player.stringIcon = icon;
}

@end