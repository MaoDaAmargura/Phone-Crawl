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
	
	IBOutlet UILabel *moneyDisplay;
	
	NSString *imgName;
}

- (void) setIcon:(NSString*) iconName;

- (void) updateWithEquippedItems:(EquipSlots*) items money:(int)money;

@end

@protocol CharacterViewDelegate

- (void) needUpdateForCharView:(CharacterView*)cView;

@end

