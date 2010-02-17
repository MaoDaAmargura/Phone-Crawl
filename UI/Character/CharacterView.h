#import <UIKit/UIKit.h>
#import "PCBaseViewController.h"

@interface CharacterView : PCBaseViewController
{
	IBOutlet UIImageView *characterImageView;
	
	IBOutlet UIImageView *leftHandEquipImg;
	IBOutlet UIImageView *rightHandEquipImg;
	IBOutlet UIImageView *headArmorEquipImg;
	IBOutlet UIImageView *chestArmorEquipImg;
}

@end
