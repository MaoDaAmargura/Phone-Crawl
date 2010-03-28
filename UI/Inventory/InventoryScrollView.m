#import "InventoryScrollView.h"
#import "PCPopupMenu.h"

#import "HomeTabViewController.h"
#import "Phone_CrawlAppDelegate.h"
#import "Engine.h"
#import "Item.h"


#define PAGE_WIDTH 320

#define EQUIP_BUTTON_TITLE	@"Equip"
#define USE_BUTTON_TITLE	@"Use"
#define DROP_BUTTON_TITLE	@"Drop"

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
		//self.backgroundColor = [UIColor redColor];
		UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)] autorelease];
		[imgView setImage:[UIImage imageNamed:@"ui-inventorybg.png"]];
		[self addSubview:imgView];
		self.bounces = YES;
		
		acceptsButtonTouchEvents = YES;
		lastPressed = nil;
		return self;
	}
	return nil;
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
	
	int numTilesAcross = 4; //bounds.size.width/ITEM_BUTTON_SIZE;
	int numTilesDown = 5; //bounds.size.height/ITEM_BUTTON_SIZE;
	
	int tileVertSpread = (bounds.size.width - (numTilesAcross * ITEM_BUTTON_SIZE))/(numTilesAcross+1);
	int tileHorizSpread = (bounds.size.height - (numTilesDown * ITEM_BUTTON_SIZE))/(numTilesDown+1);
	
	int row, col, pageIndex, numPages;
	
	numPages = ([items count]/(numTilesDown*numTilesAcross)) + 1;
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, PAGE_WIDTH * numPages, self.frame.size.height);
	
	for(Item *i in items)
	{
		row = index/numTilesAcross;
		col	= index%numTilesAcross;
		pageIndex = 0;
		while(row>=numTilesDown)
		{
			row -= numTilesDown;
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
	UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:button.item.name 
															  delegate:self 
													 cancelButtonTitle:nil
												destructiveButtonTitle:nil
													 otherButtonTitles:nil] autorelease];
	if ([button.item isEquipable]) 
		[actionSheet addButtonWithTitle:EQUIP_BUTTON_TITLE];
	else 
		[actionSheet addButtonWithTitle:USE_BUTTON_TITLE];
	[actionSheet addButtonWithTitle:DROP_BUTTON_TITLE];
	[actionSheet addButtonWithTitle:@"Cancel"];
	
	[actionSheet showInView:self];
}
								   
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	Engine *gEngine = [(Phone_CrawlAppDelegate*)([[UIApplication sharedApplication] delegate]) gameEngineObject];
	
	NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
	
	if ([buttonTitle isEqualToString:EQUIP_BUTTON_TITLE])
	{
		[gEngine playerEquipItem:lastPressed.item];
	}
	else if ([buttonTitle isEqualToString:USE_BUTTON_TITLE])
	{
		[gEngine playerUseItem:lastPressed.item];
	}
	else if ([buttonTitle isEqualToString:DROP_BUTTON_TITLE])
	{
		[gEngine playerDropItem:lastPressed.item];
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
