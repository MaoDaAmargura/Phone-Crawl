//
//  Tile.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Sorry Nathan, I kept looking for tile in the wrong places so I got sick of it not being it's own class. 
 */

typedef enum {
	town, orcMines, morlockTunnels, crypts, undergroundForest, abyss
} levelType;

typedef enum {
	tileNone, tileGrass, tileRockFloor, tileRockWall
} tileType;

NSMutableArray *tileImageArray;

@interface Tile : NSObject {
	bool blockView;
	bool blockMove;
	tileType type;
}
@property (nonatomic) bool blockView;
@property (nonatomic) bool blockMove;
@property (nonatomic) tileType type;

+ (void) initialize;
+ (UIImage*) imageForType:(tileType)type;

@end
