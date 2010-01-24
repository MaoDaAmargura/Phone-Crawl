//
//  InventoryView.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InventoryView.h"
#import "Item.h"


@implementation InventoryView


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)init
{
    if (self = [super initWithNibName:@"InventoryView"]) 
	{
		drawnItems = [[NSMutableArray alloc] init];
    }
    return self;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[delegate needRefreshForInventoryView:self];
	
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
    [super dealloc];
	
	[drawnItems release];
}


#pragma mark -
#pragma mark Custom
- (void) updateWithItemArray:(NSArray*) items
{
	[drawnItems removeAllObjects];
	int index = 0;
	
	for(Item *i in items)
	{
		//draw items in the right place. too tired for the math now.
		
	}
}

@end
