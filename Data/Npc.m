//
//  Npc.m
//  Phone-Crawl
//
//  Created by Bucky24 on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//	implentation for Npc.h

#import "Npc.h"


// implementation for Response
@implementation Response

// getter and setter methods
@synthesize dialog;
@synthesize pointsTo;
@synthesize action;

// init methods
-(id) initWithDialog:(NSString *)d pointsTo:(int)points action:(NSString *)acts {
	// set basic values then return pointer to self
	dialog = d;
	pointsTo = points;
	action = acts;
	return self;
}

@end

// implementation for Dialog
@implementation Dialog

// getter and setter methods
@synthesize dialog;
@synthesize responses;

// init methods
-(id) initWithDialog:(NSString *)d {
	// store the conversation text and initialize the responses array
	dialog = d;
	responses = [[NSMutableArray alloc] init];
	return self;
}

-(void) addResponse:(Response *)r {
	// add given response to responses array
	[responses addObject:r];
}

@end

// implementation for Dialog
@implementation Npc

// getter and setter methods
@synthesize dialogs;
@synthesize current;
@synthesize opening;

// init methods
-(id) initWithCritter:(Critter *)c {
	// create dialogs array, blank opening dialog (this will be overwritten)
	// then set current array to start dialog and store player pointer
	dialogs = [NSMutableArray arrayWithCapacity:1];
	opening = [[Dialog alloc] initWithDialog:@""];
	current = opening;
	player = c;
	return self;
}

-(void) changeDialog:(Response *)r {
	// update current dialog
	current = [dialogs objectAtIndex:r.pointsTo];
	// perform action if one is designated
	
	[self handle:r.action];
}

-(void) handle:(NSString *)act {

}

@end
