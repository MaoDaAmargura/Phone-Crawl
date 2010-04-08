//
//  Merchant.h
//  Phone-Crawl
//
//  Created by Bucky24 on 4/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//	the Priest dialog manager, extending the functionality of the Npc class

#import <Foundation/Foundation.h>
#import "Npc.h"


@interface Priest : Npc {

}

// function to heal player when the player requests it
-(void) healPlayer:(Critter *)p;

@end
