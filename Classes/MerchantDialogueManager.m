//
//  MerchantDialogueManager.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MerchantDialogueManager.h"

#import "Engine.h"
#import "Item.h"
#import "Spell.h"

#define NUM_ITEMS_TO_SHOW	4

#define NEXT_BUTTON_TITLE	@"Next Items"
#define PREV_BUTTON_TITLE	@"Previous Items"
#define DONE_BUTTON_TITLE	@"Done"
#define BUY_BUTTON_TITLE	@"Buy"
#define SELL_BUTTON_TITLE	@"Sell"
#define BACK_BUTTON_TITLE	@"Back"


@interface MerchantDialogueManager (MenuHandling)

- (void) showMainMenu;
- (void) showBuyMenu;
- (void) showSellMenu;

@end



@implementation MerchantDialogueManager

- (id) initWithView:(UIView*)target andDelegate:(id)del
{
	if (self = [super init])
	{
		targetViewRef = target;
		delegate = del;
	}
	return self;
}


- (void) interactionWithInventory:(NSMutableArray*)inv
{
	mostRecentInv = inv;
	currentInvIndex = 0;
	[self showMainMenu];
	
}

- (void) initialActionSheetTappedAtIndex:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0: // Buy
			[self showBuyMenu];
			break;
		case 1:
			[self showSellMenu];
		default:
			break;
	}
}

- (void) sellMenuSheetTappedAtIndex:(NSInteger)buttonIndex
{
	if ([[sellMenu buttonTitleAtIndex:buttonIndex] isEqualToString:PREV_BUTTON_TITLE])
	{
		currentInvIndex -= NUM_ITEMS_TO_SHOW;
		[self showSellMenu];
	}
	else if ([[sellMenu buttonTitleAtIndex:buttonIndex] isEqualToString:NEXT_BUTTON_TITLE])
	{
		currentInvIndex += NUM_ITEMS_TO_SHOW;
		[self showSellMenu];
	}
	else if	([[sellMenu buttonTitleAtIndex:buttonIndex] isEqualToString:BACK_BUTTON_TITLE])
	{
		[self showMainMenu];
	}
	else 
	{
		// Selling an item
		int itemIndex = buttonIndex;
		if ([[sellMenu buttonTitleAtIndex:0] isEqualToString:PREV_BUTTON_TITLE]) 
			--itemIndex;
		[delegate sellItem:[mostRecentInv objectAtIndex:currentInvIndex + itemIndex]];
	}

}

- (void) buyMenuSheetTappedAt:(NSInteger)buttonIndex
{
	switch (buttonIndex) {
		case 0: // health potion
			[delegate buyItem:[[[Item alloc] initExactItemWithName : @"Health Potion"
													   iconFileName: @"potion-red-I.png"
														itemQuality: REGULAR itemSlot: BAG 
														   elemType: DARK    itemType: POTION
															 damage: 1 elementalDamage:0
															charges:1 range:1 hp:0  shield:0 
															   mana:0 fire:0 cold:0 lightning:0
															 poison:0 dark:0 armor: 0
													  effectSpellId: ITEM_HEAL_SPELL_ID] autorelease]];
			break;
		case 1: // mana potion
			[delegate buyItem:[[[Item alloc] initExactItemWithName : @"MPot1"
													   iconFileName: @"potion-blue-I.png"
														itemQuality: REGULAR itemSlot: BAG 
														   elemType: DARK    itemType: POTION
															 damage: 1 elementalDamage:0
															charges:1 range:1 hp:0  shield:0 
															   mana:0 fire:0 cold:0 lightning:0
															 poison:0 dark:0 armor: 0
													  effectSpellId: ITEM_MANA_SPELL_ID] autorelease]];
			break;
		case 2: // sword
			[delegate buyItem:[[[Item alloc] initExactItemWithName:@"Sword"
													  iconFileName:@"swordsingle.png" 
													   itemQuality:REGULAR itemSlot:RIGHT
														  elemType:FIRE  itemType:SWORD_ONE_HAND
															damage:5 elementalDamage:0
														   charges:0 range:1
																hp:0 shield:0 mana:0
															  fire:0 cold:0 lightning:0
															poison:0 dark:0 armor:0
													 effectSpellId:0] autorelease]];
			break;

		default:
			[self showMainMenu];
			break;
	}
}

- (void) showMainMenu
{
	initial = [[[UIActionSheet alloc] initWithTitle:@"What can I do fer ya?"
										   delegate:self 
								  cancelButtonTitle:nil
							 destructiveButtonTitle:nil
								  otherButtonTitles:@"Buy", @"Sell", @"Done", nil] autorelease];
	[initial showInView:targetViewRef];
}
						 
- (void) showBuyMenu
{
	buyMenu = [[[UIActionSheet alloc] initWithTitle:@"What would you like?"
										   delegate:self
								  cancelButtonTitle:nil
							 destructiveButtonTitle:nil
								  otherButtonTitles:@"Health Potion", @"Mana Potion", @"Sword", BACK_BUTTON_TITLE, nil] autorelease];
	[buyMenu showInView:targetViewRef];
}

- (void) showSellMenu
{
	sellMenu = [[[UIActionSheet alloc] initWithTitle:@"What do you want to sell?"
											delegate:self
								   cancelButtonTitle:nil
							  destructiveButtonTitle:nil
								   otherButtonTitles:nil] autorelease];
	if ( currentInvIndex > 0 )
		[sellMenu addButtonWithTitle:PREV_BUTTON_TITLE];
	BOOL more = NO;
	for (int x = currentInvIndex, y = 0; x < [mostRecentInv count]; ++x, ++y) 
	{
		if (y == NUM_ITEMS_TO_SHOW)
		{
			more = YES;
			break;
		}
		[sellMenu addButtonWithTitle:[[mostRecentInv objectAtIndex: x] name]];
		
	}
	if ( more )
		[sellMenu addButtonWithTitle:NEXT_BUTTON_TITLE];
	[sellMenu addButtonWithTitle:BACK_BUTTON_TITLE];
	
	[sellMenu showInView:targetViewRef];
}
						 

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (actionSheet == initial) 
	{
		[self initialActionSheetTappedAtIndex:buttonIndex];
	}
	else if (actionSheet == sellMenu)
	{
		[self sellMenuSheetTappedAtIndex:buttonIndex];
	}
	else if (actionSheet == buyMenu)
	{
		[self buyMenuSheetTappedAt:buttonIndex];
	}
}


@end
