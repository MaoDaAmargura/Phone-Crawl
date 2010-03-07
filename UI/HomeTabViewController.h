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
	BOOL checkOutCharacter;
	BOOL checkOutInventory;
	BOOL checkOutOptions;
	BOOL backToWorld;
}

@property (nonatomic, retain) UITabBarController *mainTabController;
@property (nonatomic, retain) Engine *gameEngine;

- (void) newCharacterWithName:(NSString*)name andIcon:(NSString*)icon;

- (void) refreshInventoryView;

@end
