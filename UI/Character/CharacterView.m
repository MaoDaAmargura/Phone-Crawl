#import "CharacterView.h"
#import "CombatAbility.h"
#import "Spell.h"
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
	[characterImageView setImage:[UIImage imageNamed:imgName]];
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

- (void) updateWithEquippedItems:(EquipSlots*) items money:(int)money
{
	[leftHandEquipImg setImage:[UIImage imageNamed:items.lHand.icon]];
	[rightHandEquipImg setImage:[UIImage imageNamed:items.rHand.icon]];
	[headArmorEquipImg setImage:[UIImage imageNamed:items.head.icon]];
	[chestArmorEquipImg setImage:[UIImage imageNamed:items.chest.icon]];
	
	moneyDisplay.text = [NSString stringWithFormat:@"%d", money];
}

- (void) setIcon:(NSString*) iconName
{
	imgName = iconName;
	characterImageView.image = [UIImage imageNamed:iconName];
}

@end
