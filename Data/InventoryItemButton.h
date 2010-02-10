//
//  InventoryItemButton.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 2/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Item;

@interface InventoryItemButton : UIButton
{
	Item *myItem;
}

+ (InventoryItemButton*) buttonWithItem:(Item*)it;

@property (nonatomic, retain) Item *myItem;

@end
