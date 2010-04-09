//
//  Merchant.m
//  Phone-Crawl
//
//  Created by Bucky24 on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Priest.h"

// implementation for Priest
@implementation Priest

// init functions
-(id) init {
	// create new dialogs array
	dialogs = [[NSMutableArray alloc] initWithCapacity:1];
	
	// create first new dialog (opening dialog)
	Dialog *d = [[Dialog alloc] initWithDialog:@"Hello"];
	// create response to opening dialog
	Response *r = [[Response alloc] initWithDialog:@"Heal me please" pointsTo:1 action:@"Heal"];
	// add response to dialog
	[d addResponse:r];
	// second response, to terminate conversation
	r = [[Response alloc] initWithDialog:@"Done" pointsTo:0 action:@""];
	// add second response
	[d addResponse:r];
	// add object to dialogs array
	[dialogs addObject:d];
	// set opening and current dialog
	opening = d;
	current = d;
	// second dialog, for after player is healed
	d = [[Dialog alloc] initWithDialog:@"You are fully healed."];
	// response to returo start dialog
	r = [[Response alloc] initWithDialog:@"Thanks!" pointsTo:0 action:@""];
	// add response
	[d addResponse:r];
	// add second dialog
	[dialogs addObject:d];
	// return pointer to self
	return self;
}

// heals player when "Heal Me" option is selected
-(void) healPlayer:(Critter *)p {
	// resetStats, which resets hp, mp, and sp to max levels
	[p resetStats];
}

-(void) handle:(NSString *)act target:(Critter *)c {
	if ([act compare:@"Heal"] == NSOrderedSame) {
		[self healPlayer:c];
	}
}

@end
