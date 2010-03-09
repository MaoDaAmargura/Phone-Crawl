#import "Phone_CrawlAppDelegate.h"

#import "HomeTabViewController.h"
#import "NewGameFlowControl.h"

#import "Dungeon.h" // simply for the "town" enum
#import "Creature.h"

#define QUICK_START NO

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
	LVL_GEN_ENV = !error;

    homeTabController = [[[HomeTabViewController alloc] init] autorelease];
	flow = nil;

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
	
	[homeTabController.gameEngine saveGame:@"phonecrawlsave.gam"];
}

- (IBAction) viewScores
{
	
}

- (Creature*) playerObject
{
	return [homeTabController.gameEngine player];
}

@end

