//
//  Phone_CrawlAppDelegate.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/12/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewGameFlowControl.h"

@class Creature;
@class HomeTabViewController;

@interface Phone_CrawlAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, NewGameFlowDelegate> 
{
    UIWindow *window;

	HomeTabViewController *homeTabController;
	NewGameFlowControl *flow;
	BOOL gameStarted;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) HomeTabViewController *homeTabController;

@property BOOL gameStarted;

- (IBAction) startNewGame;
- (IBAction) loadSaveGame;
- (IBAction) viewScores;

- (void) applicationWillTerminate:(UIApplication *)application;

- (Creature*) playerObject;

@end
