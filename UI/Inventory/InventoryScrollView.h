#import <UIKit/UIKit.h>
#import "InventoryItemButton.h"

@class InventoryItemButton;
@class Engine;

@interface InventoryScrollView : UIScrollView <InventoryButtonDelegate, UIActionSheetDelegate>
{
	NSMutableArray *drawnItems;
	UIPageControl *pageMaster;
	
	InventoryItemButton *lastPressed;
	BOOL acceptsButtonTouchEvents;
	
	Engine *gEngineRef;
}

- (void) updateWithItemArray:(NSArray*) items;

@end
