

#import <UIKit/UIKit.h>
#import "PCBaseViewController.h"

#import "Creature.h"

@interface SkillUpgradeViewController : PCBaseViewController
{
	IBOutlet UIView *subspaceView;
	IBOutlet UIView *spellView;
	IBOutlet UIView *abilityView;
	
	Creature *player;
	
	IBOutlet UISegmentedControl *mainSegmentControl;
	
	IBOutlet UIButton *flameSkillButton;
	IBOutlet UIButton *frostSkillButton;
	IBOutlet UIButton *shockSkillButton;
	IBOutlet UIButton *drainSkillButton;
	IBOutlet UIButton *erodeSkillButton;
	
	IBOutlet UIButton *burnSkillButton;
	IBOutlet UIButton *freezeSkillButton;
	IBOutlet UIButton *purgeSkillButton;
	IBOutlet UIButton *confuseSkillButton;
	IBOutlet UIButton *poisonSkillButton;
}

- (IBAction) valueChangedForSegmentedControl:(UISegmentedControl*) segCont;

@end
