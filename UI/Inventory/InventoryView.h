//
//  InventoryView.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCBaseViewController.h"

@class InventoryScrollView;

@interface InventoryView : PCBaseViewController
{
	InventoryScrollView *sView;
}

- (void) updateWithItemArray:(NSArray*) items;

@end


