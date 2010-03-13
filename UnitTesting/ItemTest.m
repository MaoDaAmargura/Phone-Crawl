//
//  ItemTest.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ItemTest.h"

static const NSString *itemName[5][4] = {
	{@"Fiery Sword",@"Sword of Fire",@"Scimitar of Fire",@"Fiery Scimitar"},
	{@"Icy Sword",@"Sword of Ice",@"Scimitar of Ice",@"Icy Scimitar"},
	{@"Shocking Sword",@"Sword of Lightning",@"Shocking Scimitar",@"Scimitar of Lightning"},
	{@"Venomous Sword",@"Sword of Poison",@"Venomous Scimitar",@"Scimitar of Poison"},
	{@"Dark Sword",@"Sword of Darkness",@"Dark Scimitar",@"Scimitar of Darkness"}
};

@implementation ItemTest

/*!
 @method		testItemNameForItemType
 @abstract		Simple unit test for Item's itemNameForItemType method
 @discussion	Tests to make sure that items with type = SWORD_ONE_HAND
				have the correct names for all elements
 @owner			Colin?
 */
- (void) testItemNameForItemType
{
	for(int i = FIRE; i <= DARK ; ++i) {
		Item *it = [[[Item alloc] initWithBaseStats:0 elemType:i 
										   itemType:SWORD_ONE_HAND] autorelease];
		STAssertTrue([it.name isEqualToString:itemName[i][0]] || 
					 [it.name isEqualToString:itemName[i][1]] ||
					 [it.name isEqualToString:itemName[i][2]] || 
					 [it.name isEqualToString:itemName[i][3]],
					 @"Item name: <%@> did not fit necessary pattern.");
	}
}
/*!
 @method		testInitWithBaseStats
 @abstract		Simple unit test for Item's initWithBaseStats constructor
 @discussion	tests that attributes of item explicitly set by call are true for the returned Item
 @owner			Austin
 */
- (void) testInitWithBaseStats
{
	elemType expectedElemType = FIRE;
	itemType expectedItemType = SWORD_ONE_HAND;
	int dungeonLevel = 2;
	
	Item *testItem = [[[Item alloc] initWithBaseStats:dungeonLevel 
											 elemType:expectedElemType 
											 itemType:expectedItemType] autorelease];
	
	STAssertTrue(testItem.element == expectedElemType, @"Item elemental type was different than expected.");
	STAssertTrue(testItem.type == expectedItemType, @"Item weapon type was different than expected.");
}

/*!
 @method		testIconNameForItemType
 @abstract		Unit test for static method that determines the display icon of an item by its type
 @discussion	Tests that all items this method handles are returned the proper icon name
 @owner			Austin
 */
- (void) testIconNameForItemType
{
	itemType itemIndex = SWORD_ONE_HAND;
	itemType itemBoundary = LIGHT_CHEST;
	for (; itemIndex <= itemBoundary; ++itemIndex) 
	{
		//Test each item type
		NSString *outcome = [Item iconNameForItemType:itemIndex];
		NSString *expected;
		switch (itemIndex) 
		{
			case SWORD_ONE_HAND: expected = ICON_SWORD_SINGLE; break;
			case SWORD_TWO_HAND: expected = ICON_SWORD_DOUBLE; break;
			case BOW:            expected = ICON_BOW; break;
			case DAGGER:         expected = ICON_DAGGER; break;
			case STAFF:          expected = ICON_STAFF; break;
			case SHIELD:         expected = ICON_SHIELD; break;
			case HEAVY_HELM:     expected = ICON_HELM_HEAVY; break;
			case HEAVY_CHEST:    expected = ICON_CHEST_HEAVY; break;
			case LIGHT_HELM:     expected = ICON_HELM_LIGHT; break;
			case LIGHT_CHEST:    expected = ICON_CHEST_LIGHT; break;
			default:			 expected = nil; break;
		}
		STAssertTrue([outcome isEqualToString:expected], [NSString stringWithFormat:@"Expected icon name: %@ for Item type: %d but received icon name: %@", expected, itemIndex, outcome]);
	}
}

/*!
 @method		testScoreItem
 @abstract		tests a couple cases in score item
 @discussion	covers all boundary cases
 @owner			Austin
 */
