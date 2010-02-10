//
//  Battle.h
//  Phone-Crawl
//
//  Created by Bucky24 on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Creature.h"
#import "Util.h" // for elemType
#import "Item.h"
#include <stdlib.h>

typedef enum {
	QUICK_ATTACK,
	STANDARD_ATTACK,
	FATAL_SWING
} Action;

@interface Battle : NSObject {
	
}

+ (void)doAttack:(Creature *)attacker :(Creature *)defender :(Action)action;
+ (float)getDamage:(Action)action;

@end
