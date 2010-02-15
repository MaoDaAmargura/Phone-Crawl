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

@interface InventoryItemButton : UIView
{
	Item *myItem;
	UIImageView *itemImage;
}

+ (InventoryItemButton*) buttonWithItem:(Item*)it;

@property (nonatomic, retain) Item *myItem;
@property (nonatomic, retain) UIImageView *itemImage;

@end
