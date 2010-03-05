#import <UIKit/UIKit.h>
#import "PCBaseViewController.h"

@interface SkillUpgradeViewController : PCBaseViewController
{
	IBOutlet UIView *subspaceView;
	IBOutlet UIView *spellView;
	IBOutlet UIView *abilityView;
	
	IBOutlet UISegmentedControl *mainSegmentControl;
}

- (IBAction) valueChangedForSegmentedControl:(UISegmentedControl*) segCont;

@end
