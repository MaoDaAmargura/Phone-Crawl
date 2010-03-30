//
//  BattleMenuManager.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BattleMenuManager.h"

#import "CombatAbility.h"
#import "Spell.h"
#import "Item.h"
#import "Util.h"
#import "Creature.h"
#import "Engine.h"


@interface BattleMenuManager (MenuDisplay)

//- (void) showBattleMenu; Declared in header for other classes to use
- (void) showAttackMenu;
- (void) showSpellMenu;
- (void) showItemMenu;
- (void) showDSpellMenu;
- (void) showCSpellMenu;

@end

static NSString *attackMenuOptions[5] = {@"Regular", @"Quick", @"Power", @"Elemental", @"Combo"};
static NSString *dspellMenuOptions[5] = {@"Flame", @"Frost", @"Shock", @"Erode", @"Drain"};
static NSString *cspellMenuOptions[5] = {@"Burn", @"Freeze", @"Purge", @"Poison", @"Confuse"};
static NSString *spellLevelDesignations[5] = {@"Lesser", @"Minor", @"Major", @"Greater", @"Superior"};

@implementation BattleMenuManager

@synthesize playerRef;

- (id) initWithTargetView:(UIView*)target andDelegate:(Engine*) del
{
	if (self = [super init])
	{
		targetViewRef = target;
		gameEngineRef = del;
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}


#pragma mark -
#pragma mark Display
- (void) showBattleMenu
{
	battleMenu = [[[UIActionSheet alloc] initWithTitle:@"Do what?"
											 delegate:self
									cancelButtonTitle:nil
							   destructiveButtonTitle:nil
									otherButtonTitles:@"Attack", @"Cast", @"Item", @"Nothing", nil] autorelease];
	[battleMenu showInView:targetViewRef];
}

- (void) showAttackMenu
{
	attackMenu = [[[UIActionSheet alloc] initWithTitle:@"Use Which Attack?"
											 delegate:self
									cancelButtonTitle:nil
							   destructiveButtonTitle:nil
									otherButtonTitles:nil] autorelease];
	for (int i = 0 ; i < NUM_PLAYER_COMBAT_ABILITY_TYPES ; ++i) 
	{
		if (playerRef.abilities.combatAbility[i] != 0) 
			[attackMenu addButtonWithTitle:attackMenuOptions[i]];
	}
	[attackMenu addButtonWithTitle:@"Do Something Else"];
	[attackMenu showInView:targetViewRef];
}

- (void) showSpellMenu
{
	castMenu = [[[UIActionSheet alloc] initWithTitle:@"Which Type of Spell?"
											delegate:self
								   cancelButtonTitle:nil
							  destructiveButtonTitle:nil
								   otherButtonTitles:@"Damage", @"Condition", @"Do Something Else", nil] autorelease];
	[castMenu showInView:targetViewRef];
}

- (void) showItemMenu
{
	itemMenu = [[[UIActionSheet alloc] initWithTitle:@"Use which Item?"
											delegate:self
								   cancelButtonTitle:nil
							  destructiveButtonTitle:nil
								   otherButtonTitles:nil] autorelease];
	for (Item *i in playerRef.inventory)
	{
		if (![i isEquipable])
			[itemMenu addButtonWithTitle:i.name];
	}
	[itemMenu addButtonWithTitle:@"Do something else."];
	[itemMenu showInView:targetViewRef];
}

- (void) showDSpellMenu
{
	dspellMenu = [[[UIActionSheet alloc] initWithTitle:@"Cast Which Spell?"
											  delegate:self
									 cancelButtonTitle:nil
								destructiveButtonTitle:nil
									 otherButtonTitles:nil] autorelease];
	
	for (int i = 0; i < 5 /*number of damage spells*/; ++i) 
	{
		int spellLevel = playerRef.abilities.spellBook[i];
		if (spellLevel!=0) 
			[dspellMenu addButtonWithTitle:[NSString stringWithFormat:@"%@ %@", 
											spellLevelDesignations[spellLevel-1], 
											dspellMenuOptions[i]]];
	}
	[dspellMenu addButtonWithTitle:@"Do something else."];
	[dspellMenu showInView:targetViewRef];
}

- (void) showCSpellMenu
{
	cspellMenu = [[[UIActionSheet alloc] initWithTitle:@"Cast Which Spell?"
											  delegate:self
									 cancelButtonTitle:nil
								destructiveButtonTitle:nil
									 otherButtonTitles:nil] autorelease];
	for (int i = 5; i < 10/*number of condition spells*/; ++i)
	{
		int spellLevel = playerRef.abilities.spellBook[i];
		if (spellLevel > 0) 
			[cspellMenu addButtonWithTitle:[NSString stringWithFormat:@"%@ %@",
											spellLevelDesignations[spellLevel-1],
											cspellMenuOptions[i-5]]];
	}
	[cspellMenu addButtonWithTitle:@"Do something else."];
	[cspellMenu showInView:targetViewRef];
}

#pragma mark -
#pragma mark ActionSheet Delegate

- (void) battleMenuTouchedAtIndex:(NSInteger) buttonIndex
{
	switch (buttonIndex) {
		case 0: // Attack
			[self showAttackMenu];
			break;
		case 1:
			[self showSpellMenu];
			break;
		case 2:
			[self showItemMenu];
			break;
		default:
			break;
	}
}

- (void) attackMenuTouchedAtIndex:(NSInteger) buttonIndex
{
	NSString *buttonTitle = [attackMenu buttonTitleAtIndex:buttonIndex];
	CombatAbility *ca = nil;
	if ([buttonTitle isEqualToString:attackMenuOptions[0]])
	{
		// Regular
		ca = [abilityList objectAtIndex:0];
	}
	else if ([buttonTitle isEqualToString:attackMenuOptions[1]])
	{
		// Quick
		ca = [abilityList objectAtIndex:1];
	}
	else if	([buttonTitle isEqualToString:attackMenuOptions[2]])
	{
		// Power
		ca = [abilityList objectAtIndex:2];
	}
	else if ([buttonTitle isEqualToString:attackMenuOptions[3]])
	{
		// Elemental
		ca = [abilityList objectAtIndex:3];
	}
	else if	([buttonTitle isEqualToString:attackMenuOptions[4]])
	{
		// Combo
		ca = [abilityList objectAtIndex:4];
	}
	else 
	{
		// Something Else
		[self showBattleMenu];
		return;
	}
	[gameEngineRef ability_handler:ca];
}

- (void) castMenuTouchedAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0:
			[self showDSpellMenu];
			break;
		case 1:
			[self showCSpellMenu];
			break;
		default:
			[self showBattleMenu];
			break;
	}
}

