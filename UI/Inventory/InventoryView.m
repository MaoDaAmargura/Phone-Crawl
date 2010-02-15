//
//  InventoryView.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InventoryView.h"
#import "Item.h"
#import "InventoryItemButton.h"



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

- (void) viewDidLoad
{
	[super viewDidLoad];
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
	for (InventoryItemButton *b in drawnItems)
		[b removeFromSuperview];
	
	[drawnItems removeAllObjects];
	int index = 0;
	
	CGRect bounds = self.view.bounds;
	
	int numTilesAcross = bounds.size.width/ITEM_BUTTON_SIZE;
	int numTilesDown = bounds.size.height/ITEM_BUTTON_SIZE;
	
	int tileVertSpread = (bounds.size.width - (numTilesAcross * ITEM_BUTTON_SIZE))/(numTilesAcross+1);
	int tileHorizSpread = (bounds.size.height - (numTilesDown * ITEM_BUTTON_SIZE))/(numTilesDown+1);
	
	int row, col, pageIndex;
	
	for(Item *i in items)
	{
		row = index/numTilesAcross;
		col	= index%numTilesAcross;
		pageIndex = 0;
		while(row>numTilesDown)
		{
			row -= numTilesDown;
			pageIndex++;
		}
		
		InventoryItemButton *b = [InventoryItemButton buttonWithItem:i];
		[drawnItems addObject:b];
		
		CGRect r = CGRectMake(tileHorizSpread*(col+1) + ITEM_BUTTON_SIZE * col,
							  bounds.size.width*pageIndex + tileVertSpread*(row+1) + ITEM_BUTTON_SIZE * row,
							  ITEM_BUTTON_SIZE,
							  ITEM_BUTTON_SIZE);
		b.frame = r;
		++index;
		
	}
	
	for (InventoryItemButton *b in drawnItems)
		[self.view addSubview:b];
}

@end
