//
//  Creature.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Util.h"

@interface Creature : NSObject 
{
	Coord *location;
}

@property (nonatomic, retain) Coord *location;

@end
