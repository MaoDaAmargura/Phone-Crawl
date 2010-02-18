//
//  InventoryItemButton.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 2/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ITEM_BUTTON_SIZE 60

@class Item;

@protocol InventoryButtonDelegate;


@interface InventoryItemButton : UIView 
{
	Item *myItem;
	UIImageView *itemImage;
	id<InventoryButtonDelegate> delegate;
}

+ (InventoryItemButton*) buttonWithItem:(Item*)it;

@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) UIImageView *itemImage;
@property (nonatomic, retain) id<InventoryButtonDelegate> delegate;

@end


@protocol InventoryButtonDelegate

- (void) pressedInvButton:(InventoryItemButton*)button;

@end