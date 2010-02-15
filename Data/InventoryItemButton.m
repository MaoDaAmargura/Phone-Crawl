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
	self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:1];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}


@end
