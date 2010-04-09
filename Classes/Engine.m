//
//  Engine.m
//  Phone-Crawl
//
//  Created by Austin Kelley 
//
//  Flow control class for the entire system. Maintains important game objects like 
//  dungeon singleton and player object, and handles implementation behind most user
//  interaction at some point. 

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

#define GREATEST_ALLOWED_TURN_POINTS 150
#define TURN_POINTS_FOR_MOVEMENT_ACTION 50
#define POINTS_TO_TAKE_TURN		100

#define OUT_OF_RANGE @"Not in Range!"

#define TELEPORT_ENABLED NO

@interface Engine (UIUpdates)

- (void) updateBackgroundImage;
- (void) updateStatDisplay;
- (void) drawMiniMap;
- (void) drawItems;
- (void) drawHealthBarAboveCritter:(Critter *)m;

@end

@interface Engine (TurnActions)

- (BOOL) critter:(Critter*)c1 isInRange:(int)range ofCritter:(Critter*)c2;
- (BOOL) locationIsOccupied:(Coord*)loc;
- (BOOL) canEnterTileAtCoord:(Coord*) coord;
- (void) processDeathOfCritter:(Critter*) critter;
- (void) incrementCritterTurnPoints;
- (Critter*) nextCritterToAct;
- (void) determineBattleModes;
- (NSString*) performActionForCreature:(Critter*) critter;
- (void) performMoveForCreature:(Critter *)c;
- (void) bloodSprayWithAttacker: (Critter*) attacker;

@end

@interface Engine (Movement)

- (BOOL) locationIsOccupied:(Coord*)loc;
- (BOOL) canEnterTileAtCoord:(Coord*) coord;

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

@synthesize worldViewRef;

@synthesize npcManager;

#pragma mark -
#pragma mark Life Cycle

