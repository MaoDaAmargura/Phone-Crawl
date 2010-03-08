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

#import "Phone_CrawlAppDelegate.h"
#import "HomeTabViewController.h"

#define GREATEST_ALLOWED_TURN_POINTS 100
#define TURN_POINTS_FOR_MOVEMENT_ACTION 50
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
- (void) incrementCreatureTurnPointsBy:(int)amount;
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
- (void) putPlayerAndUpstairs;

@end

@interface Engine (Tutorial)

- (void) finishTutorial;

@end


@implementation Engine

@synthesize player, currentDungeon;
@synthesize battleMenu, attackMenu, itemMenu, spellMenu, damageSpellMenu, conditionSpellMenu;
@synthesize tutorialMode;

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
		tutorialMode = NO;
		
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
		[self hideMenus];
		
		//Both menus will eventually need to be converted to using methods that go through Creature in order to get spell and ability lists from there

		[self putPlayerAndUpstairs];
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
	for (int i = 0 ; i < NUM_PLAYER_COMBAT_ABILITY_TYPES ; ++i) {
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

- (void) putPlayerAndUpstairs {
	// put the player on the top leftmost square that can take him
	for (int delta = 0;; delta++) {
		for (int x = delta; x >= 0; x--) {
			if (![currentDungeon tileAtX: x Y: delta - x Z: 0].blockMove) {
				player.creatureLocation.X = x;
				player.creatureLocation.Y = delta - x;
				player.creatureLocation.Z = 0;
				[[currentDungeon tileAt: player.creatureLocation] initWithTileType: tileStairsToTown];
				return;
			}			
		}
	}
}

- (void) addMenusToWorldView:(WorldView*)wView
{
	[battleMenu showInView:wView.view];
	[spellMenu showInView:wView.view];
	[conditionSpellMenu showInView:wView.view];
	[damageSpellMenu showInView:wView.view];
	[attackMenu showInView:wView.view];
	[itemMenu showInView:wView.view];
	hasAddedMenusToWorldView = YES;
	[self hideMenus];
	
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
			if ([Util point_distanceC1:creature.creatureLocation C2:creature.selectedCreatureForAction.creatureLocation] <= [creature getRange]) {
			//todo: use the combat ability on the target
				actionResult = [creature.selectedCombatAbilityToUse useAbility:creature target:creature.selectedCreatureForAction];
				[self checkIfCreatureIsDead: creature.selectedCreatureForAction];
				creature.turnPoints -= creature.selectedCombatAbilityToUse.turnPointCost;
			} else {
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
	
	if(creature == player) [self hideMenus];
	
	return actionResult;
}

- (void) gameLoopWithWorldView:(WorldView*)wView
{
	if(!hasAddedMenusToWorldView) [self addMenusToWorldView:wView];

	
	NSString *actionResult = @"";
	int oldLevel = player.level;
	Creature *creature = [self nextCreatureToTakeTurn];
	
	if (creature == player)
	{
		if(player.current.health <= 0)
		{
			//TODO: die
		}
		if(!player.inBattle)
			player.current.shield += [Util minValueOfX:player.max.shield*0.05 andY:(player.max.shield-player.current.shield)];
		
		if([player hasActionToTake])
			actionResult = [self performActionForCreature:player]; 
		// Why do we want this? If the player hasn't given any input yet, shouldnt the game freeze until they do?
		//else
		// It was so that idling monsters would take turns whether or not the player did. Gives the world a sense of 
		// real time. - Austin
			//player.turnPoints -= 5;
	}
	else
	{
		[self determineActionForCreature:creature];
		if ([creature hasActionToTake]) 
		{
			actionResult = [self performActionForCreature:creature];
		}
	}
	
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
	
	if( [self manhattanDistanceFromPlayer: c] > 1)
		c.selectedMoveTarget = player.creatureLocation;
	else
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

- (void) loadGame:(NSString *)filename {
	const char *fname = [filename cStringUsingEncoding:NSASCIIStringEncoding];
	FILE *file;
	if (!(file = fopen(fname,"r"))) {
		NSLog([@"Unable to open file for reading: " stringbyAppendingString:filename]);
		return;
	}
	char line[100];
	while (fgets(line,100,file) != NULL) {
		// cut off trailing newline
		if (line[strlen(line)-1] == '\n') {
			line[strlen(line)-1] = '\0';
		}
		printf("%s\n",line);
	}
}

- (void) saveGame:(NSString *)filename {
	const char *fname = [filename cStringUsingEncoding:NSASCIIStringEncoding];
	FILE *file;
	if (!(file = fopen(fname,"w"))) {
		NSLog([@"Unable to open file for writing: " stringByAppendingString:filename]);
		return;
	}
	// name
	// money
	// level
	// experience points
	// head (all equipped follow item template below)
	// chest
	// rhand
	// lhand
	// health
	// shield
	// mana
	// maxhealth
	// maxshield
	// maxmana
	// turnspeed
	// maxturnspeed
	// [abilitiesbegin]
	// id||level
	// ...
	// [spellsbegin]
	// id||level
	// ...
	// [inventorybegin]
	// name||icon||equipable||damage||elementaldamage||range||charges||pointvalue||quality||slot||element||type
	// ||spellid||hp||shield||mana||fire||cold||lightning||poison||dark||armor
	fputs([player.name cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d",player.money] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d",player.experiencePoints] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	[self writeItemToFile:player.equipment.head file:file];
	[self writeItemToFile:player.equipment.chest file:file];
	[self writeItemToFile:player.equipment.rHand file:file];
	[self writeItemToFile:player.equipment.lHand file:file];
	fputs([[NSString stringWithFormat:@"%d",player.current.health] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d",player.current.shield] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d",player.current.mana] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d",player.max.health] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d",player.max.shield] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d",player.max.mana] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d",player.current.turnSpeed] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d",player.max.turnSpeed] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([@"[abilitiesbegin]" cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	for (int i=0; i<NUM_COMBAT_ABILITY_TYPES; i++) {
		int ability = player.abilities.combatAbility[i];
		if (ability != 0) {
			CombatAbility *ca = [abilityList objectAtIndex:i];
			fputs([[NSString stringWithFormat:@"%d",i] cStringUsingEncoding:NSASCIIStringEncoding],file);
			fputs("||",file);
			fputs([[NSString stringWithFormat:@"%d",ability] cStringUsingEncoding:NSASCIIStringEncoding],file);
			fputs("\n",file);
		}
	}
	fputs([@"[spellsbegin]" cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	for (int i=0; i<NUM_PC_SPELL_TYPES; i++) {
		int ability = player.abilities.spellBook[i];
		if (ability != 0) {
			fputs([[NSString stringWithFormat:@"%d",i] cStringUsingEncoding:NSASCIIStringEncoding],file);
			fputs("||",file);
			fputs([[NSString stringWithFormat:@"%d",ability] cStringUsingEncoding:NSASCIIStringEncoding],file);
			fputs("\n",file);
		}
	}
	fputs([@"[inventorybegin]" cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	for (int i=0;i<[player.inventory count];i++) {
		Item *item = [player.inventory objectAtIndex:i];
		[self writeItemToFile:item file:file];
	}
	fclose(file);
}

// name||icon||equipable||damage||elementaldamage||range||charges||pointvalue||quality||slot||element||type
// ||spellid||hp||shield||mana||fire||cold||lightning||poison||dark||armor

- (void) writeItemToFile:(Item *)item file:(FILE *)file {
	//fputs([@"item||" cStringUsingEncoding:NSASCIIStringEncoding],file);
	if (item == nil) {
		fputs([@"null\n" cStringUsingEncoding:NSASCIIStringEncoding],file);
		return;
	}
	fputs([item.name cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([item.icon cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	if (item.isEquipable) {
		fputs([@"YES" cStringUsingEncoding:NSASCIIStringEncoding],file);
		fputs("||",file);
	} else {
		fputs([@"NO" cStringUsingEncoding:NSASCIIStringEncoding],file);
		fputs("||",file);	
	}
	fputs([[NSString stringWithFormat:@"%d",item.damage] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.elementalDamage] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.range] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.charges] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.damage] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.pointValue] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.slot] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.element] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.type] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.effectSpellId] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.hp] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.shield] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.mana] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.fire] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.cold] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.lightning] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.poison] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.dark] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.armor] cStringUsingEncoding:NSASCIIStringEncoding],file);
	
	fputs("\n",file);
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
					[currentDungeon initWithType:orcMines];
					c.creatureLocation = currentDungeon.playerLocation;
					if(tutorialMode) [self finishTutorial];
					[self putPlayerAndUpstairs];
					break;
				case slopeToCrypt:
					[currentDungeon initWithType:crypts];
					[self putPlayerAndUpstairs];
					break;					
				case slopeToTown:
					[currentDungeon initWithType:town];
					[liveEnemies removeAllObjects];
					[deadEnemies removeAllObjects];
					player.creatureLocation.X = player.creatureLocation.Y = player.creatureLocation.Z = 0;
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
		[self showBattleMenu];
	}
	else 
	{
		[self hideMenus];
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

/*!
 These are a hack. Don't do this unless you know what you're doing and you're me. -Austin
 This is terrible practice. Once I have time, I'm going to do this in a better way. 
 */
- (void) refreshInventoryScreen
{
	Phone_CrawlAppDelegate *appDlgt = (Phone_CrawlAppDelegate*) [[UIApplication sharedApplication] delegate];
	[appDlgt.homeTabController refreshInventoryView];
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

- (void) playerEquipItem:(Item*)i
{
	[player addEquipment:i slot:i.slot];
	// The code below will remove items that are equipped from the inventory. But since addEquipment is coded in a
	// way that doesn't allow for getting back the old equipment, we aren't going to do that. -Austin
	//[player.inventory removeObject:i];
	//[self refreshInventoryScreen];
	
	if(tutorialMode)
		[self tutorialModeEquippedItem];
}

- (void) playerUseItem:(Item*)i
{
	if( i == nil ) return;
	if([i cast:player target:player.selectedCreatureForAction] == 0)
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
	
	// TODO: Take this line out, it is only to test save/load
	[self saveGame:@"test.gam"];
	[self loadGame:@"test.gam"];
	
	[currentDungeon initWithType:town];
	

}

@end
