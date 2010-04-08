//
//  GameFileManager.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//	GameFileManager is responsible for saving and loading game data

#import <Foundation/Foundation.h>

@class Critter;

@interface GameFileManager : NSObject 
{

}

// load and save functions
- (Critter*) loadCharacterFromFile:(NSString *)filename;

- (void) saveCharacter:(Critter*) player toFile:(NSString *)filename;


@end