- (id) init
{
	if(self = [super init])
	{
		tutorialMode = NO;
		tilesPerSide = 11;
		oldPlayerLevel = 0;

		self.currentDungeon = [[[Dungeon alloc] init] autorelease];
		loadDungeonLock = [NSLock new];		
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
	
}

- (void) setWorldViewRef:(WorldView *)wView
{
	[worldViewRef release];
	worldViewRef = [wView retain];
	
	[battleMenuMngr release];
	battleMenuMngr = [[BattleMenuManager alloc] initWithTargetView:worldViewRef.view andDelegate:self];
	
	battleMenuMngr.playerRef = player;
}

#pragma mark -
#pragma mark Turn Actions

- (BOOL) critter:(Critter*)c1 isInRange:(int)range ofCritter:(Critter*)c2
{
	return [Util point_distanceC1:c1.location C2:c2.location] < range && c1.location.Z == c2.location.Z;
}

- (BOOL) locationIsOccupied:(Coord*)loc
{
	if ([player.location equals:loc]) 
		return YES;
	return [currentDungeon isACreatureAtLocation:loc];
}


/*!
 @method		creature:c CanEnterTileAtCoord:
 @abstract		query function for if anything prevents creature entrance to coord (blocked by environment or monsters)
 A creature doesn't block itself.
 */
- (BOOL) canEnterTileAtCoord:(Coord*) coord
{
	return ![currentDungeon tileAtCoordBlocksMovement:coord] && ![self locationIsOccupied:coord];
}

/*!
 @method		processDeathOfCritter
 @abstract		It's all in the title
 */
- (void) processDeathOfCritter:(Critter*) critter
{
	if (critter != nil)
	{
		float experienceGained = 1.0;
		int levelDifference = player.level - critter.level;
		experienceGained *= pow(1.2, levelDifference);
		[player gainExperience:experienceGained];
		[currentDungeon.items setObject:[Item generateRandomItem:critter.level/5 elemType:FIRE] forKey:critter.location];
		[currentDungeon.deadEnemies addObject:critter];
		[currentDungeon.liveEnemies removeObject:critter];
	}
}

/*!
 @method		crittersInRange
 @abstract		calculates an array of enemies that are close enough to the player to be allowed to act
 @discussion	uses custom range function in engine for a more radial feel than point distance
 */
- (NSMutableArray*) crittersInRange
{
	NSMutableArray* ret = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
	for (Critter *c in currentDungeon.liveEnemies)
		if ([self critter:c isInRange:4 ofCritter:player])
			[ret addObject:c];
	return ret;
}

- (void) incrementCritterTurnPoints
{
	[player incrementTurnPoints];
	for (Critter *c in [self crittersInRange])
		[c incrementTurnPoints];
}

/*!
 @method		nextCritterToAct
 @abstract		Returns exactly what the name says
 */
- (Critter*) nextCritterToAct
{
	while (YES)
	{
		if (player.turnPoints >= POINTS_TO_TAKE_TURN)
			return player;
	
		for (Critter *c in [self crittersInRange])
			if (c.turnPoints >= POINTS_TO_TAKE_TURN && !c.npc)
				return c;
		
		[self incrementCritterTurnPoints];
	}
}

- (void) determineBattleModes
{
	player.inBattle = NO;
	for (Critter *c in currentDungeon.liveEnemies)
		if ([self critter:c isInRange:5 ofCritter:player])
		{
			c.inBattle = YES;
			player.inBattle = YES;
		}
		else
		{
			c.inBattle = NO;
		}

}

/*!
 @method		performActionForCreature
 @abstract		Well titled method.
 @discussion	will attempt actions in this order:
				1) Skill
				2) Spell
				3) Item
				Checks for death of the target critter (if it exists) at the end
 */
- (NSString*) performActionForCreature:(Critter*) critter
{
	NSString *actionResult = @"";
	
	if(critter.target.skillToUse)
	{
		actionResult = [critter useSkill];
		if(![actionResult isEqualToString:OUT_OF_RANGE])
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

	if (critter.target.critterForAction != nil && ![critter.target.critterForAction isAlive]) 
	{
		[self processDeathOfCritter:critter.target.critterForAction];
		[critter think:nil];
	}
	return actionResult;
}

/*!
 @method		performMoveForCreature
 @abstract		attempts to move the critter along its determined path
 @discussion	if no path has been decided, the critter makes one
				then it attempts to follow the path
				smashable objects are handled here, because Critter doesn't have access to class Dungeon
				movement is handled by Critter functions
				Inability to move costs monsters their turn (but not the player) because monsters
				aren't smart enough to change move targets (infinite loop)
 */
- (void) performMoveForCreature:(Critter *)c
{
	if (![c.cachedPath count] || ![[c.cachedPath objectAtIndex:0] equals: c.target.moveLocation])
		c.cachedPath = [currentDungeon pathBetween:c.location and:c.target.moveLocation];
	
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
		if (c != player) {
			c.turnPoints -= TURN_POINTS_FOR_MOVEMENT_ACTION;
		}
	}
}

/*!
 @method		gameLoopWithWorldView
 @abstract		handle everything that needs to happen during one turn 
 @discussion	sets some important variables that couldn't have been put anywhere smarter
				checks for battle mode for some legacy functions (i.e. shield regen)
				saves state information to check for changes
				requests a critter object to work with and performs its turn
				rechecks state information for updates
 */
- (void) gameLoop
{
	[self determineBattleModes];

	NSString *actionResult = @"";
	
	Critter *critter = [self nextCritterToAct];
	
	if (player.level > oldPlayerLevel && oldPlayerLevel != 0)
	{
		actionResult = @"You gained a level!";
	}
	else
	{
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
	
		if ([critter hasMoveToMake] && ([actionResult isEqualToString:OUT_OF_RANGE] || [actionResult isEqualToString:@""]))
		{
			[self performMoveForCreature:critter];
			if (critter == player)
				[self confirmLevelChange];
			actionResult = @"";
		}
	}
	
	worldViewRef.actionResult.text = actionResult;
	
	oldPlayerLevel = player.level;
	
	[self updateWorldView];
}



#pragma mark -
#pragma mark Graphics

/*!
 @method		drawMiniMap
 @abstract		presents the minimap
 @discussion	does this belong in this class?
 */
- (void) drawMiniMap 
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
			if ([currentDungeon isACreatureAtLocation: here]) {
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

	worldViewRef.miniMapImageView.image = result;
}

/*!
 @method		updateWorldView
 @abstract		main graphics loop for world view. 
 */
- (void) updateWorldView
{
	if (!currentDungeon || currentDungeon.dungeonType == NOT_INITIALIZED)
		return;
	
	if ([loadDungeonLock tryLock])
	{
		[self updateBackgroundImage];
		[self updateStatDisplay];
		[self drawMiniMap];
		[loadDungeonLock unlock];
	}
}

/*!
 @method		coordIsVisible
 @abstract		determines whether a particular world coordinate is visible on the screen that the player can see
 */
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

/*!
 @method		drawImage:atTile:inWorld:
 @abstract		helper routine to place images on tiles
				refactored from code in drawMonsters and drawItems
 */
- (void) drawImage:(UIImage*) img atTile:(Coord*) loc
{
	if(![self coordIsVisible:loc]) return;
	
	CGSize tileSize = [self tileSizeForWorldView];
	int halfTile = (tilesPerSide-1)/2;
	Coord *center = player.location;
	
	CGPoint upperLeft = CGPointMake(center.X-halfTile, center.Y-halfTile);
	CGPoint tile = CGPointMake(loc.X - upperLeft.x, loc.Y - upperLeft.y);
	
	[img drawInRect:CGRectMake(tile.x*tileSize.width, tile.y*tileSize.height, tileSize.width, tileSize.height)];
}

- (void) drawImageNamed:(NSString*) imgName atTile:(Coord*) loc
{
	UIImage *img = [UIImage imageNamed:imgName];
	[self drawImage:img atTile:loc];
}


/*!
 @method		drawHealthBar
 @abstract		draws a critters health bar above it on the worldView
 */
- (void) drawHealthBarAboveCritter:(Critter *)m
{
	Coord *loc = m.location;
	if(![self coordIsVisible:loc]) return;
	
	CGSize tileSize = [self tileSizeForWorldView];
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

/*!
 @method		drawTiles
 @abstract		subroutine to draw tiles to the current graphics context
 */
- (void) drawTiles
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
			
			[self drawImage:img atTile:loc];
		}
	}
}

