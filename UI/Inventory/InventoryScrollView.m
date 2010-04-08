#import "InventoryScrollView.h"
#import "PCPopupMenu.h"

#import "HomeTabViewController.h"
#import "Phone_CrawlAppDelegate.h"
#import "Critter.h"
#import "Engine.h"
#import "Item.h"


#define PAGE_WIDTH 320

#define EQUIP_BUTTON_TITLE	@"Equip"
#define DEQUIP_BUTTON_TITLE	@"Dequip"
#define USE_BUTTON_TITLE	@"Use"
#define DROP_BUTTON_TITLE	@"Drop"

#define TILES_DOWN		5
#define TILES_ACROSS	4

@interface InventoryScrollView (Private)

+ (void) clearCurrentItem;

@end


@implementation InventoryScrollView

- (id) initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		drawnItems = [[NSMutableArray alloc] initWithCapacity:5];
		pageMaster = [[UIPageControl alloc] initWithFrame:CGRectMake(140, 340, 40, 20)];
		[self addSubview:pageMaster];
		self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ui-inventorybg.png"]];
		self.bounces = YES;
		
		acceptsButtonTouchEvents = YES;
		lastPressed = nil;
		
		gEngineRef = [(Phone_CrawlAppDelegate*)([[UIApplication sharedApplication] delegate]) gameEngineObject];
	}
	return self;
}

- (void)dealloc 
{
	[pageMaster release];
	[drawnItems release];
    [super dealloc];
}

#pragma mark -
#pragma mark Control
/*!
 @method		updateWithItemArray
 @abstract		re-renders the new inventory screen with the new item list.
 @discussion	clears array of references to drawn items. determines item spread based on numbers and values.
				creates an inventory button for each item. modifies the pageControl. adds all the new buttons
				to the saved reference array
 */
- (void) updateWithItemArray:(NSArray*) items
{
	for (InventoryItemButton *b in drawnItems)
		[b removeFromSuperview];
	
	[drawnItems removeAllObjects];
	int index = 0;
	
	CGRect bounds = self.bounds;
	
	int tileVertSpread = (bounds.size.width - (TILES_ACROSS * ITEM_BUTTON_SIZE))/(TILES_ACROSS+1)-1;
	int tileHorizSpread = (bounds.size.height - (TILES_DOWN * ITEM_BUTTON_SIZE))/(TILES_DOWN+1)-1;
	
	int row, col, pageIndex, numPages;
	
	numPages = ([items count]/(TILES_DOWN*TILES_ACROSS))+1;
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, PAGE_WIDTH * numPages, self.frame.size.height);
	
	for(Item *i in items)
	{
		row = index/TILES_ACROSS;
		col	= index%TILES_ACROSS;
		pageIndex = 0;
		while(row>=TILES_DOWN)
		{
			row -= TILES_DOWN;
			pageIndex++;
		}

		InventoryItemButton *b = [InventoryItemButton buttonWithItem:i];
		b.delegate = self;
		[drawnItems addObject:b];
		
		CGRect r = CGRectMake(tileHorizSpread*(col+1) + ITEM_BUTTON_SIZE * col,
							  bounds.size.width*pageIndex + tileVertSpread*(row+1) + ITEM_BUTTON_SIZE * row,
							  ITEM_BUTTON_SIZE,
							  ITEM_BUTTON_SIZE);
		b.frame = r;
		++index;
	}

	for (InventoryItemButton *b in drawnItems)
		[self addSubview:b];
}

#pragma mark -
#pragma mark Protocols
/*!
 @method		pressedInvButton
 @abstract		callback handler for a button thats been clicked
 @discussion	removes the old menu if there was one. determines the location for the new menu.
				instantiates the new menu. generates the menu items for it. Saves the reference.
 */
- (void) pressedInvButton:(InventoryItemButton*)button
{
	/*
	Engine *gEngine = [[(Phone_CrawlAppDelegate*)([[UIApplication sharedApplication] delegate]) homeTabController] gameEngine];

	int xoffset = ITEM_BUTTON_SIZE/2, yoffset = ITEM_BUTTON_SIZE/2;
	if(button.frame.origin.x > 160)
		xoffset = -xoffset;
	if(button.frame.origin.y > 230)
		yoffset = -yoffset;
	CGPoint origin = CGPointMake(button.frame.origin.x + xoffset, button.frame.origin.y + yoffset);
	PCPopupMenu *menu = [[[PCPopupMenu alloc] initWithOrigin:origin] autorelease];
	[menu addMenuItem:@"Drop" delegate:gEngine selector:@selector(playerDropItem:) context:button.item];
	menu.dieOnFire = YES;
	
	if([button.item isEquipable])
		[menu addMenuItem:@"Equip" delegate:gEngine selector:@selector(playerEquipItem:) context:button.item];
	if(![button.item isEquipable])
		[menu addMenuItem:@"Use" delegate:gEngine selector:@selector(playerUseItem:) context:button.item];
	
	[menu showInView:self];
	*/
	lastPressed = button;
	Item *i = button.item;
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:i.name 
															  delegate:self 
													 cancelButtonTitle:nil
												destructiveButtonTitle:nil
													 otherButtonTitles:nil] autorelease];
	if ([i isEquipable])
	{
		if ([gEngineRef.player hasItemEquipped:i])
		{
			[actionSheet addButtonWithTitle:DEQUIP_BUTTON_TITLE];
		}
		else
		{
			[actionSheet addButtonWithTitle:EQUIP_BUTTON_TITLE];
		}
	}
	else 
	{
		[actionSheet addButtonWithTitle:USE_BUTTON_TITLE];
	}
	[actionSheet addButtonWithTitle:DROP_BUTTON_TITLE];
	[actionSheet addButtonWithTitle:@"Cancel"];
	
	[actionSheet showInView:self];
}
								   
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	
	if ([buttonTitle isEqualToString:EQUIP_BUTTON_TITLE])
	{
		[gEngineRef playerEquipItem:lastPressed.item];
	}
	else if ([buttonTitle isEqualToString:USE_BUTTON_TITLE])
	{
		[gEngineRef playerUseItem:lastPressed.item];
	}
	else if ([buttonTitle isEqualToString:DROP_BUTTON_TITLE])
	{
		[gEngineRef playerDropItem:lastPressed.item];
	}
	else if ([buttonTitle isEqualToString:DEQUIP_BUTTON_TITLE])
	{
		[gEngineRef playerDequipItem:lastPressed.item];
	}


}


#pragma mark -
#pragma mark UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
}

@end
