//
//  WorldView.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WorldView.h"

@implementation WorldView

@synthesize mapImageView;


#pragma mark -
#pragma mark Life Cycle

- (id) init
{
	if(self = [super initWithNibName:@"WorldView"])
	{
		return self;
	}
	return nil;
}

- (void) setDelegate:(id<WorldViewDelegate>) idOfDelegate
{
	delegate = idOfDelegate;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	[delegate worldViewDidLoad:self];

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
#pragma mark UIResponder


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
}

@end
