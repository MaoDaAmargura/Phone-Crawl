//
//  PCBaseViewController.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 1/19/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PCBaseViewController : UIViewController 
{
	id delegate;
}

@property (nonatomic, retain) id delegate;

- (id) initWithNibName:(NSString *)nibNameOrNil;

- (void) flipToView:(UIView*) nView WithTransition:(UIViewAnimationTransition) transition;

@end
