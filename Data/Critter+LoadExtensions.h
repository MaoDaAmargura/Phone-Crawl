//
//  Critter+LoadExtensions.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Critter.h"

@interface Critter (LoadExtensions)

@property (nonatomic) int experience;

- (void) setHealth:(int)hp;
- (void) setShield:(int)sp;
- (void) setMana:(int)mp;

@end
