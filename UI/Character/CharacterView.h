#import <UIKit/UIKit.h>
#import "PCBaseViewController.h"

@class Critter;

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

- (void) updateWithPlayer:(Critter*)player;

@end

@protocol CharacterViewDelegate

- (void) needUpdateForCharView:(CharacterView*)cView;

@end

