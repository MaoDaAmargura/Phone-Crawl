//
//  Npc.m
//  Phone-Crawl
//
//  Created by Bucky24 on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Npc.h"


@implementation Npc

@synthesize dialogs;

-(id) init {
	dialogs = [NSMutableArray arrayWithCapacity:1];
	return self;
}

@end
