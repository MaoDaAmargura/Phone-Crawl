//
//  WorldView.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCBaseViewController.h"

@protocol WorldViewDelegate;


@interface WorldView : PCBaseViewController
{
	IBOutlet UIImageView *mapImageView;
}

- (void) setDelegate:(id<WorldViewDelegate>) delegate;

@property (nonatomic, retain) IBOutlet UIImageView *mapImageView;

@end

@protocol WorldViewDelegate

- (void) worldView:(WorldView*) wView touchedAt:(CGPoint)point;
- (void) worldView:(WorldView*) wView selectedAt:(CGPoint)point;
- (void) worldViewDidLoad:(WorldView*) wView;

@end
