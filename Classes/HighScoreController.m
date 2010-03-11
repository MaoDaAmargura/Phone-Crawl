//
//  HighScoreController.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HighScoreController.h"

#define HIGH_SCORES_DICT_USER_DEFAULTS_KEY	@"ab23682c99f204e57ac73c7500b9f"

@interface HighScoreController (Private)

- (void) sortNames;

@end


@implementation HighScoreController

- (id) init
{
	if(self = [super init])
	{
		scores = [[[NSUserDefaults standardUserDefaults] objectForKey:HIGH_SCORES_DICT_USER_DEFAULTS_KEY] retain];
		if(!scores)
		{
			scores = [[NSMutableDictionary alloc] initWithCapacity:6];
			[scores setObject:[NSNumber numberWithInt: 2500] forKey:@"Albeiro Invictus"];
			[scores setObject:[NSNumber numberWithInt: 2000] forKey:@"Warmaster Wijtman"];
			[scores setObject:[NSNumber numberWithInt: 1750] forKey:@"Gangster Forgeman"];
			[scores setObject:[NSNumber numberWithInt: 1500] forKey:@"Mapmaker King"];
			[scores setObject:[NSNumber numberWithInt: 1250] forKey:@"Beastmaster Fultz"];
			[scores setObject:[NSNumber numberWithInt: 10] forKey:@"Curator Tan"];
			
			[[NSUserDefaults standardUserDefaults] setObject:scores forKey:HIGH_SCORES_DICT_USER_DEFAULTS_KEY];
		}
		
		sortedNames = [[NSMutableArray alloc] init];
		
		[self sortNames];
	}
	return self;
}

- (void) sortNames
{
	NSMutableArray *temp = [NSMutableArray arrayWithArray:[scores allKeys]];
	[sortedNames removeAllObjects];
	int i = 0;
	while ([temp count] > 0 && i < 6)
	{
		int highest = 0;
		NSString *highName;
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
