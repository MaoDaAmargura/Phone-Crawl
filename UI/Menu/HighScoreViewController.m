//
//  HighScoreViewController.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HighScoreViewController.h"
#import "HighScoreController.h"

#define HIGH_SCORE_CELL_ID	@"HighScoreCellId"


@implementation HighScoreViewController


/*!
 @method		initWithScores
 @abstract		The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 @param			dict: expected to be a dictionary of (NSString => NSInteger)
 */
- (id)initWithScoreController:(HighScoreController*)scoreController
{
    if (self = [super initWithNibName:@"HighScoreViewController"])
	{
		highScoreController = [scoreController retain];
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
	[highScoreController release];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return [highScoreController numHighScores];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HIGH_SCORE_CELL_ID];
	if(!cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HIGH_SCORE_CELL_ID] autorelease];
		
		cell.textLabel.opaque = NO;
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.detailTextLabel.opaque = NO;
		cell.detailTextLabel.backgroundColor = [UIColor clearColor];
	}
	
	cell.textLabel.text = [highScoreController nameForIndex:indexPath.row];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [highScoreController scoreForIndex:indexPath.row]];
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

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)path
{
	return nil;
}

- (IBAction) doneViewing
{
	[self.view removeFromSuperview];
	[self autorelease];
}

@end
