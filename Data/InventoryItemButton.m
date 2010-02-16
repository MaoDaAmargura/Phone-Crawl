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

PCPopupMenu *currentItemMenu = 0;

@implementation InventoryItemButton

@synthesize myItem, itemImage;

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
	[currentItemMenu removeFromSuperview];
	int xoffset = ITEM_BUTTON_SIZE/2, yoffset = ITEM_BUTTON_SIZE/2;
	if(self.frame.origin.x > 160)
		xoffset = -xoffset;
	if(self.frame.origin.y > 230)
		yoffset = -yoffset;
	CGPoint origin = CGPointMake(self.frame.origin.x + xoffset, self.frame.origin.y + yoffset);
	PCPopupMenu *menu = [[[PCPopupMenu alloc] initWithOrigin:origin] autorelease];
	[menu addMenuItem:@"Drop" delegate:self selector:@selector(drop)];
	
	if(1/*[myItem isEquippable]*/)
		[menu addMenuItem:@"Equip" delegate:self selector:@selector(equip)];
	if(1/*[myItem isUsable]*/)
		[menu addMenuItem:@"Use" delegate:self selector:@selector(use)];
	
	[menu showInView:self.superview];
	currentItemMenu = menu;

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
	[self launchMenu];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];	
}


@end
