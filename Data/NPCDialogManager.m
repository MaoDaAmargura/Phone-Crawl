//
//  NPCDialogManager.m
//  Phone-Crawl
//
//  Created by Bucky24 on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NPCDialogManager.h"
#import "Npc.h"


@implementation NPCDialogManager

-(id) initWithView:(UIView *)target andDelegate:(id)del {
	if (self = [super init])
	{
		targetViewRef = target;
		delegate = del;
		current = nil;
		message = nil;
	}
	return self;
}

-(void) beginDialog:(Critter *)c {
	if (!c.npc) return;
	Npc *npc = c.dialog;
	//npc.current = npc.opening;
	[self setDialog:npc.opening];
}

-(void) setDialog:(Dialog *)d {
	message = d;
	initial = [[[UIActionSheet alloc] initWithTitle:d.dialog
										   delegate:self 
								  cancelButtonTitle:nil
							 destructiveButtonTitle:nil
								  otherButtonTitles:nil] autorelease];
	for (Response *r in d.responses) {
		[initial addButtonWithTitle:r.dialog];
	}
	[initial addButtonWithTitle:@"Done"];
	[initial showInView:targetViewRef];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	Response *r = [message.responses objectAtIndex:buttonIndex];
	if (r == nil) return;
	[current.dialog performSelector:r.callfunc];
	[self setDialog:[current.dialog.dialogs objectAtIndex:r.pointsTo]];
}

@end
