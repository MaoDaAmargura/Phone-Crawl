#import "Phone_CrawlAppDelegate.h"

#import "HomeTabViewController.h"
#import "NewGameFlowControl.h"

#define QUICK_START NO

@implementation Phone_CrawlAppDelegate

@synthesize window;

@synthesize homeTabController;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    homeTabController = [[[HomeTabViewController alloc] init] autorelease];
	flow = nil;
	
	//return;
	if(QUICK_START)
		[window addSubview:homeTabController.view];
	else 
		[window insertSubview:homeTabController.view atIndex:0];


}


- (void)applicationWillTerminate:(UIApplication *)application
{
	//Save here.
}


- (void)dealloc 
{
	[flow release];
    [super dealloc];
}

- (IBAction) startNewGame
{
	if(!flow)
	{
		flow = [[NewGameFlowControl alloc] init];
		[window addSubview:flow.view];
		flow.delegate = homeTabController.gameEngine;
	}
	[window bringSubviewToFront:flow.view];
	[flow begin];
}

- (IBAction) loadSaveGame
{
	[window bringSubviewToFront:homeTabController.view];
}

- (IBAction) viewScores
{
	
}

@end

