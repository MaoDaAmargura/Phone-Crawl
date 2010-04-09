//
//  Phone_CrawlAppDelegate.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/12/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewGameFlowControl.h"

@class Critter;
@class HomeTabViewController;
@class EndGame;
@class HighScoreManager;
@class GameFileManager;
@class HighScoreViewController;
@class Engine;

@interface Phone_CrawlAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, NewGameFlowDelegate> 
{
    UIWindow *window;

	IBOutlet UIView *mainMenuView;
	HomeTabViewController *homeTabController;
	NewGameFlowControl *flow;
	BOOL gameStarted;
	
	HighScoreManager *scoreController;
	GameFileManager *gameManager;
	
	HighScoreViewController *hView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) HomeTabViewController *homeTabController;

@property BOOL gameStarted;

- (IBAction) startNewGame;
- (IBAction) loadSaveGame;
- (IBAction) viewScores;

- (void) endOfPlayersLife;


- (void) applicationWillTerminate:(UIApplication *)application;

- (Critter*) playerObject;

- (void) showDungeonLoadingScreen;
- (void) hideDungeonLoadingScreen;

- (Engine*) gameEngineObject;

@end
