

#import <UIKit/UIKit.h>
#import "PCBaseViewController.h"

#import "Creature.h"

@interface SkillUpgradeViewController : PCBaseViewController
{
	IBOutlet UIView *subspaceView;
	IBOutlet UIView *spellView;
	IBOutlet UIView *abilityView;
	
	Creature *player;
	IBOutlet UILabel *numPoints;
	
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
	
	IBOutlet UIButton *basicAttackButton;
	IBOutlet UIButton *quickAttackButton;
	IBOutlet UIButton *powerAttackButton;
	IBOutlet UIButton *eleAttackButton;
	IBOutlet UIButton *comboAttackButton;
}

- (IBAction) valueChangedForSegmentedControl:(UISegmentedControl*) segCont;

- (IBAction) upgradeFlame;
- (IBAction) upgradeFrost;
- (IBAction) upgradeShock;
- (IBAction) upgradeDrain;
- (IBAction) upgradeErode;

- (IBAction) upgradeBurn;
- (IBAction) upgradeFreeze;
- (IBAction) upgradePurge;
- (IBAction) upgradeConfuse;
- (IBAction) upgradePoison;

- (IBAction) upgradeBasic;
- (IBAction) upgradeQuick;
- (IBAction) upgradePower;
- (IBAction) upgradeElem;
- (IBAction) upgradeCombo;

@end
