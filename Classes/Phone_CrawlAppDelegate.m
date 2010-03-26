#import "Phone_CrawlAppDelegate.h"

#import "HomeTabViewController.h"
#import "NewGameFlowControl.h"

#import "Dungeon.h" // simply for the "town" enum
#import "Creature.h"

#import "HighScoreViewController.h"
#import "HighScoreManager.h"

#import "GameFileManager.h"

#import "EndGame.h"

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

	isAllowedToLoadGame = [[NSUserDefaults standardUserDefaults] boolForKey:ALLOWED_TO_LOAD_GAME_KEY];
	
	//return;
	if(QUICK_START) {
		[window addSubview:homeTabController.view];
		gameStarted = YES;
	} else {
		[window insertSubview:homeTabController.view atIndex:0];
		gameStarted = NO;
	}
}


- (void)applicationWillTerminate:(UIApplication *)application
{
	if (gameStarted) 
	{
		printf("saving game\n");
		//[homeTabController.gameEngine saveGame:@"phonecrawlsave.gam"];
		[gameManager saveCharacter:[self playerObject] toFile:SAVED_GAME_FILE_NAME];
		isAllowedToLoadGame = YES;
	}
	[[NSUserDefaults standardUserDefaults] setBool:isAllowedToLoadGame forKey:ALLOWED_TO_LOAD_GAME_KEY];
}


- (void)dealloc 
{
	[scoreController release];
	[flow release];
    [super dealloc];
}

#pragma mark -
#pragma mark Delegates

- (void) newCharacterWithName:(NSString*)name andIcon:(NSString*)icon
{
	flow.view.hidden = YES;
	[homeTabController newCharacterWithName:name andIcon:icon];
	[window bringSubviewToFront:homeTabController.view];
}

#pragma mark -
#pragma mark IBActions

- (IBAction) startNewGame
{
	if(!flow)
	{
		flow = [[NewGameFlowControl alloc] init];
		[window addSubview:flow.view];
		flow.delegate = self;
	}
	[window bringSubviewToFront:flow.view];
	[flow begin];
	gameStarted = YES;
	isAllowedToLoadGame = YES;
}

- (IBAction) loadSaveGame
{
	if(!isAllowedToLoadGame) return;
	homeTabController.gameEngine.player = [gameManager loadCharacterFromFile:SAVED_GAME_FILE_NAME];
	if(homeTabController.gameEngine.player)
	{
		[homeTabController.gameEngine.currentDungeon convertToType:town];
		[homeTabController updateCharacterView];
		[window bringSubviewToFront:homeTabController.view];
		gameStarted = YES;
	}

}

- (IBAction) viewScores
{
	[hView release];
	hView = [[HighScoreViewController alloc] initWithScoreController:scoreController];
	[window addSubview:hView.view];
}

- (void) endOfPlayersLife
{
	isAllowedToLoadGame = NO;
	gameStarted = NO;
	Creature *player = [homeTabController.gameEngine player];
	[scoreController insertPossibleNewScore:[player getHighScore] name:[player name]];
	[window bringSubviewToFront:mainMenuView];
}

- (Creature*) playerObject
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

@end

