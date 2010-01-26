//
//  Phone_CrawlAppDelegate.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/12/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "Phone_CrawlAppDelegate.h"

#import "HomeTabViewController.h"
#import "MainMenu.h"
#import "CharacterCreation.h"

@implementation Phone_CrawlAppDelegate

@synthesize window;

@synthesize homeTabController;
@synthesize mainMenu;
@synthesize cCreate;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    homeTabController = [[[HomeTabViewController alloc] init] autorelease];
	mainMenu = [[[MainMenu alloc] init] autorelease];
	cCreate = [[[CharacterCreation alloc] init] autorelease];
	[window addSubview:homeTabController.view];
	//[window addSubview:mainMenu.view];
	//[window addSubview:cCreate.view];

}


- (void)applicationWillTerminate:(UIApplication *)application
{
	//Save here.
}

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
    [window release];
    [super dealloc];
}

@end

