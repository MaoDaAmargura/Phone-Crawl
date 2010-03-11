//
//  HighScoreViewController.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCBaseViewController.h"

@class HighScoreController;

@interface HighScoreViewController : PCBaseViewController <UITableViewDelegate, UITableViewDataSource>
{
	HighScoreController *highScoreController;
	
	IBOutlet UITableView *scoresTable;
}

- (id)initWithScoreController:(HighScoreController*)scoreController;

- (IBAction) doneViewing;

@end
