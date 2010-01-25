//
//  Util.h
//  Phone-Crawl
//
//  Created by Benjamin Sangster on 1/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {FIRE,COLD,LIGHTNING,POISON,DARK} elemType;

//Items can always go in Bag, need non-bag slot to go in more
#define NUM_ARMOR_TYPES 2
typedef enum {
    HEAD = 0,
    CHEST = 1,
    LEFT = 2,
    RIGHT = 3,
    BOTH = 4,
    EITHER = 5,
    BAG = 6
} slotType;