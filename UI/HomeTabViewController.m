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
#import "Critter.h"

#import "EndGame.h"

#define NUMBER_OF_TABS 4

#define HIGHLIGHT_RED		[UIColor colorWithRed:1 green:0 blue:0 alpha:0.5]
#define HIGHLIGHT_YELLOW	[UIColor colorWithRed:1 green:1 blue:0 alpha:0.5]
#define HIGHLIGHT_GREEN		[UIColor colorWithRed:0 green:1 blue:0 alpha:0.5]

@interface HomeTabViewController (ViewControllers)

- (UIViewController*) initWorldView;
- (UIViewController*) initCharacterView;
- (UIViewController*) initInventoryView;
- (UIViewController*) initOptionsView;

- (void) fireGameLoop;

@end



@implementation HomeTabViewController

@synthesize mainTabController, gameEngine;

@synthesize wView, endView;

#pragma mark -
#pragma mark Life Cycle

-(void) loadView
{
	doneMerchant = NO;
	gotSword = NO;
	
	self.mainTabController = [[[UITabBarController alloc] init] autorelease];
	
	NSMutableArray *tabs = [[[NSMutableArray alloc] initWithCapacity:NUMBER_OF_TABS] autorelease];
	[tabs addObject:[self initWorldView]];
	[tabs addObject:[self initCharacterView]];
	[tabs addObject:[self initInventoryView]];
	[tabs addObject:[self initOptionsView]];
	
	[mainTabController setViewControllers:tabs];
	
	self.view = mainTabController.view;
	mainTabController.delegate = self;
	
	self.gameEngine = [[[Engine alloc] init] autorelease]; 
	
	endView = [[EndGame alloc] init];
	[endView setDelegate:self];
	endView.engine = gameEngine;
	
	merchManager = [[MerchantDialogueManager alloc] initWithView:wView.view andDelegate:gameEngine];
	npcManager = [[NPCDialogManager alloc] initWithView:wView.view andDelegate:gameEngine];
	
	gameEngine.npcManager = npcManager;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	//[gameEngine updateWorldView:wView];
	
	
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
	[endView release];
    [super dealloc];
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
		worldView.highlight.backgroundColor = HIGHLIGHT_YELLOW;
	else 
		worldView.highlight.backgroundColor = HIGHLIGHT_RED;
	
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
	else if([gameEngine.currentDungeon dungeonType] == town && [gameEngine.currentDungeon tileAt:tileCoord].type == tileShopKeeper)
	{
		if(gameEngine.tutorialMode && !doneMerchant)
		{
			[self continueTutorialFromMerchant];
		}
		else if(!gameEngine.tutorialMode)
		{	
			[merchManager interactionWithInventory:[gameEngine getPlayerInventory]];
		}
	}
}

- (void) worldViewDidLoad:(WorldView*) worldView
{
	DLog(@"worldViewDidLoad:(WorldView*) worldView");
	[gameEngine updateWorldView:wView];
}

#pragma mark -
#pragma mark New Tab View Controllers

- (UIViewController*) initWorldView
{
	wView = [[WorldView alloc] init];
	[wView setDelegate: self];
	wView.title = @"World";
	wView.tabBarItem.image = [UIImage imageNamed:@"icon-world.png"];
	return wView;
}

- (UIViewController*) initCharacterView
{
	cView = [[[CharacterView alloc] init] autorelease];
	//
	cView.title = @"Character";
	cView.tabBarItem.image = [UIImage imageNamed:@"icon-character.png"];
	return cView;
}

- (UIViewController*) initInventoryView
{
	iView = [[[InventoryView alloc] init] autorelease];
	//
	iView.title = @"Inventory";
	iView.tabBarItem.image = [UIImage imageNamed:@"icon-inventory.png"];
	return iView;
}

- (UIViewController*) initOptionsView
{
	oView = [[[OptionsView alloc] init] autorelease];
	UINavigationController *navCont = [[[UINavigationController alloc] initWithRootViewController:oView] autorelease];
	//
	navCont.title = @"Options";
	navCont.tabBarItem.image = [UIImage imageNamed:@"icon-options.png"];
	return navCont;
}

#pragma mark -
#pragma mark Delegates

- (void) updateCharacterView
{
	[cView updateWithPlayer:gameEngine.player];
}

- (void) refreshInventoryView
{
	[iView updateWithItemArray:[gameEngine getPlayerInventory]];
}

/*!
 @method		newCharacterWithName
 @abstract		a horrendous hack to write a tutorial over our game engine by limiting player options in this view controller
 */
- (void) newCharacterWithName:(NSString*)name andIcon:(NSString*)icon
{
	[gameEngine startNewGameWithPlayerName:name andIcon:icon];
	gameEngine.tutorialMode = YES;
	
	doneMerchant = NO;
	gotSword = NO;
	equippedSword = NO;
	
	Tile* down = [gameEngine.currentDungeon tileAt:[Coord withX:0 Y:10 Z:0]];
	
	down.blockMove = YES;
	
	tutorialDialogueBox = [[[UILabel alloc] initWithFrame:CGRectMake(15, 15, 290, 80)] autorelease];
	tutorialDialogueBox.backgroundColor = [UIColor whiteColor];
	tutorialDialogueBox.text = @"This is the town of Andor. The fat man in the building is the merchant. Go say hello.";
	tutorialDialogueBox.numberOfLines = 4;
	
	[wView.view addSubview:tutorialDialogueBox];
	
	[self moveHighlightInWorldView:wView toCoord:[Coord withX:3 Y:1 Z:0]];
	wView.highlight.hidden = NO;
	wView.highlight.backgroundColor = HIGHLIGHT_GREEN;
	
}

- (void) continueTutorialFromMerchant
{
	if(gameEngine.tutorialMode)
	{
		tutorialDialogueBox.text = @"Welcome to Andor, kiddo. You got no money, huh? Well, that sword was left here. It's yours. Stand on it and tap it to pick it up.";
		Item *tutorialSword = [[[Item alloc] initWithBaseStats:0 elemType:FIRE itemType:SWORD_ONE_HAND] autorelease];
	
		[gameEngine.currentDungeon.items setObject:tutorialSword forKey:[Coord withX:4 Y:2 Z:0]];
	
		doneMerchant = YES;
	}
}

- (void) continueTutorialFromSword
{
	if(gameEngine.tutorialMode)
	{
		tutorialDialogueBox.text = @"Yeah, that's the spirit. Let's see how you hold it. Open your inventory, tap the sword, and equip it.";
		gotSword = YES;
	}
	
}

- (void) continueTutorialFromSwordEquipped
{
	if(gameEngine.tutorialMode)
	{
		tutorialDialogueBox.text = @"Not bad. Seems to me you've held one before. Listen, why don't you take a walk in the mines? The way should be clear now.";
		equippedSword = YES;
		
		[self moveHighlightInWorldView:wView toCoord:[Coord withX:0 Y:9 Z:0]];
		wView.highlight.backgroundColor = HIGHLIGHT_GREEN;
		wView.highlight.hidden = NO;
		
		Tile* down = [gameEngine.currentDungeon tileAt:[Coord withX:0 Y:10 Z:0]];
		down.blockMove = NO;
	}
}

- (void) finishTutorial
{
	[tutorialDialogueBox removeFromSuperview];
	gameEngine.tutorialMode = NO;
}


#pragma mark -
#pragma mark UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
	return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	if(viewController == iView)
		[self refreshInventoryView];
	if(viewController == cView)
		[self updateCharacterView];
}

@end
