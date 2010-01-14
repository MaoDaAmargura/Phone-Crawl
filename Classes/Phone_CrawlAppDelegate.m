//
//  Phone_CrawlAppDelegate.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/12/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "Phone_CrawlAppDelegate.h"

#import "HomeTabViewController.h"

@implementation Phone_CrawlAppDelegate

@synthesize window;
@synthesize tabBarController;

@synthesize homeTabController;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    homeTabController = [[[HomeTabViewController alloc] init] autorelease];
    // Add the tab bar controller's current view as a subview of the window
    //[window addSubview:tabBarController.view];
	[window addSubview:homeTabController.view];
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
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

