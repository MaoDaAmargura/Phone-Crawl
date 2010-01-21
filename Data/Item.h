//
//  Item.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	ITEM_WEAPON,
	ITEM_ARMOR,
	ITEM_POTION} item_type;

@interface Item : NSObject 
{
	NSString *name;
	item_type type;
	int amount; // used for damage of weapon, defense of armor,
				// number of coins, ect
}

-(Item *)init:(NSString *)name :(item_type)type :(int)amount;
-(NSString *)getName;
-(item_type)getType;
-(int)getAmount;

@end
