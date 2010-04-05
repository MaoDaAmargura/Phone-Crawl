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
	dialogs = [NSMutableArray arrayWithCapacity:1];
	
	Dialog *d = [[Dialog alloc] initWithDialog:@"Hello"];
	Response *r = [[Response alloc] initWithDialog:@"Heal" pointsTo:1 func:@selector(healPlayer)];
	
	[d addResponse:r];
	
	[dialogs addObject:d];
	
	opening = d;
	current = d;
	return self;
}

-(void) healPlayer {
	
}

@end
