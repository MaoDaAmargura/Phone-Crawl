

#import "SkillUpgradeViewController.h"

#import "Phone_CrawlAppDelegate.h"
#import "UIImage+Overlay.h"
#import <QuartzCore/QuartzCore.h>

#import "Util.h"
#import "Critter.h"
#import "Skill.h"
#import "Spell.h"

#define FIRE_ICON	@"bg-fire.png"
#define COLD_ICON	@"bg-cold.png"
#define SHOCK_ICON	@"bg-lightning.png"
#define DARK_ICON	@"bg-dark.png"
#define POISON_ICON	@"bg-poison.png"

#define BASIC_ICON	@"swordsingle.png"
#define QUICK_ICON	@"dagger.png"
#define POWER_ICON	@"claymore.png"
#define ELEM_ICON	@"bg-fire.png"
#define COMBO_ICON	@"sworddual.png"

#define COST_OF_SKILL 2
#define COST_OF_SPELL 1

@interface SkillUpgradeViewController (Private)

- (void) updateUI;

@end


@implementation SkillUpgradeViewController

#pragma mark -
#pragma mark Life Cycle

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)init
{
    if (self = [super initWithNibName:@"SkillUpgradeViewController"]) 
	{
        // Custom initialization
		Phone_CrawlAppDelegate *appdlgt = (Phone_CrawlAppDelegate*) [[UIApplication sharedApplication] delegate];
		player = [appdlgt playerObject];
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	[subspaceView addSubview:spellView];
	[subspaceView addSubview:abilityView];
	abilityView.hidden = YES;
	[mainSegmentControl setSelectedSegmentIndex:0];
	[self updateUI];
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
    [super dealloc];
}

#pragma mark -
#pragma mark Control

- (void) updateButton:(UIButton*)button withBackground:(NSString*)bkg number:(int)num
{
	UIImage *bkgrnd = [UIImage imageNamed:bkg];
	bkgrnd = [bkgrnd resize:button.frame.size];
	UIImage *lvlImg = [UIImage imageNamed:[NSString stringWithFormat:@"Numeral%d-Normal.png", num]];
	UIImage *icon = [bkgrnd overlayedWithImage:lvlImg];
	[button setImage:icon forState:UIControlStateNormal];
	CALayer *layer = [button layer];
	[layer setMasksToBounds:YES];
	[layer setCornerRadius:10.0];
}

- (void) updateUI
{
	Abilities playerAbils = player.abilities;
	
	[self updateButton:flameSkillButton withBackground:FIRE_ICON number:playerAbils.spells[FIREDAMAGE]];
	[self updateButton:frostSkillButton withBackground:COLD_ICON number:playerAbils.spells[COLDDAMAGE]];
	[self updateButton:shockSkillButton withBackground:SHOCK_ICON number:playerAbils.spells[LIGHTNINGDAMAGE]];
	[self updateButton:erodeSkillButton withBackground:POISON_ICON number:playerAbils.spells[POISONDAMAGE]];
	[self updateButton:drainSkillButton withBackground:DARK_ICON number:playerAbils.spells[DARKDAMAGE]];
	
	[self updateButton:burnSkillButton withBackground:FIRE_ICON number:playerAbils.spells[FIRECONDITION]];
	[self updateButton:freezeSkillButton withBackground:COLD_ICON number:playerAbils.spells[COLDCONDITION]];
	[self updateButton:purgeSkillButton withBackground:SHOCK_ICON number:playerAbils.spells[LIGHTNINGCONDITION]];
	[self updateButton:poisonSkillButton withBackground:POISON_ICON number:playerAbils.spells[POISONCONDITION]];
	[self updateButton:confuseSkillButton withBackground:DARK_ICON number:playerAbils.spells[DARKCONDITION]];
	
	[self updateButton:basicAttackButton withBackground:BASIC_ICON number:playerAbils.skills[REG_STRIKE]];
	[self updateButton:quickAttackButton withBackground:QUICK_ICON number:playerAbils.skills[QUICK_STRIKE]];
	[self updateButton:powerAttackButton withBackground:POWER_ICON number:playerAbils.skills[BRUTE_STRIKE]];
	[self updateButton:eleAttackButton withBackground:ELEM_ICON number:playerAbils.skills[ELE_STRIKE]];
	[self updateButton:comboAttackButton withBackground:COMBO_ICON number:playerAbils.skills[MIX_STRIKE]];
	
	numPoints.text = [NSString stringWithFormat:@"%d", player.abilityPoints];
}

#pragma mark -
#pragma mark XIB Interface

- (IBAction) valueChangedForSegmentedControl:(UISegmentedControl*) segCont
{
	switch (segCont.selectedSegmentIndex) 
	{
		case 0:
			abilityView.hidden = YES;
			spellView.hidden = NO;
			break;
		case 1:
			abilityView.hidden = NO;
			spellView.hidden = YES;
			break;
		default:
			//TODO: Error
			break;
	}
}

- (void) upgradeSpell:(PC_SPELL_TYPE)spell andUpdateButton:(UIButton*)button withIconNamed:(NSString*)name 
{
	int i = (int) spell;
	if (player.abilities.spells[i] >= 5 || player.abilityPoints < COST_OF_SPELL)
		return;
	[player abilities].spells[i]++;
	player.abilityPoints -= COST_OF_SPELL;
	numPoints.text = [NSString stringWithFormat:@"%d", player.abilityPoints];
	[self updateButton:button withBackground:name number:player.abilities.spells[spell]];
}

- (void) upgradeSkill:(PC_COMBAT_ABILITY_TYPE)skill andUpdateButton:(UIButton*)button withIconNamed:(NSString*) name
{
	if (player.abilities.skills[skill] >= 5 || player.abilityPoints < COST_OF_SKILL)
		return;
	[player abilities].skills[skill]++;
	player.abilityPoints -= COST_OF_SKILL;
	numPoints.text = [NSString stringWithFormat:@"%d", player.abilityPoints];
	[self updateButton:button withBackground:name number:player.abilities.skills[skill]];
}

- (IBAction) upgradeFlame
{
	[self upgradeSpell:FIREDAMAGE andUpdateButton:flameSkillButton withIconNamed:FIRE_ICON];
}

- (IBAction) upgradeFrost
{
	[self upgradeSpell:COLDDAMAGE andUpdateButton:frostSkillButton withIconNamed:COLD_ICON];
}

- (IBAction) upgradeShock
{
	[self upgradeSpell:LIGHTNINGDAMAGE andUpdateButton:shockSkillButton withIconNamed:SHOCK_ICON];
}

- (IBAction) upgradeDrain
{
	[self upgradeSpell:DARKDAMAGE andUpdateButton:drainSkillButton withIconNamed:DARK_ICON];
}

- (IBAction) upgradeErode
{
	[self upgradeSpell:POISONDAMAGE andUpdateButton:erodeSkillButton withIconNamed:POISON_ICON];
}

- (IBAction) upgradeBurn
{
	[self upgradeSpell:FIRECONDITION andUpdateButton:burnSkillButton withIconNamed:FIRE_ICON];
}

- (IBAction) upgradeFreeze
{
	[self upgradeSpell:COLDCONDITION andUpdateButton:freezeSkillButton withIconNamed:COLD_ICON];
}

- (IBAction) upgradePurge
{
	[self upgradeSpell:LIGHTNINGCONDITION andUpdateButton:purgeSkillButton withIconNamed:SHOCK_ICON];
}

- (IBAction) upgradeConfuse
{
	[self upgradeSpell:DARKCONDITION andUpdateButton:confuseSkillButton withIconNamed:DARK_ICON];
}

- (IBAction) upgradePoison
{
	[self upgradeSpell:POISONCONDITION andUpdateButton:poisonSkillButton withIconNamed:POISON_ICON];
}

- (IBAction) upgradeBasic
{
	[self upgradeSkill:REG_STRIKE andUpdateButton:basicAttackButton withIconNamed:BASIC_ICON];
}

- (IBAction) upgradeQuick
{
	[self upgradeSkill:QUICK_STRIKE andUpdateButton:quickAttackButton withIconNamed:QUICK_ICON];
}

- (IBAction) upgradePower
{
	[self upgradeSkill:BRUTE_STRIKE andUpdateButton:powerAttackButton withIconNamed:POWER_ICON];
}

- (IBAction) upgradeElem
{
	[self upgradeSkill:ELE_STRIKE andUpdateButton:eleAttackButton withIconNamed:ELEM_ICON];
}

- (IBAction) upgradeCombo
{
	[self upgradeSkill:MIX_STRIKE andUpdateButton:comboAttackButton withIconNamed:COMBO_ICON];
}

@end