- (void) itemMenuTouchedAtIndex:(NSInteger)buttonIndex
{
	int index = 0;
	for (Item *i in playerRef.inventory)
	{
		if (![i isEquipable]) {
			if (index == buttonIndex) 
			{
				// use this item
				[gameEngineRef item_handler:i];
				return;
			}
			else 
			{
				++index;
			}
		}
	}
	// We didn't find it, so we chose do nothing or there's an error
	[self showBattleMenu];
}

- (void) cspellMenuTouchedAtIndex:(NSInteger)buttonIndex
{
	NSString *buttonTitle = [cspellMenu buttonTitleAtIndex:buttonIndex];
	Spell *spell = nil;
	if ([buttonTitle rangeOfString:cspellMenuOptions[0]].length > 0) 
	{
		// Fire
		spell = [spellList objectAtIndex:START_PC_SPELLS + 25 /*Fire offset*/ + playerRef.abilities.spellBook[5] - 1];
	}
	else if ([buttonTitle rangeOfString:cspellMenuOptions[1]].length > 0) 
	{
		// Frost
		spell = [spellList objectAtIndex:START_PC_SPELLS + 30 /*Frost offset*/ + playerRef.abilities.spellBook[6] - 1];
	}
	else if ([buttonTitle rangeOfString:cspellMenuOptions[2]].length > 0) 
	{
		// Shock
		spell = [spellList objectAtIndex:START_PC_SPELLS + 35 /*Shock offset*/ + playerRef.abilities.spellBook[7] - 1];
	}
	else if ([buttonTitle rangeOfString:cspellMenuOptions[3]].length > 0) 
	{
		// Poison
		spell = [spellList objectAtIndex:START_PC_SPELLS + 40 /*Poison offset*/ + playerRef.abilities.spellBook[8] - 1];
	}
	else if ([buttonTitle rangeOfString:cspellMenuOptions[4]].length > 0) 
	{
		// Dark
		spell = [spellList objectAtIndex:START_PC_SPELLS + 45 /*Dark offset*/ + playerRef.abilities.spellBook[9] - 1];
	}
	else
	{
		//Do something else
		[self showSpellMenu];
		return;
	}
	[gameEngineRef spell_handler:spell];
}

- (void) dspellMenuTouchedAtIndex:(NSInteger)buttonIndex
{
	NSString *buttonTitle = [dspellMenu buttonTitleAtIndex:buttonIndex];
	Spell *spell;
	if ([buttonTitle rangeOfString:dspellMenuOptions[0]].length > 0) 
	{
		// Fire
		spell = [spellList objectAtIndex:START_PC_SPELLS + 0 /*Fire offset*/ + playerRef.abilities.spellBook[0] - 1];
	}
	else if ([buttonTitle rangeOfString:dspellMenuOptions[1]].length > 0) 
	{
		// Frost
		spell = [spellList objectAtIndex:START_PC_SPELLS + 5 /*Frost offset*/ + playerRef.abilities.spellBook[1] - 1];
	}
	else if ([buttonTitle rangeOfString:dspellMenuOptions[2]].length > 0) 
	{
		// Shock
		spell = [spellList objectAtIndex:START_PC_SPELLS + 10 /*Shock offset*/ + playerRef.abilities.spellBook[2] - 1];
	}
	else if ([buttonTitle rangeOfString:dspellMenuOptions[3]].length > 0) 
	{
		// Poison
		spell = [spellList objectAtIndex:START_PC_SPELLS + 15 /*Poison offset*/ + playerRef.abilities.spellBook[3] - 1];
	}
	else if ([buttonTitle rangeOfString:dspellMenuOptions[4]].length > 0) 
	{
		// Dark
		spell = [spellList objectAtIndex:START_PC_SPELLS + 20 /*Dark offset*/ + playerRef.abilities.spellBook[4] - 1];
	}
	else
	{
		//Do something else
		[self showSpellMenu];
		return;
	}
	[gameEngineRef spell_handler:spell];
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (actionSheet == battleMenu)
	{
		[self battleMenuTouchedAtIndex:buttonIndex];
	}
	else if (actionSheet == attackMenu)
	{
		[self attackMenuTouchedAtIndex:buttonIndex];
	}
	else if (actionSheet == castMenu)
	{
		[self castMenuTouchedAtIndex:buttonIndex];
	}
	else if (actionSheet == itemMenu)
	{
		[self itemMenuTouchedAtIndex:buttonIndex];
	}
	else if (actionSheet == cspellMenu)
	{
		[self cspellMenuTouchedAtIndex:buttonIndex];
	}
	else if	(actionSheet == dspellMenu)
	{
		[self dspellMenuTouchedAtIndex:buttonIndex];
	}
}

@end
