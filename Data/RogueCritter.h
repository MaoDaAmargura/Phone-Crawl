//
//  RogueCritter.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Critter.h"

@interface RogueCritter : Critter
{
	BOOL haveWeakened;
	BOOL havePoisoned;
	BOOL haveSlowed;
}

@end
