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

- (void) fireGameLoop;

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
	//[gameEngine updateWorldView:wView];
	
	NSTimer *timer = [[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(fireGameLoop) userInfo:nil repeats:YES] retain];
	
	[timer fire];
}

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
#pragma mark Engine Related Calls

//I really should just combine HTVC and Engine

- (void) fireGameLoop
{
	[gameEngine gameLoopWithWorldView:wView];
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
	
	Coord *tileCoord = [gameEngine convertToDungeonCoord:point inWorldView:wView];
	
	if([gameEngine canEnterTileAtCoord:tileCoord])
		worldView.highlight.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.5];
	else 
		worldView.highlight.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
	
	CGPoint p = [gameEngine originOfTile:tileCoord inWorldView:worldView];
	
	CGSize s = [gameEngine tileSizeForWorldView:worldView];
	
	worldView.highlight.frame = CGRectMake(p.x, p.y, s.width, s.height);
	
}

#define PLAYER_INSTANT_TRANSMISSION NO

/*!
 @method		worldSelectedAt
 @abstract		worldView callback for when world gets selected
 @discussion	uses square as final choice for touch. Changes highlighted square
 */
- (void) worldView:(WorldView*) worldView selectedAt:(CGPoint)point {
	
	Coord *tileCoord = [gameEngine convertToDungeonCoord:point inWorldView:worldView];
	
	if([gameEngine canEnterTileAtCoord:tileCoord])
	{
		if(PLAYER_INSTANT_TRANSMISSION)
		{	
			[gameEngine movePlayerToTileAtCoord:tileCoord];
			[gameEngine updateWorldView:worldView];
		}
		else
		{
			[gameEngine setSelectedMoveTarget:tileCoord];
		}

	}
}

- (void) worldViewDidLoad:(WorldView*) worldView
{
	DLog(@"worldViewDidLoad:(WorldView*) worldView");
	[gameEngine updateWorldView:wView];
}


#pragma mark InventoryView
- (void) needRefreshForInventoryView:(InventoryView*) invView
{
	NSArray *inv = [gameEngine getPlayerInventory];
	[invView updateWithItemArray:inv];
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
