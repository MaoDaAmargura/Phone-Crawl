//
//  WorldView.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCBaseViewController.h"


@protocol WorldViewDelegate

- (void) worldTouchedAt:(CGPoint)point;
- (void) worldSelectedAt:(CGPoint)point;

@end



@interface WorldView : PCBaseViewController
{
	IBOutlet UIImageView *mapImageView;
}

@property (nonatomic, retain) UIImageView *mapImageView;

@end
