#import <UIKit/UIKit.h>
#import "PCBaseViewController.h"

@class EquipSlots;

@interface CharacterView : PCBaseViewController
{
	IBOutlet UIImageView *characterImageView;
	
	IBOutlet UIImageView *leftHandEquipImg;
	IBOutlet UIImageView *rightHandEquipImg;
	IBOutlet UIImageView *headArmorEquipImg;
	IBOutlet UIImageView *chestArmorEquipImg;
}

- (void) updateWithEquippedItems:(EquipSlots*) items;

@end

@protocol CharacterViewDelegate

- (void) needUpdateForCharView:(CharacterView*)cView;

@end

