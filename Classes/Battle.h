//
//  Battle.h
//  Phone-Crawl
//
//  Created by Bucky24 on 1/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Creature.h"


@interface Battle : NSObject {
	
}

+ (void)doAttack:(Creature *)attacker :(Creature *)defender;

@end
