//
//  Npc.m
//  Phone-Crawl
//
//  Created by Bucky24 on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Npc.h"


@implementation Response

@synthesize dialog;
@synthesize pointsTo;
@synthesize callfunc;

-(id) initWithDialog:(NSString *)d pointsTo:(int)points func:(SEL)func {
	dialog = d;
	pointsTo = points;
	callfunc = func;
	return self;
}

@end

@implementation Dialog

@synthesize dialog;
@synthesize responses;

-(id) initWithDialog:(NSString *)d {
	dialog = d;
	responses = [NSMutableArray arrayWithCapacity:1];
	return self;
}

-(void) addResponse:(Response *)r {
	[responses addObject:r];
}

@end

@implementation Npc

@synthesize dialogs;
@synthesize current;

-(id) initWithCritter:(Critter *)c {
	dialogs = [NSMutableArray arrayWithCapacity:1];
	opening = [[Dialog alloc] initWithDialog:@""];
	current = opening;
	player = c;
	return self;
}

-(void) changeDialog:(Response *)r {
	current = [dialogs objectAtIndex:r.pointsTo];
	[self performSelector:r.callfunc];
}

@end
