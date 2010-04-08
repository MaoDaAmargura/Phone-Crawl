#import "EndGame.h"
#import "Engine.h"
#import "Critter.h"
#import "Util.h"

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
	//self.navigationController.popViewController(endView);
	// return player to town
	[engine.player gainHealth:engine.player.max.hp];
	[engine.player gainMana:engine.player.max.sp];
	engine.player.alive = YES;
	engine.player.deathPenalty += engine.player.level * 100;
	[engine changeToDungeon:town];
	engine.player.location = [Coord withX:6 Y:2 Z:0];
	[self.view removeFromSuperview];
}

- (IBAction) clickEnd 
{
	Phone_CrawlAppDelegate *appdel = (Phone_CrawlAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appdel endOfPlayersLife];
	[self.view removeFromSuperview];
}

- (void) update {
	[score setText:[NSString stringWithFormat:@"%d",[engine.player score]]];
	[cost setText:[NSString stringWithFormat:@"%d",engine.player.level * 100]];
}

@end
