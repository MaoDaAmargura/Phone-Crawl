#import <UIKit/UIKit.h>
#import "InventoryItemButton.h"

@class InventoryItemButton;

@interface InventoryScrollView : UIScrollView <InventoryButtonDelegate, UIActionSheetDelegate>
{
	NSMutableArray *drawnItems;
	UIPageControl *pageMaster;
	
	InventoryItemButton *lastPressed;
	BOOL acceptsButtonTouchEvents;
}

- (void) updateWithItemArray:(NSArray*) items;

@end
