//
//  Merchant.m
//  Phone-Crawl
//
//  Created by Bucky24 on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Priest.h"


@implementation Priest

-(id) init {
	dialogs = [[NSMutableArray alloc] initWithCapacity:1];
	
	Dialog *d = [[Dialog alloc] initWithDialog:@"Hello"];
	Response *r = [[Response alloc] initWithDialog:@"Heal" pointsTo:1 func:@selector(healPlayer)];
	
	[d addResponse:r];
	
	r = [[Response alloc] initWithDialog:@"Done" pointsTo:0 func:nil];
	
	[d addResponse:r];
	
	[dialogs addObject:d];
	
	opening = d;
	current = d;
	
	d = [[Dialog alloc] initWithDialog:@"Healing!"];
	r = [[Response alloc] initWithDialog:@"Thanks!" pointsTo:0 func:nil];
	[d addResponse:r];
	
	[dialogs addObject:d];
	return self;
}

-(void) healPlayer {
	
}

@end
