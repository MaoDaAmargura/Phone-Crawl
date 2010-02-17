//
//  InventoryItemButton.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 2/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InventoryItemButton.h"
#import "Item.h"

#import "PCPopupMenu.h"



@implementation InventoryItemButton

@synthesize myItem, itemImage, delegate;

- (id) init
{
	if(self = [super init])
	{
		self.itemImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ITEM_BUTTON_SIZE, ITEM_BUTTON_SIZE)] autorelease];
		[self addSubview:itemImage];
		return self;
	}
	return nil;
}

- (void) launchMenu
{
	

}

+ (InventoryItemButton*) buttonWithItem:(Item*)it
{
	InventoryItemButton *ret = [[[InventoryItemButton alloc] init] autorelease];
	ret.myItem = it;
	ret.itemImage.image = [UIImage imageNamed:it.item_icon];
	ret.hidden = NO;
	ret.userInteractionEnabled = YES;
	
	return ret;
}


#pragma mark -
#pragma mark UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.5f];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
	//[self launchMenu];
	
	[delegate pressedInvButton:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];	
}


@end
