#import <UIKit/UIKit.h>
#import "WorldView.h"
#import "CharacterView.h"
#import "InventoryView.h"
#import "OptionsView.h"
#import "Engine.h"


@interface HomeTabViewController : UIViewController <WorldViewDelegate, UITabBarControllerDelegate, CharacterViewDelegate>
{
	UITabBarController *mainTabController;
	WorldView *wView;
	CharacterView *cView;
	InventoryView *iView;
	OptionsView *oView;
	Engine *gameEngine;
}

@property (nonatomic, retain) UITabBarController *mainTabController;
@property (nonatomic, retain) Engine *gameEngine;

@end
