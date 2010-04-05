#import <UIKit/UIKit.h>
#import "WorldView.h"
#import "CharacterView.h"
#import "InventoryView.h"
#import "OptionsView.h"
#import "Engine.h"

#import "MerchantDialogueManager.h"
#import "NPCDialogManager.h"

@class EndGame;

@interface HomeTabViewController : UIViewController <WorldViewDelegate, UITabBarControllerDelegate>
{
	UITabBarController *mainTabController;
	WorldView *wView;
	CharacterView *cView;
	InventoryView *iView;
	OptionsView *oView;
	Engine *gameEngine;
	
	EndGame *endView;
	
	BOOL doneMerchant;
	BOOL gotSword;
	BOOL equippedSword;
	
	UILabel *tutorialDialogueBox;
	
	MerchantDialogueManager *merchManager;
	NPCDialogManager *npcManager;
}

@property (nonatomic, retain) UITabBarController *mainTabController;
@property (nonatomic, retain) Engine *gameEngine;

@property (nonatomic, retain) WorldView *wView;
@property (nonatomic, retain) EndGame *endView;

- (void) newCharacterWithName:(NSString*)name andIcon:(NSString*)icon;

- (void) refreshInventoryView;

- (void) updateCharacterView;

@end

@interface HomeTabViewController (Tutorial)

- (void) continueTutorialFromMerchant;
- (void) continueTutorialFromSword;
- (void) continueTutorialFromSwordEquipped;
- (void) finishTutorial;


@end
