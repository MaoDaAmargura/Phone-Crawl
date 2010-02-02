#import "HomeTabViewController.h"

//Individual View Classes
#import "CharacterView.h"
#import "InventoryView.h"
#import "OptionsView.h"
#import "WorldView.h"

#import "Engine.h"
#import "Util.h"

#define NUMBER_OF_TABS 4

@interface HomeTabViewController (Private)

- (UIViewController*) initWorldView;
- (UIViewController*) initCharacterView;
- (UIViewController*) initInventoryView;
- (UIViewController*) initOptionsView;

@end


@implementation HomeTabViewController

@synthesize mainTabController, gameEngine;


#pragma mark -
#pragma mark Life Cycle

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}*/

-(void) loadView
{
	mainTabController = [[UITabBarController alloc] init];
	
	gameEngine = [[Engine alloc] init];
	
	NSMutableArray *tabs = [[[NSMutableArray alloc] initWithCapacity:NUMBER_OF_TABS] autorelease];
	[tabs addObject:[self initWorldView]];
	[tabs addObject:[self initCharacterView]];
	[tabs addObject:[self initInventoryView]];
	[tabs addObject:[self initOptionsView]];
	
	[mainTabController setViewControllers:tabs];
	
	self.view = mainTabController.view;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	[gameEngine updateWorldView:wView];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Delegate Callbacks

#pragma mark WorldView
/*!
 @method		worldTouchedAt
 @abstract		worldView callback for when world gets touched 
 @discussion	highlights the space the user touched, but allows them to change it.
 user hasn't stopped touching yet
 */
- (void) worldView:(WorldView*) worldView touchedAt:(CGPoint)point
{
	DLog(@"worldView:(WorldView*)wView touchedAt:(CGPoint)point");



//	imageForType


	
//	[UIView beginAnimations:nil context: context];
//	[UIView setAnimationDuration: DROP_ANIM_DURATION];
//	[UIView setAnimationDelegate:self];
//	[UIView setAnimationDidStopSelector:@selector(finishedMoveOut:finished:context:)];
//	
//	CGPoint center = left.view.center;
//	
//	center.x -= 133.5;
//	left.view.center = center;
//	center = right.view.center;
//	center.x -= 133.5;
//	right.view.center = center;
//	
//	[UIView commitAnimations];
}

/*!
 @method		worldSelectedAt
 @abstract		worldView callback for when world gets selected
 @discussion	uses square as final choice for touch. Changes highlighted square
 */
- (void) worldView:(WorldView*) worldView selectedAt:(CGPoint)point
{
	DLog(@"worldView:(WorldView*) wView selectedAt:(CGPoint)point");

}

- (void) worldViewDidLoad:(WorldView*) worldView
{
	DLog(@"worldViewDidLoad:(WorldView*) worldView");
	[gameEngine updateWorldView:wView];
}

/*!
 @method		highlightShouldBeYellowAtPoint:
 @abstract		called by WorldView in response to a touch
 @discussion	returns true (yellow) if Player can move / attack there, false (red) otherwise
 */
- (bool) highlightShouldBeYellowAtPoint: (CGPoint) point {
	float x = floor(point.x / TILE_SIZE_PX);
	float y = floor(point.y / TILE_SIZE_PX);

	CGPoint localCoord = CGPointMake(x,y);
	return [gameEngine validTileAtLocalCoord: localCoord];
}


#pragma mark InventoryView
- (void) needRefreshForInventoryView:(InventoryView*) iView
{
	
}

#pragma mark -
#pragma mark New Tab View Controllers

- (UIViewController*) initWorldView
{
	wView = [[[WorldView alloc] init] autorelease];
	//wView.tabBarItem.image = 
	[wView setDelegate: self];
	wView.title = @"World";
	return wView;
}

- (UIViewController*) initCharacterView
{
	cView = [[[CharacterView alloc] init] autorelease];
	//
	cView.title = @"Character";
	return cView;
}

- (UIViewController*) initInventoryView
{
	iView = [[[InventoryView alloc] init] autorelease];
	//
	iView.title = @"Inventory";
	return iView;
}

- (UIViewController*) initOptionsView
{
	oView = [[[OptionsView alloc] init] autorelease];
	UINavigationController *navCont = [[[UINavigationController alloc] initWithRootViewController:oView] autorelease];
	//
	navCont.title = @"Options";
	return navCont;
}


#pragma mark -
#pragma mark UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	
}


@end
