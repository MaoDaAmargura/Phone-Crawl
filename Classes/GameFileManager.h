//
//  GameFileManager.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Critter;

@interface GameFileManager : NSObject 
{

}

- (Critter*) loadCharacterFromFile:(NSString *)filename;

- (void) saveCharacter:(Critter*) player toFile:(NSString *)filename;


@end
