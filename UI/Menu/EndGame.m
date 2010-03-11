#import "EndGame.h"
#import "Engine.h"
#import "Creature.h"

// for the "town" enum
#import "Dungeon.h"

#import "Phone_CrawlAppDelegate.h"


@implementation EndGame

@synthesize engine;

- (id) init {
	if (self = [super initWithNibName:@"EndGame"]) {
		
	}
	return self;
}

- (void) viewDidLoad
{
	[super viewDidLoad];
	[self update];
}

- (IBAction) clickContinue {
	engine.player.money -= engine.player.level * 100;
	//self.navigationController.popViewController(endView);
	// return player to town
	engine.player.current.health = engine.player.max.health;
	engine.player.current.shield = engine.player.max.shield;
	engine.player.current.mana = engine.player.max.mana;
	engine.player.creatureLocation = [Coord withX:0 Y:0 Z:0];
	[engine.currentDungeon initWithType:town];
	[self.view removeFromSuperview];
}

- (IBAction) clickEnd 
{
	Phone_CrawlAppDelegate *appdel = (Phone_CrawlAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appdel endOfPlayersLife];
}

- (void) update {
	[score setText:[NSString stringWithFormat:@"%d",[engine.player getHighScore]]];
	[cost setText:[NSString stringWithFormat:@"%d",engine.player.level * 100]];
}

@end
