#import <UIKit/UIKit.h>
#import "PCBaseViewController.h"

@class InventoryScrollView;

@interface InventoryView : PCBaseViewController
{
	InventoryScrollView *sView;
}

- (void) updateWithItemArray:(NSArray*) items;

@end


