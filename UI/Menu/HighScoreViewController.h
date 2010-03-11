//
//  HighScoreViewController.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCBaseViewController.h"

@interface HighScoreViewController : PCBaseViewController <UITableViewDelegate, UITableViewDataSource>
{
	NSDictionary *scores;
	NSMutableArray *sortedNames;
	IBOutlet UITableView *scoresTable;
}

- (id)initWithScores:(NSDictionary*)dict;

@end
