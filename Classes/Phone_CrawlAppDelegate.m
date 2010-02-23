#import "Phone_CrawlAppDelegate.h"

#import "HomeTabViewController.h"
#import "NewGameFlowControl.h"

@implementation Phone_CrawlAppDelegate

@synthesize window;

@synthesize homeTabController;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    homeTabController = [[[HomeTabViewController alloc] init] autorelease];
	
	[window insertSubview:homeTabController.view atIndex:0];
	flow = nil;
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

