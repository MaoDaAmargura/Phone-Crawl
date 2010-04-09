//
//  NPCDialogManager.m
//  Phone-Crawl
//
//  Created by Bucky24 on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NPCDialogManager.h"
#import "Npc.h"

// implementation for NPCDialogManager
@implementation NPCDialogManager

// initialization functions
-(id) initWithView:(UIView *)target andDelegate:(id)del {
	// initialize an NSObject
	if (self = [super init])
	{
		// save the target ref and the delegate
		targetViewRef = target;
		delegate = del;
		current = nil;
		message = nil;
	}
	// return pointer to self
	return self;
}

// beginDialog
-(void) beginDialog:(Critter *)c {
	// if the critter is not an NPC, then they won't have a dialog set
	if (!c.npc) return;
	// get pointer to critter's NPC data
	Npc *npc = c.dialog;
	// begin conversation
	[self setDialog:npc.opening];
	// store pointer to critter
	current = c;
}

// setDialog
-(void) setDialog:(Dialog *)d {
	// store the dialog pointer
	message = d;
	// initialize the menu
	initial = [[[UIActionSheet alloc] initWithTitle:d.dialog
										   delegate:self
								  cancelButtonTitle:nil
							 destructiveButtonTitle:nil
								  otherButtonTitles:nil] autorelease];
	// need to keep track of position for the dismissWithClickedButtonIndex
	int i = 0;
	// for each response
	for (Response *r in d.responses) {
		// add the response as a button
		[initial addButtonWithTitle:r.dialog];
		// if response title is "Done"
		if ([r.dialog compare:@"Done"] == NSOrderedSame) {
			// tell menu that this button (at position i) should close it
			[initial dismissWithClickedButtonIndex:i animated:NO];
		}
		// increment position
		i++;
	}
	// show menu in main view
	[initial showInView:targetViewRef];
}

// this function is triggered when a button is tapped on the menu
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// find the response at the given index
	Response *r = [message.responses objectAtIndex:buttonIndex];
	// if response is invalid, quit function
	if (r == nil) return;
	// if the name of the response is "Done"
	if ([r.dialog compare:@"Done"] == NSOrderedSame) {
		// menu will close automatically-no need to do more
		return;
	}
	// handle the action
	[current.dialog handle:r.action target:delegate.player];
	// get the next dialog
	Dialog *d = [current.dialog.dialogs objectAtIndex:r.pointsTo];
	// set the current dialog to the next dialog
	[self setDialog:d];
	// call a world refresh
	[delegate updateWorldView];
}

@end
