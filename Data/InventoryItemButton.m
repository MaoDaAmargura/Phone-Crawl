//
//  InventoryItemButton.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 2/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InventoryItemButton.h"
#import "Item.h"

@implementation InventoryItemButton

@synthesize myItem;

- (id) init
{
	if(self = [super init])
	{
		return self;
	}
	return nil;
}

+ (InventoryItemButton*) buttonWithItem:(Item*)it
{
	InventoryItemButton *ret = [[[InventoryItemButton alloc] init] autorelease];
	ret.myItem = it;
	//TODO: Use Real Image
	[ret setImage:[UIImage imageNamed:@"human1.png"] forState:UIControlStateNormal];
	
	return ret;
}

@end
