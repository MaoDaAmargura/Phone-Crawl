//
//  Player.h
//  Phone-Crawl
//
//  Created by Bucky24 on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"


@interface Player : NSObject {
	
	int fireResist;
	int coldResist;
	int poisonResist;
	int lightningResist;
	int darkResist;
	int magicResist;
	
	int strength;
	int willpower;
	int dexterity;
	int maxMana;
	int mana;
	
	int aggroRange;
	
	int maxHp;
	int hp;
	
	int maxShield;
	int shield;
	
	Item *armorBody;
	Item *armorHead;
	
	Item *weaponLeft;
	Item *weaponRight;
}

-(Player *)init;
-(int)getStrength;
-(int)getHp;
-(int)getShield;
-(Item *)getArmorBody;
-(Item *)getArmorHead;
-(Item *)getWeaponLeft;
-(Item *)getWeaponRight;

-(void)setHp:(int)hp;
-(void)setShield:(int)shield;
@end
