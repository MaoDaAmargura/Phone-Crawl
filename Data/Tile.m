//
//  Tile.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Tile.h"

#pragma mark Tile

@implementation Tile

@synthesize blockMove, blockView, type;

- (id) init {
	blockMove = false;
	blockView = false;
	type = tileGrass;
	return self;
}

@end