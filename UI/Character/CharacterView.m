#import "CharacterView.h"
#import "Skill.h"
#import "Spell.h"
#import "Critter.h"
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

- (void) updateWithPlayer:(Critter*)player
{
	EquippedItems items = player.equipment;
	[leftHandEquipImg setImage:[UIImage imageNamed:items.lhand.icon]];
	[rightHandEquipImg setImage:[UIImage imageNamed:items.rhand.icon]];
	[headArmorEquipImg setImage:[UIImage imageNamed:items.head.icon]];
	[chestArmorEquipImg setImage:[UIImage imageNamed:items.chest.icon]];
	
	moneyDisplay.text = [NSString stringWithFormat:@"%d", player.money];
	
	if (imgName != player.stringIcon)
	{
		imgName = player.stringIcon;
		characterImageView.image = [UIImage imageNamed:imgName];
	}
}

@end
