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
	PCPopupMenu *menu = [[[PCPopupMenu alloc] initWithFrame:CGRectMake(ITEM_BUTTON_SIZE/2, ITEM_BUTTON_SIZE/2, 40, 60)] autorelease];
	
	if(1/*[myItem isEquippable]*/)
		[menu addMenuItem:@"Equip" delegate:self selector:@selector(equip)];
	if(1/*[myItem isUsable]*/)
		[menu addMenuItem:@"Use" delegate:self selector:@selector(use)];
	
	[menu showInView:self];


}

+ (InventoryItemButton*) buttonWithItem:(Item*)it
{
	InventoryItemButton *ret = [[[InventoryItemButton alloc] init] autorelease];
	ret.myItem = it;
	//TODO: Use Real Image
	//[ret setImage:[UIImage imageNamed:@"human1.png"] forState:UIControlStateNormal];
	//[ret setImage:[UIImage imageNamed:it.item_icon] forState:UIControlStateNormal];
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
