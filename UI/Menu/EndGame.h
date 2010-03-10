//
//  EndGame.h
//  Phone-Crawl
//
//  Created by Bucky24 on 3/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PCBaseViewController.h"

@class Engine;

@interface EndGame : PCBaseViewController {
	IBOutlet UILabel *score;
	IBOutlet UILabel *cost;
	Engine *engine;
}

- (id) init;

- (IBAction) clickContinue;
- (IBAction) clickEnd;

- (void) update;

@property (retain, nonatomic) Engine *engine;

@end
