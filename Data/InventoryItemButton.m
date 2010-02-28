#import "InventoryItemButton.h"
#import "Item.h"

#import "PCPopupMenu.h"



@implementation InventoryItemButton

@synthesize item = myItem, itemImage, delegate;

- (id) init
{
	if(self = [super init])
	{
		self.itemImage = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ITEM_BUTTON_SIZE, ITEM_BUTTON_SIZE)] autorelease];
		[self addSubview:itemImage];
		return self;
	}
	return nil;
}

+ (InventoryItemButton*) buttonWithItem:(Item*)it
{
	InventoryItemButton *ret = [[[InventoryItemButton alloc] init] autorelease];
	ret.item = it;
	//DLog(@"Item_icon: <%@>",it.item_icon);
	ret.itemImage.image = [UIImage imageNamed:it.icon];
	//DLog(@"Item loaded successfully: %@",it.item_icon);
	ret.hidden = NO;
	ret.userInteractionEnabled = YES;
	
	return ret;
}


#pragma mark -
#pragma mark UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.5f];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	//[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
	//[self launchMenu];
	
	[delegate pressedInvButton:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];	
}


@end
