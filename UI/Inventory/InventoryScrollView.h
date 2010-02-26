#import <UIKit/UIKit.h>
#import "InventoryItemButton.h"



@interface InventoryScrollView : UIScrollView <InventoryButtonDelegate>
{
	NSMutableArray *drawnItems;
	UIPageControl *pageMaster;
}

- (void) updateWithItemArray:(NSArray*) items;

@end
