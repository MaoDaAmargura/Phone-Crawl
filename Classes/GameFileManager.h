//
//  GameFileManager.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Creature;

@interface GameFileManager : NSObject 
{

}

- (Creature*) loadCharacterFromFile:(NSString *)filename;

- (void) saveCharacter:(Creature*) player toFile:(NSString *)filename;


@end
