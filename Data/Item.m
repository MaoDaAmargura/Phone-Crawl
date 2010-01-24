//
//  Item.m
//  Phone-Crawl
//
//  Created by Benjamin Sangster on 1/23/10. 
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Item.h"


@implementation Item

-(Item *)init:(NSString *)n :(item_type)t :(int)a {
	if (self = [super init]) {
		name = n;
		type = t;
		amount = a;
		return self;
	}
	return nil;
}

-(NSString *)getName {
	return name;
}

-(item_type)getType {
	return type;
}

-(int)getAmount {
	return amount;
}


@end
