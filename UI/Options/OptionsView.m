#import "OptionsView.h"

#import "SkillUpgradeViewController.h"


@implementation OptionsView


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)init
{
    if (self = [super initWithNibName:@"OptionsView"]) 
	{
        // Custom initialization
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
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


- (IBAction) launchSkillUpgradeController
{
	SkillUpgradeViewController *sView = [[[SkillUpgradeViewController alloc] init] autorelease];
	//[sview updatewithinfo];
	[self.navigationController pushViewController:sView animated:YES];
}

@end
