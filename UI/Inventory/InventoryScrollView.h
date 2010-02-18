//
//  InventoryScrollView.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 2/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InventoryItemButton.h"



@interface InventoryScrollView : UIScrollView <InventoryButtonDelegate>
{
	NSMutableArray *drawnItems;
	UIPageControl *pageMaster;
}

- (void) updateWithItemArray:(NSArray*) items;

- (void) dropCurrentItem;
- (void) useCurrentItem;
- (void) equipCurrentItem;

@end
