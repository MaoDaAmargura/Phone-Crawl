//
//  InventoryScrollView.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 2/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InventoryScrollView.h"
#import "PCPopupMenu.h"

PCPopupMenu *currentItemMenu;

#define PAGE_WIDTH 320

@implementation InventoryScrollView

- (id) initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		drawnItems = [[NSMutableArray alloc] initWithCapacity:5];
		pageMaster = [[UIPageControl alloc] initWithFrame:CGRectMake(140, 340, 40, 20)];
		[self addSubview:pageMaster];
		self.backgroundColor = [UIColor redColor];
		self.bounces = YES;
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
	[currentItemMenu removeFromSuperview];
	int xoffset = ITEM_BUTTON_SIZE/2, yoffset = ITEM_BUTTON_SIZE/2;
	if(button.frame.origin.x > 160)
		xoffset = -xoffset;
	if(button.frame.origin.y > 230)
		yoffset = -yoffset;
	CGPoint origin = CGPointMake(button.frame.origin.x + xoffset, button.frame.origin.y + yoffset);
	PCPopupMenu *menu = [[[PCPopupMenu alloc] initWithOrigin:origin] autorelease];
	[menu addMenuItem:@"Drop" delegate:self selector:@selector(drop)];
	
	if(1/*[myItem isEquippable]*/)
		[menu addMenuItem:@"Equip" delegate:self selector:@selector(equip)];
	if(1/*[myItem isUsable]*/)
		[menu addMenuItem:@"Use" delegate:self selector:@selector(use)];
	
	[menu showInView:self];
	currentItemMenu = menu;
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
	[currentItemMenu removeFromSuperview];
	currentItemMenu = nil;
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
}

@end
