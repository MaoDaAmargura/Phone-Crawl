#import <UIKit/UIKit.h>
#import "WorldView.h"
#import "CharacterView.h"
#import "InventoryView.h"
#import "OptionsView.h"
#import "Engine.h"

@interface HomeTabViewController : UIViewController <WorldViewDelegate, UITabBarControllerDelegate>
{
	UITabBarController *mainTabController;
	WorldView *wView;
	CharacterView *cView;
	InventoryView *iView;
	OptionsView *oView;
	Engine *gameEngine;
	
	BOOL tutorialMode;
	
	BOOL doneMerchant;
	BOOL gotSword;
	BOOL equippedSword;
	
	UILabel *tutorialDialogueBox;
}

@property (nonatomic, retain) UITabBarController *mainTabController;
@property (nonatomic, retain) Engine *gameEngine;

- (void) newCharacterWithName:(NSString*)name andIcon:(NSString*)icon;

- (void) refreshInventoryView;

@end

@interface HomeTabViewController (Tutorial)

- (void) continueTutorialFromMerchant;
- (void) continueTutorialFromSword;
- (void) continueTutorialFromSwordEquipped;

@end
