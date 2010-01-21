//
//  Player.m
//  Phone-Crawl
//
//  Created by Bucky24 on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Player.h"


@implementation Player

-(Player *)init {
	self = [super init];
	if (self) {
		fireResist = 0;
		coldResist = 0;
		lightningResist = 0;
		poisonResist = 0;
		darkResist = 0;
		magicResist = 0;
		
		strength = 1;
		willpower = 1;
		dexterity = 1;
		maxMana = 5;
		mana = 5;
		
		aggroRange = 4;
		
		maxHp = 20;
		hp = 20;
		
		maxShield = 10;
		shield = 10;
		
		armorBody = nil;
		armorHead = nil;
		weaponLeft = nil;
		weaponRight = nil;
		return self;
	}
	return nil;
}

-(int)getStrength {
	return strength;
}

-(int)getHp {
	return hp;
}

-(int)getShield {
	return shield;
}

-(Item *)getArmorBody {
	return armorBody;
}

-(Item *)getArmorHead {
	return armorHead;
}

-(Item *)getWeaponLeft {
	return weaponLeft;
}

-(Item *)getWeaponRight {
	return weaponRight;
}

-(void)setHp:(int)hp {
	self.hp = hp;
}
	
-(void)setShield:(int)shield {
	self.shield = shield;
}
	 

@end