- (void) testGetItemValue
{
	Item *item = nil;
	int value, expectedPointVal;
	
	//Test function when no item is given
	value = [Item getItemValue:item];
	STAssertTrue(value == -1, @"(nil) item should have invalid score of -1.");
	
	//Test sword value
	item = [[[Item alloc] initWithBaseStats:2 elemType:FIRE itemType:SWORD_ONE_HAND] autorelease];
	expectedPointVal = item.damage + item.elementalDamage + (item.hp + item.shield + item.mana) * 2 + (item.fire + item.cold + item.lightning + item.poison + item.dark) * 1.5 + item.armor;
	value = [Item getItemValue:item];
	STAssertTrue(value == expectedPointVal, @"Item's value was not calculated according to sword formula.");
	
	//Test Bow formula
	item = [[[Item alloc] initWithBaseStats:5 elemType:COLD itemType:BOW] autorelease];
	expectedPointVal = item.damage + item.elementalDamage + item.range * 20 + (item.hp + item.shield + item.mana) * 2 + (item.fire + item.cold + item.lightning + item.poison + item.dark) * 1.5 + item.armor;
	value = [Item getItemValue:item];
	STAssertTrue(value == expectedPointVal, @"Item's value was not calculated according to bow formula.");


	//Test scroll handling
	item = [[[Item alloc] initWithBaseStats:3 elemType:DARK itemType:SCROLL] autorelease];
	expectedPointVal = 2000;
	value = [Item getItemValue:item];
	STAssertTrue(value == expectedPointVal, @"Item's value was not properly decided as a scroll.");

	//No need to test invalid Item objects because they cannot be created.
}



/*!
 @method		testInitExactItemWithName
 @abstract		Unit test for Item's initExactItemWithName constructor
 @discussion	tests that all attributes of returned item line up with the stats that were specified in the call
 @owner			Robbert
 */
- (void) testInitExactItemWithName 
{
	NSString *expectedItemName = @"Wand of awesome coldness!";
	NSString *expectedIconFileName = @"wand1.png";
	itemQuality expectedItemQuality = REGULAR;
	slotType expectedSlot = BAG;
	elemType expectedElemType = COLD;
	itemType expectedItemType = WAND;
	int expectedDamage = 15;
	int expectedElementalDamage = 30;
	int expectedCharges = 4;
	int expectedRange = 10;
	int expectedHp = 100;
	int expectedShield = 100;
	int expectedMana = 15;
	int expectedFire = 5;
	int expectedCold = 10;
	int expectedLightning = 15;
	int expectedPoison = 20;
	int expectedDark = 25;
	int expectedArmor = 30;
	int expectedEffectSpellId = 10;
	
	Item *testItem = [[[Item alloc] initExactItemWithName:expectedItemName
											 iconFileName:expectedIconFileName 
											  itemQuality:expectedItemQuality
												 itemSlot:expectedSlot
												 elemType:expectedElemType
												 itemType:expectedItemType
												   damage:expectedDamage
										  elementalDamage:expectedElementalDamage
												  charges:expectedCharges
													range:expectedRange
													   hp:expectedHp
												   shield:expectedShield
													 mana:expectedMana
													 fire:expectedFire
													 cold:expectedCold
												lightning:expectedLightning
												   poison:expectedPoison
													 dark:expectedDark
													armor:expectedArmor
											effectSpellId:expectedEffectSpellId] autorelease];
	
	STAssertTrue(testItem.name == expectedItemName, @"Item name was different from expected");
	STAssertTrue(testItem.icon == expectedIconFileName, @"Icon name was different from expected");
	STAssertTrue(testItem.damage == expectedDamage, @"Item damage was different from expected");
	STAssertTrue(testItem.elementalDamage == expectedElementalDamage, @"Item elemental damage was different from expected");
	STAssertTrue(testItem.range == expectedRange, @"Item range was different from expected");
	STAssertTrue(testItem.charges == expectedCharges, @"Item charge was different from expected");
	STAssertTrue(testItem.quality == expectedItemQuality, @"Item quality was different from expected");
	STAssertTrue(testItem.slot == expectedSlot, @"Item slot was different from expected");
	STAssertTrue(testItem.element == expectedElemType, @"Item element was different from expected");
	STAssertTrue(testItem.type == expectedItemType, @"Item type was different from expected");
	STAssertTrue(testItem.effectSpellId == expectedEffectSpellId, @"Item spell id was different from expected");
	STAssertTrue(testItem.hp == expectedHp, @"Item hp was different from expected");
	STAssertTrue(testItem.shield == expectedShield, @"Item shield was different from expected");
	STAssertTrue(testItem.mana == expectedMana, @"Item mana was different from expected");
	STAssertTrue(testItem.fire == expectedFire, @"Item fire was different from expected");
	STAssertTrue(testItem.cold == expectedCold, @"Item cold was different from expected");
	STAssertTrue(testItem.lightning == expectedLightning, @"Item lightning was different from expected");
	STAssertTrue(testItem.poison == expectedPoison, @"Item poison was different from expected");
	STAssertTrue(testItem.dark == expectedDark, @"Item dark was different from expected");
	STAssertTrue(testItem.armor == expectedArmor, @"Item armor was different from expected");
}


@end
