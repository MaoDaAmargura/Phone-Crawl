#import <UIKit/UIKit.h>
#import "WorldView.h"
#import "CharacterView.h"
#import "InventoryView.h"
#import "OptionsView.h"
#import "Engine.h"


@interface HomeTabViewController : UIViewController <WorldViewDelegate, InventoryViewDelegate>
{
	UITabBarController *mainTabController;
	WorldView *wView;
	CharacterView *cView;
	InventoryView *iView;
	OptionsView *oView;
	Engine *gameEngine;
}

@property (nonatomic, retain) UITabBarController *mainTabController;

- (bool) highlightShouldBeYellowAtPoint: (CGPoint) point;
+ (HomeTabViewController*) instance;

@end
