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
	current = c;
}

-(void) setDialog:(Dialog *)d {
	message = d;
	initial = [[[UIActionSheet alloc] initWithTitle:d.dialog
										   delegate:self
								  cancelButtonTitle:nil
							 destructiveButtonTitle:nil
								  otherButtonTitles:nil] autorelease];
	int i = 0;
	for (Response *r in d.responses) {
		[initial addButtonWithTitle:r.dialog];
		if ([r.dialog compare:@"Done"] == NSOrderedSame) {
			[initial dismissWithClickedButtonIndex:i animated:NO];
		}
		i++;
	}
	[initial showInView:targetViewRef];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	Response *r = [message.responses objectAtIndex:buttonIndex];
	if ([r.dialog compare:@"Done"] == NSOrderedSame) {
		return;
	}
	if (r == nil) return;
	if (r.callfunc != nil) {
		[current.dialog performSelector:r.callfunc withObject:current];
	}
	Dialog *d = [current.dialog.dialogs objectAtIndex:r.pointsTo];
	[self setDialog:d];
}

@end
