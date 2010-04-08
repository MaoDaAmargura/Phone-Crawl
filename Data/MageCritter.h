//
//  MageCritter.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Critter.h"

@interface MageCritter : Critter
{
	BOOL debuffMode;
	BOOL haveWeakened;
	BOOL haveSlowed;
	BOOL haveHastened;
}

@end
