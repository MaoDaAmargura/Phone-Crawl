#import "Phone_CrawlAppDelegate.h"

#import "HomeTabViewController.h"
#import "NewGameFlowControl.h"

#define QUICK_START NO

@implementation Phone_CrawlAppDelegate

@synthesize window;

@synthesize homeTabController;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	// this is an incredibly hackish workaround to GET PEOPLE TO QUIT STEPPING ON MY TELEPORT.
	// so DON'T TOUCH IT.
	// almost commented this out, just to see Nathan bust a vein -Bucky
	// almost killed bucky, just to see him bleed -Nate
	NSError *error = nil;
	[NSString stringWithContentsOfFile: @"/Users/nathanking/classes/cs115/Phone-Crawl/YES" encoding: NSUTF8StringEncoding error: &error];
	DLog(@"%@", [error description]);
	LVL_GEN_ENV = !error;

    homeTabController = [[[HomeTabViewController alloc] init] autorelease];
	flow = nil;
	
	//return;
	if(QUICK_START || LVL_GEN_ENV)
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

