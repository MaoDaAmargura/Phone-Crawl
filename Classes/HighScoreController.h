//
//  HighScoreController.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
typedef enum 
{
	HighScoreSortAlphabetically,
	HighScoreSortHighest,
	HighScoreSortLowest,
} HighScoreSortStyle;
*/

@interface HighScoreController : NSObject 
{
	NSMutableArray *sortedNames;
	NSMutableDictionary *scores;
}

- (id) init;

- (int) numHighScores;

- (void) insertPossibleNewScore:(int) score name:(NSString*)name;

- (int) scoreForName:(NSString*) name;
- (NSString*) nameForIndex:(int) index;
- (int) scoreForIndex:(int)index;
//- (int) scoreForIndex:(int)index sortStyle:(HighScoreSortStyle)style;

@end
