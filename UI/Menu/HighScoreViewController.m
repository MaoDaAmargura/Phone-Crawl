//
//  HighScoreViewController.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HighScoreViewController.h"

#define HIGH_SCORE_CELL_ID	@"HighScoreCellId"


@implementation HighScoreViewController

- (void) sortNames
{
	NSMutableArray *temp = [NSMutableArray arrayWithArray: sortedNames];
	[sortedNames removeAllObjects];
	while ([temp count] > 0)
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
		
	}
}

/*!
 @method		initWithScores
 @abstract		The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 @param			dict: expected to be a dictionary of (NSString => NSInteger)
 */
- (id)initWithScores:(NSDictionary*)dict
{
    if (self = [super initWithNibName:@"HighScoreViewController"])
	{
		scores = [dict copy];
		sortedNames = [[NSMutableArray arrayWithArray: [scores allKeys]] retain];
		[self sortNames];
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
    [super dealloc];
	[scores release];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return [scores count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HIGH_SCORE_CELL_ID];
	if(!cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HIGH_SCORE_CELL_ID] autorelease];
	}
	
	NSString *charName = [sortedNames objectAtIndex:[indexPath row]];
	
	cell.textLabel.text = charName;
	NSNumber *score = [scores objectForKey:charName];
	cell.detailTextLabel.text = [score stringValue];
	cell.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui-inventorybg.png"]] autorelease];
	
	return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"High Scores";
}

#pragma mark -
#pragma mark UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIImageView *highScoreImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ui-button-highscores.png"]] autorelease];
	return highScoreImage;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 35;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 50;
}

@end
