//
//  ItemTest.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ItemTest.h"


@implementation ItemTest

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

- (void) testInitExactItemWithName {
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
