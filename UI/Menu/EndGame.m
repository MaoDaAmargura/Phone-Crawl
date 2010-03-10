#import "EndGame.h"
#import "Engine.h"
#import "Creature.h"


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
}

- (IBAction) clickEnd {
	// TODO: return to main menu?
}

- (void) update {
	[score setText:[NSString stringWithFormat:@"%d",[engine.player getHighScore]]];
	[cost setText:[NSString stringWithFormat:@"%d",engine.player.level * 100]];
}

@end
