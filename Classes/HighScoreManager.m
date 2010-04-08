//
//  HighScoreManager.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//  Control object for managing high score table; i.e. selecting scores to display, adding new scores, 
//		selecting scores to display.

#import "HighScoreManager.h"

#define HIGH_SCORES_DICT_USER_DEFAULTS_KEY	@"ab23682c99f204e57ac73c7500b9f"

@interface HighScoreManager (Private)

- (void) sortNames;

@end


@implementation HighScoreManager

- (id) init
{
	if(self = [super init])
	{
		scores = [[[NSUserDefaults standardUserDefaults] objectForKey:HIGH_SCORES_DICT_USER_DEFAULTS_KEY] retain];
		if(!scores)
		{
			scores = [[NSMutableDictionary alloc] initWithCapacity:6];
			[scores setObject:[NSNumber numberWithInt: 25000] forKey:@"Albeiro Invictus"];
			[scores setObject:[NSNumber numberWithInt: 20000] forKey:@"Warmaster Wijtman"];
			[scores setObject:[NSNumber numberWithInt: 17500] forKey:@"Gangster Forgeman"];
			[scores setObject:[NSNumber numberWithInt: 15000] forKey:@"Mapmaker King"];
			[scores setObject:[NSNumber numberWithInt: 12500] forKey:@"Beastmaster Fultz"];
			[scores setObject:[NSNumber numberWithInt: 10000] forKey:@"Curator Tan"];
			
			[[NSUserDefaults standardUserDefaults] setObject:scores forKey:HIGH_SCORES_DICT_USER_DEFAULTS_KEY];
		}
		
		sortedNames = [[NSMutableArray alloc] init];
		
		[self sortNames];
	}
	return self;
}

/*!
 @method		sortNames
 @abstract		sorts the scores we've kept track of so far
 @discussion	simple insertion sort. Order of Magnitude is not a problem
				because list size should never exceed 7-10 elements.
 */
- (void) sortNames
{
	NSMutableArray *temp = [NSMutableArray arrayWithArray:[scores allKeys]];
	[sortedNames removeAllObjects];
	int i = 0;
	while ([temp count] > 0 && i < 6)
	{
		int highest = 0;
		NSString *highName = @"";
		for (NSString *name in temp)
		{
			NSNumber *num = [scores objectForKey:name];
			int val = [num intValue];
			if (val > highest)
			{
				highest = val;
				highName = name;
			}
		}
		[sortedNames addObject:highName];
		int nameindex = [temp indexOfObject:highName];
		[temp removeObjectAtIndex: nameindex];
		++i;
	}
}

/*!
 @method		removeLowScores
 @abstract		drop scores that aren't in Top Six (save space)
 @discussion	drops all scores that didn't make it into sortedNames
				meaning they weren't Top Six scores
 */
- (void) removeLowScores
{
	NSMutableArray *temp = [NSMutableArray arrayWithArray:[scores allKeys]];
	for(NSString *item in sortedNames)
	{
		[temp removeObject:item];
	}
	[scores removeObjectsForKeys:temp];
}

- (void) insertPossibleNewScore:(int) score name:(NSString*)name
{
	if ([self scoreForIndex:5] <= score)
	{
		[scores setObject:[NSNumber numberWithInt:score] forKey:name];
		[self sortNames];
		[self removeLowScores];
		[[NSUserDefaults standardUserDefaults] setObject:scores forKey:HIGH_SCORES_DICT_USER_DEFAULTS_KEY];
	}
}

- (int) numHighScores
{
	return [sortedNames count];
}

- (NSString*) nameForIndex:(int) index
{
	return [sortedNames objectAtIndex:index];
}

- (int) scoreForName:(NSString*) name
{
	NSNumber *val = [scores objectForKey:name];
	if (!val) return -1;
	return [val intValue];
}

- (int) scoreForIndex:(int)index 
{
	NSNumber *val = [scores objectForKey:[sortedNames objectAtIndex:index]];
	return [val intValue];
}

- (void) dealloc
{
	[sortedNames release];
	[scores release];
	[super dealloc];
}

@end
