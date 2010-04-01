//
//  GameFileManager.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameFileManager.h"

#import "Critter.h"
#import "Critter+LoadExtensions.h"
#import "Item.h"
#import "Skill.h"
#import "Spell.h"

@interface GameFileManager (Helper)

- (void) writeItem:(Item *)item file:(FILE *)file;

- (Item *) loadItemFromFile:(NSString *)datastring;

- (NSString *) getArrayString:(NSMutableArray *)array;

@end


@implementation GameFileManager


- (Critter*) loadCharacterFromFile:(NSString *)filename 
{
	const char *fname = [filename cStringUsingEncoding:NSASCIIStringEncoding];
	FILE *file;
	if (!(file = fopen(fname,"r"))) {
		NSLog(@"Unable to open file for reading: %@", fname);
		return nil;
	}
	char line[150];
	NSMutableArray *data = [NSMutableArray arrayWithCapacity:10];
	while (fgets(line,150,file) != NULL) {
		// cut off trailing newline
		if (line[strlen(line)-1] == '\n') {
			line[strlen(line)-1] = '\0';
		}
		[data addObject:[NSString stringWithFormat:@"%s",line]];
		printf("%s\n",line);
	}
	if ([data count] == 0) {
		[[[[UIAlertView alloc] initWithTitle:@"No Save Games" message:@"You don't have a saved character." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] autorelease] show];
		return nil;
	}
	// maxhealth
	// maxshield
	// maxmana
	// maxturnspeed
	// [abilitiesbegin]
	// id||level
	// ...
	// [spellsbegin]
	// id||level
	// ...
	// [inventorybegin]
	// name||icon||equipable||damage||elementaldamage||range||charges||pointvalue||quality||slot||element||type
	// ||spellid||hp||shield||mana||fire||cold||lightning||poison||dark||armor
	Critter *player = [Critter alloc];
	NSString *playerName = [self getArrayString:data];
	NSString *playerIcon = [self getArrayString:data];
	int money = [[self getArrayString:data] intValue];
	int playerLevel = [[self getArrayString:data] intValue];
	[player initWithLevel:playerLevel];
	player.stringName = playerName;
	player.stringIcon = playerIcon;
	player.money = money;
	player.deathPenalty = [[self getArrayString:data] intValue];
	player.experience = [[self getArrayString:data] intValue];
	player.abilityPoints = [[self getArrayString:data] intValue];
	int head = [[self getArrayString:data] intValue];
    int chest = [[self getArrayString:data] intValue];
	int rhand = [[self getArrayString:data] intValue];
	int lhand = [[self getArrayString:data] intValue];
	[player setHealth:[[self getArrayString:data] intValue]];
	[player setShield:[[self getArrayString:data] intValue]];
	[player setMana:[[self getArrayString:data] intValue]];
	player.turnSpeed = [[self getArrayString:data] intValue];
	NSString *sentinel = [self getArrayString:data];
	if ([sentinel isEqualToString:@"[abilitiesbegin]"]) {
		for (int i=0; i<NUM_PLAYER_SKILL_TYPES; ++i) 
		{
			player.abilities.skills[i] = [[self getArrayString:data] intValue];
		}
	}
	else {
		[[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Problem Loading Save Game - 001" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] autorelease] show];
		return nil;
	}
	sentinel = [self getArrayString:data];
	if ([sentinel isEqualToString:@"[spellsbegin]"]) {
		for (int i =0; i<NUM_PLAYER_SPELL_TYPES; ++i) {
			player.abilities.spells[i] = [[self getArrayString:data] intValue];
		}
	}
	else {
		[[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Problem Loading Save Game - 002" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] autorelease] show];
		return nil;
	}
	
	sentinel = [self getArrayString:data];
	if ([sentinel isEqualToString:@"[inventorybegin]"]) 
	{
		NSString *line = [self getArrayString:data];
		int numItems = [line intValue];
		NSLog(@"%d", numItems);
		
		for (int i=0; i<numItems; ++i)
		{
			line = [self getArrayString:data];
			Item *it = [self loadItemFromFile:line];
			if (it) {
				[player gainItem: it];
			}
		}
	}
	else {
		[[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Problem Loading Save Game - 003" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] autorelease] show];
		return nil;
	}
	
	sentinel = [self getArrayString:data];
	if (head >= 0)
		[player equipItem: [[player inventoryItems] objectAtIndex:head]];

	if (chest >= 0) 
		[player equipItem:[[player inventoryItems] objectAtIndex:chest]];

	if (rhand >= 0) 
		[player equipItem:[[player inventoryItems] objectAtIndex:rhand]];
	
	if (lhand >= 0) 
		[player equipItem:[[player inventoryItems] objectAtIndex:lhand]];
	
	fclose(file);
	return [player autorelease];
}

/*Item *i = [self loadItemFromFile:line];
 if (i != nil) {
 [player.inventory addObject:i];
 }
 line = [self getArrayString:data];
 }
 sentinel = line;
 */

- (Item *) loadItemFromFile:(NSString *)datastring 
{
	//NSString *datastring = [self getArrayString:array];
	Item *ret = nil;
	if (![datastring isEqualToString:@"null"]) {
		NSArray *data = [datastring componentsSeparatedByString:@"||"];
		if ([data count] < 22) {
			NSLog(@"Error: item parsed improperly");
			return nil;
		}
		NSString *name = [data objectAtIndex:0];
		NSString *icon = [data objectAtIndex:1];
		//BOOL equippable = [data objectAtIndex:2] == @"YES" ? YES : NO;
		int damage = [[data objectAtIndex:3] intValue];
		int elementalDamage = [[data objectAtIndex:4] intValue];
		int range = [[data objectAtIndex:5] intValue];
		int charges = [[data objectAtIndex:6] intValue];
		int pointValue = [[data objectAtIndex:7] intValue];
		int quality = [[data objectAtIndex:8] intValue];
		int slot = [[data objectAtIndex:9] intValue];
		int element = [[data objectAtIndex:10] intValue];
		int type = [[data objectAtIndex:11] intValue];
		int spellId = [[data objectAtIndex:12] intValue];
		int hp = [[data objectAtIndex:13] intValue];
		int shield = [[data objectAtIndex:14] intValue];
		int mana = [[data objectAtIndex:15] intValue];
		int fire = [[data objectAtIndex:16] intValue];
		int cold = [[data objectAtIndex:17] intValue];
		int lightning = [[data objectAtIndex:18] intValue];
		int poison = [[data objectAtIndex:19] intValue];
		int dark = [[data objectAtIndex:20] intValue];
		int armor = [[data objectAtIndex:21] intValue];
		
		ret = [[[Item alloc] initExactItemWithName:name
									 iconFileName: icon
									  itemQuality: quality
										 itemSlot: slot 
										 elemType: element 
										 itemType: type 
										   damage: damage 
								  elementalDamage: elementalDamage
										  charges: charges
											range: range
											   hp: hp
										   shield: shield 
											 mana: mana 
											 fire: fire 
											 cold: cold 
										lightning: lightning 
										   poison: poison 
											 dark: dark 
											armor: armor
									effectSpellId: spellId] autorelease];
		ret.pointValue = pointValue;
	}
	return ret;
}

- (NSString *) getArrayString:(NSMutableArray *)array {
	NSString *ret;
	if ([array count] > 0) {
		ret = [array objectAtIndex:0];
		[array removeObjectAtIndex:0];
	} else {
		ret = @"";
	}
	return ret;
}

- (void) saveCharacter:(Critter*) player toFile:(NSString *)filename 
{
	const char *fname = [filename cStringUsingEncoding:NSASCIIStringEncoding];
	FILE *file;
	if (!(file = fopen(fname,"w"))) {
		NSLog(@"Unable to open file for writing: ");
		NSLog(@"%s", filename);
		return;
	}
	// name
	// money
	// level
	// experience points
	// head (index only)
	// chest
	// rhand
	// lhand
	// maxhealth
	// maxshield
	// maxmana
	// turnspeed
	// maxturnspeed
	// [abilitiesbegin]
	// id||level
	// ...
	// [spellsbegin]
	// id||level
	// ...
	// [inventorybegin]
	// name||icon||equipable||damage||elementaldamage||range||charges||pointvalue||quality||slot||element||type
	// ||spellid||hp||shield||mana||fire||cold||lightning||poison||dark||armor
	fputs([player.stringName cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([player.stringIcon cStringUsingEncoding:NSASCIIStringEncoding], file);
	fputs("\n", file);
	fputs([[NSString stringWithFormat:@"%d",player.money] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d",player.level] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d", player.deathPenalty] cStringUsingEncoding:NSASCIIStringEncoding], file);
	fputs("\n", file);
	fputs([[NSString stringWithFormat:@"%d", player.experience] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d", player.abilityPoints] cStringUsingEncoding:NSASCIIStringEncoding], file);
	fputs("\n", file);
	
	int hindex = [[player inventoryItems] indexOfObject:player.equipment.head];
	if (hindex == NSNotFound) hindex = -1;
	fputs([[NSString stringWithFormat:@"%d",hindex] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	int cindex = [[player inventoryItems] indexOfObject:player.equipment.chest];
	if (cindex == NSNotFound) cindex = -1;
	fputs([[NSString stringWithFormat:@"%d",cindex] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	int rindex = [[player inventoryItems] indexOfObject:player.equipment.rhand];
	if (rindex == NSNotFound) rindex = -1;
	fputs([[NSString stringWithFormat:@"%d",rindex] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	int lindex = [[player inventoryItems] indexOfObject:player.equipment.lhand];
	if (lindex == NSNotFound) lindex = -1;
	fputs([[NSString stringWithFormat:@"%d",lindex] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	//fputs([[NSString stringWithFormat:@"%d",player.current.health] cStringUsingEncoding:NSASCIIStringEncoding],file);
	//fputs("\n",file);
	//fputs([[NSString stringWithFormat:@"%d",player.current.shield] cStringUsingEncoding:NSASCIIStringEncoding],file);
	//fputs("\n",file);
	//fputs([[NSString stringWithFormat:@"%d",player.current.mana] cStringUsingEncoding:NSASCIIStringEncoding],file);
	//fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d",player.max.hp] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d",player.max.sp] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d",player.max.mp] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	//fputs([[NSString stringWithFormat:@"%d",player.current.turnSpeed] cStringUsingEncoding:NSASCIIStringEncoding],file);
	//fputs("\n",file);
	fputs([[NSString stringWithFormat:@"%d",player.turnSpeed] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	fputs([@"[abilitiesbegin]" cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	for (int i=0; i<NUM_PLAYER_SKILL_TYPES; i++)
	{
		int ability = player.abilities.skills[i];
		fputs([[NSString stringWithFormat:@"%d", ability]cStringUsingEncoding:NSASCIIStringEncoding], file);
		fputs("\n", file);
	}
	fputs([@"[spellsbegin]" cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("\n",file);
	for (int i=0; i<NUM_PLAYER_SPELL_TYPES; i++) 
	{
		int ability = player.abilities.spells[i];
		fputs([[NSString stringWithFormat:@"%d", ability]cStringUsingEncoding:NSASCIIStringEncoding], file);
		fputs("\n", file);
	}
	fputs("[inventorybegin]",file);
	fputs("\n",file);
	int numItems = [[player inventoryItems] count];
	fputs([[NSString stringWithFormat:@"%d", numItems] cStringUsingEncoding:NSASCIIStringEncoding], file);
	fputs("\n", file);
	
	for (Item *i in [player inventoryItems]) {
		[self writeItem:i file:file];
	}
	fclose(file);
}

// name||icon||equipable||damage||elementaldamage||range||charges||pointvalue||quality||slot||element||type
// ||spellid||hp||shield||mana||fire||cold||lightning||poison||dark||armor

- (void) writeItem:(Item *)item file:(FILE *)file {
	//fputs([@"item||" cStringUsingEncoding:NSASCIIStringEncoding],file);
	if (item == nil) {
		fputs([@"null\n" cStringUsingEncoding:NSASCIIStringEncoding],file);
		return;
	}
	fputs([item.name cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([item.icon cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	if (item.isEquipable) {
		fputs([@"YES" cStringUsingEncoding:NSASCIIStringEncoding],file);
		fputs("||",file);
	} else {
		fputs([@"NO" cStringUsingEncoding:NSASCIIStringEncoding],file);
		fputs("||",file);	
	}
	fputs([[NSString stringWithFormat:@"%d",item.damage] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.elementalDamage] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.range] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.charges] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.damage] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.pointValue] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.slot] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.element] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.type] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.effectSpellId] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.hp] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.shield] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.mana] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.fire] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.cold] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.lightning] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.poison] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.dark] cStringUsingEncoding:NSASCIIStringEncoding],file);
	fputs("||",file);
	fputs([[NSString stringWithFormat:@"%d",item.armor] cStringUsingEncoding:NSASCIIStringEncoding],file);
	
	fputs("\n",file);
}




@end