- (void) drawPlayer
{
	[self drawImageNamed:player.stringIcon atTile:player.location];
}

- (void) drawEnemies
{
	for (Critter *m in currentDungeon.liveEnemies) {
		[self drawImageNamed:m.stringIcon atTile:m.location];
		if (m.npc == NO) {
			[self drawHealthBarAboveCritter:m];
		}
	}
}

- (void) drawItems
{
	NSMutableDictionary *items = currentDungeon.items;
	for(Coord *c in [items allKeys])
	{
		Item *i = [items objectForKey:c];
		[self drawImageNamed:[i icon]  atTile:c];
	}
}

/*!
 @method		updateBackgroundImage
 @abstract		draws background image and player. 
 @discussion	enemies kinda should be done with player. maybe i'll make an extra creature loop.
 */
- (void) updateBackgroundImage
{
	CGRect bounds = worldViewRef.mapImageView.bounds;

	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIGraphicsPushContext(context);
	
	[self drawTiles];
	[self drawItems];
	[self drawEnemies];
	[self drawPlayer];

	UIGraphicsPopContext();

	UIImage* result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	worldViewRef.mapImageView.image = result;
}

/*!
 @method		updateStatDisplay
 @abstract		updates the stat displays based on the players vitals.
 */
- (void) updateStatDisplay
{	
	[worldViewRef setDisplay:displayStatHealth withAmount:player.current.hp ofMax:player.max.hp];
	[worldViewRef setDisplay:displayStatShield withAmount:player.current.sp ofMax:player.max.sp];
	[worldViewRef setDisplay:displayStatMana withAmount:player.current.mp ofMax:player.max.mp];
}

/*!
 @method		bloodSprayWithAttacker
 @abstract		provide visceral visual feedback for melee skill actions
 */
