

#import "SkillUpgradeViewController.h"

#import "Phone_CrawlAppDelegate.h"
#import "UIImage+Overlay.h"

@interface SkillUpgradeViewController (Private)

- (void) updateUI;

@end


@implementation SkillUpgradeViewController

#pragma mark -
#pragma mark Life Cycle

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)init
{
    if (self = [super initWithNibName:@"SkillUpgradeViewController"]) 
	{
        // Custom initialization
		Phone_CrawlAppDelegate *appdlgt = (Phone_CrawlAppDelegate*) [[UIApplication sharedApplication] delegate];
		player = [appdlgt playerObject];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	[subspaceView addSubview:spellView];
	[subspaceView addSubview:abilityView];
	abilityView.hidden = YES;
	[mainSegmentControl setSelectedSegmentIndex:0];
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
    [super dealloc];
}

#pragma mark -
#pragma mark Control

- (void) updateUI
{
	Abilities *playerAbils = [player abilities];
	UIImage *flameIcon = [[UIImage imageNamed:@"bg-fire.png"] overlayedWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"Numeral%d-Normal", playerAbils.spellBook[0]]]];
	[flameSkillButton setImage:flameIcon forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark XIB Interface

- (IBAction) valueChangedForSegmentedControl:(UISegmentedControl*) segCont
{
	switch (segCont.selectedSegmentIndex) 
	{
		case 0:
			abilityView.hidden = YES;
			spellView.hidden = NO;
			break;
		case 1:
			abilityView.hidden = NO;
			spellView.hidden = YES;
			break;
		default:
			//TODO: Error
			break;
	}
}

@end
