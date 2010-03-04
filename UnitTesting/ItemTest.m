//
//  ItemTest.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ItemTest.h"


@implementation ItemTest

- (void) testInitWithBaseStats
{
	elemType expectedElemType = FIRE;
	itemType expectedItemType = SWORD_ONE_HAND;
	int dungeonLevel = 2;
	
	Item *testItem = [[[Item alloc] initWithBaseStats:dungeonLevel 
											 elemType:expectedElemType 
											 itemType:expectedItemType] autorelease];
	
	STAssertTrue(testItem.element == expectedElemType, @"Item elemental type was different than expected.");
	
	STAssertTrue(testItem.type == expectedItemType, @"Item weapon type was different than expected.");
}

@end
