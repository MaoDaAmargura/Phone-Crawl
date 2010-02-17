//
//  InventoryView.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InventoryView.h"

#import "InventoryScrollView.h"

#import "Item.h"




@implementation InventoryView


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)init
{
    //if (self = [super initWithNibName:@"InventoryView"]) 
	if (self = [super init])
	{
		sView = [[[InventoryScrollView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)] autorelease];
 		self.view = sView;

    }
    return self;
}


- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)dealloc 
{
    [super dealloc];
	
}

- (void) updateWithItemArray:(NSArray*) items
{
	[sView updateWithItemArray:items];
}


#pragma mark -
#pragma mark UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{

}

@end
