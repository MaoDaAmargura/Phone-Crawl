#import "CharacterView.h"
#import "Creature.h"
#import "Item.h"

@implementation CharacterView

- (id) init 
{
	if(self = [super initWithNibName:@"CharacterView"])
	{
		return self;
	}
	return nil;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	[delegate needUpdateForCharView:self];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[delegate needUpdateForCharView:self];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Control

- (void) updateWithEquippedItems:(EquipSlots*) items
{
	[leftHandEquipImg setImage:[UIImage imageNamed:items.l_hand.item_icon]];
	[rightHandEquipImg setImage:[UIImage imageNamed:items.r_hand.item_icon]];
	[headArmorEquipImg setImage:[UIImage imageNamed:items.head.item_icon]];
	[chestArmorEquipImg setImage:[UIImage imageNamed:items.chest.item_icon]];
}


@end