- (void) bloodSprayWithAttacker: (Critter*) attacker 
{
	if (!worldViewRef.mapImageView) return;

	Coord *origin = attacker.target.critterForAction.location;
	CGPoint screenCoord = [self originOfTile: origin];
	CGSize tileSize = [self tileSizeForWorldView];
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
	[worldViewRef.mapImageView addSubview: emitter];
}


#pragma mark -
#pragma mark control


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
	if ([currentDungeon isACreatureAtLocation:tileCoord]) 
	{
		// The player has touched a monster.
		// The game should show a menu of actions and be ready for additional user input.
		//     -the menu should be triggered here.
		Critter *c = [currentDungeon creatureAtLocation:tileCoord];
		if (c.npc) {
			[npcManager beginDialog:c];
		} else {
			[player think:c];
			battleMenuMngr.playerRef = player;
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
- (CGSize) tileSizeForWorldView
{
	CGRect bounds = worldViewRef.mapImageView.bounds;
	int tileWidth = bounds.size.width/tilesPerSide;
	int tileHeight = bounds.size.height/tilesPerSide;
	
	return CGSizeMake(tileWidth, tileHeight);
}

/*!
 @method		convertToDungeonCoord
 @abstract		converts a point in pixels to an absolute dungeon coordinate.
 @discussion	coord returned is the actual location in dungeon that the screen was touched. no locality.
 */
- (Coord*) convertToDungeonCoord:(CGPoint) touch
{
	Coord *center = player.location;
	
	CGSize tileSize = [self tileSizeForWorldView];
	int halfTile = (tilesPerSide-1)/2;
	
	CGPoint topleft = CGPointMake(center.X - halfTile, center.Y - halfTile);
	return [Coord withX:topleft.x + (int)(touch.x/tileSize.width) Y:topleft.y + (int)(touch.y/tileSize.height) Z:center.Z];
	
}

/*!
 @method		originOfTile
 @abstract		returns the pixel point on the screen that is the top left point where the tile at coord should be drawn.
 */
- (CGPoint) originOfTile:(Coord*) tileCoord
{
	Coord *center = player.location;
	CGSize tileSize = [self tileSizeForWorldView];
	int halfTile = (tilesPerSide-1)/2;
	
	CGPoint topleft = CGPointMake(center.X - halfTile, center.Y - halfTile);
	
	return CGPointMake((tileCoord.X-topleft.x)*tileSize.width, (tileCoord.Y-topleft.y)*tileSize.height);
	
}

#pragma mark -
#pragma mark Dungeon Loading 

/*!
 @method		changeToDungeon
 @abstract		thread launched for dungeon changing
 @discussion	locks access to certain parts of the app until dungeon is loaded so that stupid stuff doesn't happen
 */
- (void) changeToDungeon:(levelType)type
{
	if(tutorialMode && type != town)
		[self finishTutorial];
	Phone_CrawlAppDelegate *appDelg = (Phone_CrawlAppDelegate*) [[UIApplication sharedApplication] delegate];
	[appDelg showDungeonLoadingScreen];
	[loadDungeonLock lock];
	[NSThread detachNewThreadSelector:@selector(asynchronouslyLoadDungeon:)
							 toTarget:self
						   withObject:[NSNumber numberWithInt: type]];
	
}

/*!
 @method		successfullyLoadedDungeon
 @abstract		end of thread function that unlocks resource access and redraws screen
 */
- (void) successfullyLoadedDungeon
{
	player.location = [currentDungeon.playerStartLocation copy];
	
	Phone_CrawlAppDelegate *appDelg = (Phone_CrawlAppDelegate*) [[UIApplication sharedApplication] delegate];
	[appDelg hideDungeonLoadingScreen];
	
	[loadDungeonLock unlock];
}

/*!
 @method		asynchronouslyLoadDungeon
 @abstract		function for dungeon loading to be done in a thead
 */
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

- (void) playerDequipItem:(Item*) i
{
	[player dequipItem:i];
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
	if ([player hasItemEquipped:i])
		[player dequipItem:i];
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