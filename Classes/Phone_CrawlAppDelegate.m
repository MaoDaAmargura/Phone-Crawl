#import "Phone_CrawlAppDelegate.h"

#import "HomeTabViewController.h"
#import "NewGameFlowControl.h"

#import "Dungeon.h" // simply for the "town" enum
#import "Creature.h"

#import "HighScoreViewController.h"

#import "EndGame.h"

#define QUICK_START NO

#define HIGH_SCORES_DICT_USER_DEFAULTS_KEY	@"ab23682c99f204e57ac73c7500b9f"

@implementation Phone_CrawlAppDelegate

@synthesize window;

@synthesize homeTabController;

@synthesize gameStarted;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	// this is an incredibly hackish workaround to GET PEOPLE TO QUIT STEPPING ON MY TELEPORT.
	// so DON'T TOUCH IT.
	// almost commented this out, just to see Nathan bust a vein -Bucky
	// almost killed bucky, just to see him bleed -Nate
	NSError *error = nil;
	[NSString stringWithContentsOfFile: @"/Users/nathanking/classes/cs115/Phone-Crawl/YES" encoding: NSUTF8StringEncoding error: &error];
//	LVL_GEN_ENV = !error;

    homeTabController = [[[HomeTabViewController alloc] init] autorelease];
	flow = nil;
	
	NSMutableDictionary *scores = [[NSUserDefaults standardUserDefaults] objectForKey:HIGH_SCORES_DICT_USER_DEFAULTS_KEY];
	if(!scores)
	{
		scores = [[NSMutableDictionary alloc] initWithCapacity:6];
		[scores setObject:[NSNumber numberWithInt: 5000] forKey:@"Albeiro Invictus"];
		[scores setObject:[NSNumber numberWithInt: 4000] forKey:@"Warmaster Wijtman"];
		[scores setObject:[NSNumber numberWithInt: 3500] forKey:@"Gangster Forgeman"];
		[scores setObject:[NSNumber numberWithInt: 3000] forKey:@"Mapmaker King"];
		[scores setObject:[NSNumber numberWithInt: 2500] forKey:@"Beastmaster Fultz"];
		[scores setObject:[NSNumber numberWithInt: 2000] forKey:@"Curator Tan"];
		
		[[NSUserDefaults standardUserDefaults] setObject:scores forKey:HIGH_SCORES_DICT_USER_DEFAULTS_KEY];
	}
	//return;
	if(QUICK_START || LVL_GEN_ENV) {
		[window addSubview:homeTabController.view];
		gameStarted = YES;
	} else {
		[window insertSubview:homeTabController.view atIndex:0];
		gameStarted = NO;
	}
}


- (void)applicationWillTerminate:(UIApplication *)application
{
	if (gameStarted) {
		printf("saving game\n");
		[homeTabController.gameEngine saveGame:@"phonecrawlsave.gam"];
	}
}


- (void)dealloc 
{
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
}

- (IBAction) loadSaveGame
{
	[homeTabController.gameEngine loadGame:@"phonecrawlsave.gam"];
	[homeTabController.gameEngine.currentDungeon initWithType:town];
	[window bringSubviewToFront:homeTabController.view];
	
	//[homeTabController.gameEngine saveGame:@"phonecrawlsave.gam"];
}

- (IBAction) viewScores
{
	NSDictionary *scores = [[NSUserDefaults standardUserDefaults] objectForKey:HIGH_SCORES_DICT_USER_DEFAULTS_KEY];
	HighScoreViewController *hView = [[HighScoreViewController alloc] initWithScores:scores];
	[window addSubview:hView.view];
}

- (Creature*) playerObject
{
	return [homeTabController.gameEngine player];
}

- (void) showMainMenu
{
	mainMenuView.hidden = NO;
}

- (void) hideMainMenu
{
	mainMenuView.hidden = YES;
}

@end

