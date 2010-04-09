#import "Phone_CrawlAppDelegate.h"

#import "HomeTabViewController.h"
#import "NewGameFlowControl.h"
#import "EndGame.h"

#import "Dungeon.h" // simply for the "town" enum
#import "Critter.h"
#import "Skill.h"
#import "Spell.h"

#import "Engine.h"

#import "HighScoreViewController.h"
#import "HighScoreManager.h"
#import "GameFileManager.h"



#define ALLOWED_TO_LOAD_GAME_KEY	@"ac871013842be92b2b53c294d1c1d48efa51"

#define SAVED_GAME_FILE_NAME	@"phonecrawlsave.gam"

#define QUICK_START NO

@implementation Phone_CrawlAppDelegate

@synthesize window;

@synthesize homeTabController;

@synthesize gameStarted;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    homeTabController = [[[HomeTabViewController alloc] init] autorelease];
	flow = nil;
	
	scoreController = [[HighScoreManager alloc] init];
	gameManager = [[GameFileManager alloc] init];
	
	//return;
	if(QUICK_START) {
		[window addSubview:homeTabController.view];
		gameStarted = YES;
	} else {
		[window insertSubview:homeTabController.view atIndex:0];
		gameStarted = NO;
	}
	
	[Spell initialize];
	[Skill initialize];
	
	NSTimer *timer = [[NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(fireGameLoop) userInfo:nil repeats:YES] retain];
	
	[timer fire];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
	if (gameStarted) 
	{
		printf("saving game\n");
		//[homeTabController.gameEngine saveGame:@"phonecrawlsave.gam"];
		[gameManager saveCharacter:[self playerObject] toFile:SAVED_GAME_FILE_NAME];
	}
}


- (void)dealloc 
{
	[scoreController release];
	[flow release];
    [super dealloc];
}

#pragma mark -
#pragma mark Delegates

/*!
 @method		fireGameLoop
 @abstract		Timer controlled function fired to perform a turn
 @discussion	only enter -[engine gameLoop] if player is alive.
				handle death here.
 */
- (void) fireGameLoop
{
	if (gameStarted)
	{
		if ([homeTabController.gameEngine.player isAlive]) 
		{
			[homeTabController.gameEngine gameLoop];
		}
		else 
		{
			[homeTabController.wView.view addSubview:homeTabController.endView.view];
		}
	}
}

- (void) loadGameWorld
{
	[window bringSubviewToFront:homeTabController.view];
	[homeTabController.gameEngine changeToDungeon:town];
	gameStarted = YES;
}

- (void) newCharacterWithName:(NSString*)name andIcon:(NSString*)icon
{
	[flow.view removeFromSuperview];
	[flow release];
	homeTabController.gameEngine.tutorialMode = YES;
	[homeTabController newCharacterWithName:name andIcon:icon];
	[self loadGameWorld];
}

#pragma mark -
#pragma mark IBActions
/*!
 @method		startNewGame
 @abstract		starts a new game
 @discussion	called from XIB
 */
- (IBAction) startNewGame
{
	flow = [[NewGameFlowControl alloc] init];
	[window addSubview:flow.view];
	flow.delegate = self;
	[flow begin];
}

/*!
 @method		loadSaveGame
 @abstract		loads game from save file
 @discussion	called from XIB
 */
- (IBAction) loadSaveGame
{
	homeTabController.gameEngine.player = [gameManager loadCharacterFromFile:SAVED_GAME_FILE_NAME];
	if(homeTabController.gameEngine.player)
	{
		homeTabController.gameEngine.tutorialMode = NO;
		[self loadGameWorld];
	}
}

/*!
 @method		viewScores
 @abstract		creates a highScoreController to show scores in
 @discussion	called from XIB. always uses same scoreManager.
 */
- (IBAction) viewScores
{
	[hView release];
	hView = [[HighScoreViewController alloc] initWithScoreController:scoreController];
	[window addSubview:hView.view];
}

/*!
 @method		endOfPlayersLife
 @abstract		called when player decides not to continue.
 @discussion	should clear game, disable game modes, and enter player into high scores.
 */
- (void) endOfPlayersLife
{
	gameStarted = NO;
	Critter *player = [homeTabController.gameEngine player];
	[scoreController insertPossibleNewScore:[player score] name:player.stringName];
	[window bringSubviewToFront:mainMenuView];
	
	// delete the save game
	NSFileManager *fm = [NSFileManager defaultManager];
	[fm removeItemAtPath:SAVED_GAME_FILE_NAME error:nil];
}

#pragma mark -
#pragma mark Accessors

- (Critter*) playerObject
{
	return [homeTabController.gameEngine player];
}

- (void) showDungeonLoadingScreen
{
	[homeTabController.wView showDungeonLoading];
}

- (void) hideDungeonLoadingScreen
{
	[homeTabController.wView hideDungeonLoading];
}

- (Engine*) gameEngineObject
{
	return [homeTabController gameEngine];
}

@end

