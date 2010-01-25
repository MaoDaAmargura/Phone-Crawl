//
//  MainMenu.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"


@implementation MainMenu

- (id) init 
{
	if( self = [super initWithNibName:@"MainMenu"])
	{
		
		return self;
	}
	return nil;
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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


@end
