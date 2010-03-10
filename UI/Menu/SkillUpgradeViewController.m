

#import "SkillUpgradeViewController.h"

#import "Phone_CrawlAppDelegate.h"
#import "UIImage+Overlay.h"
#import <QuartzCore/QuartzCore.h>

#import "Util.h"

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
	[self updateUI];
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

- (void) updateButton:(UIButton*)button withBackground:(NSString*)bkg number:(int)num
{
	UIImage *bkgrnd = [UIImage imageNamed:bkg];
	UIImage *lvlImg = [UIImage imageNamed:[NSString stringWithFormat:@"Numeral%d-Normal.png", num]];
	UIImage *icon = [bkgrnd overlayedWithImage:lvlImg];
	[button setImage:icon forState:UIControlStateNormal];
	CALayer *layer = [button layer];
	[layer setMasksToBounds:YES];
	[layer setCornerRadius:10.0];
}

- (void) updateUI
{
	Abilities *playerAbils = [player abilities];
	
	[self updateButton:flameSkillButton withBackground:@"bg-fire.png" number:playerAbils.spellBook[FIREDAMAGE]];
	[self updateButton:frostSkillButton withBackground:@"bg-cold.png" number:playerAbils.spellBook[COLDDAMAGE]];
	[self updateButton:shockSkillButton withBackground:@"bg-lightning.png" number:playerAbils.spellBook[LIGHTNINGDAMAGE]];
	[self updateButton:erodeSkillButton withBackground:@"bg-poison.png" number:playerAbils.spellBook[POISONDAMAGE]];
	[self updateButton:drainSkillButton withBackground:@"bg-dark.png" number:playerAbils.spellBook[DARKDAMAGE]];
	
	[self updateButton:burnSkillButton withBackground:@"bg-fire.png" number:playerAbils.spellBook[FIRECONDITION]];
	[self updateButton:freezeSkillButton withBackground:@"bg-cold.png" number:playerAbils.spellBook[COLDCONDITION]];
	[self updateButton:purgeSkillButton withBackground:@"bg-lightning.png" number:playerAbils.spellBook[LIGHTNINGCONDITION]];
	[self updateButton:poisonSkillButton withBackground:@"bg-poison.png" number:playerAbils.spellBook[POISONCONDITION]];
	[self updateButton:confuseSkillButton withBackground:@"bg-dark.png" number:playerAbils.spellBook[DARKCONDITION]];
	
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
