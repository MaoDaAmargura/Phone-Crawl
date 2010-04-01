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
	engine.player.deathPenalty += engine.player.level * 100;
	engine.player.location = [Coord withX:0 Y:0 Z:0];
	[engine.currentDungeon convertToType:town];
	[self.view removeFromSuperview];
}

- (IBAction) clickEnd 
{
	Phone_CrawlAppDelegate *appdel = (Phone_CrawlAppDelegate*)[[UIApplication sharedApplication] delegate];
	[appdel endOfPlayersLife];
}

- (void) update {
	[score setText:[NSString stringWithFormat:@"%d",[engine.player score]]];
	[cost setText:[NSString stringWithFormat:@"%d",engine.player.level * 100]];
}

@end
