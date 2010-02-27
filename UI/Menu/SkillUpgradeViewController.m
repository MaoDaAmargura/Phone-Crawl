//
//  SkillUpgradeViewController.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 2/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SkillUpgradeViewController.h"


@implementation SkillUpgradeViewController

#pragma mark -
#pragma mark Life Cycle

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)init
{
    if (self = [super initWithNibName:@"SkillUpgradeViewController"]) 
	{
        // Custom initialization
		
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	[subspaceView addSubview:spellView];
	[subspaceView addSubview:abilityView];
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
#pragma mark XIB Interface

- (IBAction) valueChangedForSegmentedControl:(UISegmentedControl*) segCont
{
	switch (segCont.selectedSegmentIndex) 
	{
		case 0:
			[subspaceView bringSubviewToFront:spellView];
			break;
		case 1:
			[subspaceView bringSubviewToFront:abilityView];
			break;
		default:
			//TODO: Error
			break;
	}
}

@end
