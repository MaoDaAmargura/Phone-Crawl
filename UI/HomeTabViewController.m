#import "HomeTabViewController.h"

//Individual View Classes

#import "CharacterView.h"
#import "InventoryView.h"
#import "OptionsView.h"
#import "WorldView.h"

#import "Engine.h"
#import "Util.h"

#import "Dungeon.h"
#import "Tile.h"
#import "Item.h"

#define NUMBER_OF_TABS 4

@interface HomeTabViewController (ViewControllers)

- (UIViewController*) initWorldView;
- (UIViewController*) initCharacterView;
- (UIViewController*) initInventoryView;
- (UIViewController*) initOptionsView;

- (void) fireGameLoop;

@end

@interface HomeTabViewController (Tutorial)

- (void) continueTutorialFromMerchant;

@end



@implementation HomeTabViewController

@synthesize mainTabController, gameEngine;


#pragma mark -
#pragma mark Life Cycle

-(void) loadView
{
	tutorialMode = NO;
	checkOutOptions = NO;
	checkOutCharacter = NO;
	checkOutInventory = NO;
	backToWorld = NO;
	
	mainTabController = [[UITabBarController alloc] init];
	
	NSMutableArray *tabs = [[[NSMutableArray alloc] initWithCapacity:NUMBER_OF_TABS] autorelease];
	[tabs addObject:[self initWorldView]];
	[tabs addObject:[self initCharacterView]];
	[tabs addObject:[self initInventoryView]];
	[tabs addObject:[self initOptionsView]];
	
	[mainTabController setViewControllers:tabs];
	
	self.view = mainTabController.view;
	mainTabController.delegate = self;
	
	gameEngine = [[Engine alloc] init];
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	//[gameEngine updateWorldView:wView];
	
	NSTimer *timer = [[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(fireGameLoop) userInfo:nil repeats:YES] retain];
	
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

- (void) moveHighlightInWorldView:(WorldView*)worldView toCoord:(Coord*) loc
{
	CGPoint p = [gameEngine originOfTile:loc inWorldView:worldView];
	
	CGSize s = [gameEngine tileSizeForWorldView:worldView];
	
	worldView.highlight.frame = CGRectMake(p.x, p.y, s.width, s.height);
	
}
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
	
	if(![gameEngine tileAtCoordBlocksMovement:tileCoord])
		worldView.highlight.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.5];
	else 
		worldView.highlight.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
	
	[self moveHighlightInWorldView:wView toCoord:tileCoord];
	
}

/*!
 @method		worldSelectedAt
 @abstract		worldView callback for when world gets selected
 @discussion	uses square as final choice for touch. Changes highlighted square
 */
- (void) worldView:(WorldView*) worldView selectedAt:(CGPoint)point 
{
	Coord *tileCoord = [gameEngine convertToDungeonCoord:point inWorldView:worldView];
	
	if(![gameEngine tileAtCoordBlocksMovement:tileCoord])
	{
		[gameEngine processTouch:tileCoord];
		[gameEngine updateWorldView:worldView];
	}
	
	if([gameEngine.currentDungeon dungeonType] == town)
	{
		if([gameEngine.currentDungeon tileAt:tileCoord].type == tileShopKeeper)
		{
			if(tutorialMode)
			{
				[self continueTutorialFromMerchant];
			}
			else
			{
				
			}

		}
	}
}

- (void) worldViewDidLoad:(WorldView*) worldView
{
	DLog(@"worldViewDidLoad:(WorldView*) worldView");
	[gameEngine updateWorldView:wView];
}

- (void) refreshInventoryView
{
	[iView updateWithItemArray:[gameEngine getPlayerInventory]];
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
#pragma mark Delegates
/*!
 @method		newCharacterWithName
 @abstract		a horrendous hack to write a tutorial over our game engine by limiting player options in this view controller
 */
- (void) newCharacterWithName:(NSString*)name andIcon:(NSString*)icon
{
	[gameEngine startNewGameWithPlayerName:name andIcon:icon];
	tutorialMode = YES;
	
	Tile* down = [gameEngine.currentDungeon tileAt:[Coord withX:0 Y:5 Z:0]];
	
	tileType oldtype = [down type];
	[down setType:tileWoodDoorBroken]; //disallow moving down for now
	
	tutorialDialogueBox = [[[UILabel alloc] initWithFrame:CGRectMake(15, 15, 290, 80)] autorelease];
	tutorialDialogueBox.backgroundColor = [UIColor whiteColor];
	tutorialDialogueBox.text = @"This is the town of Andor. The fat man in the building is the merchant. Go say hello.";
	tutorialDialogueBox.numberOfLines = 4;
	
	[wView.view addSubview:tutorialDialogueBox];
	
	[self moveHighlightInWorldView:wView toCoord:[Coord withX:3 Y:1 Z:0]];
	wView.highlight.hidden = NO;
	wView.highlight.backgroundColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.5];
	
}

- (void) continueTutorialFromMerchant
{
	tutorialDialogueBox.text = @"Welcome to Andor, kiddo. You got no money, huh? Well, that sword was left here. It's yours. Stand on it and tap it to pick it up.";
	Item *tutorialSword = [[[Item alloc] initWithBaseStats:0 elemType:FIRE itemType:SWORD_ONE_HAND] autorelease];
	
	[gameEngine.currentDungeon.items setObject:tutorialSword forKey:[Coord withX:4 Y:2 Z:0]];
	
	
}

#pragma mark -
#pragma mark UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	if (tutorialMode)
	{
		if(viewController == oView) return checkOutOptions;
		if(viewController == cView) return checkOutCharacter;
		if(viewController == iView) return checkOutInventory;
		if(viewController == wView) return backToWorld;
		return NO;
	}
	return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	if(viewController == iView)
		[self refreshInventoryView];
	if(viewController == cView)
		[cView updateWithEquippedItems:[gameEngine getPlayerEquippedItems]];
}

@end
