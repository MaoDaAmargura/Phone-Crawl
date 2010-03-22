//
//  LoadingView.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoadingView.h"


@implementation LoadingView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) 
	{
		spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(frame.origin.x/2-30, frame.origin.y/2-30, 60, 60)];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	[spinner release];
    [super dealloc];
}

- (void) startSpinner
{
	[spinner startAnimating];
}

- (void) stopSpinner
{
	[spinner stopAnimating];
}

- (void) showInView:(UIView*)view
{
	[view addSubview:self];
}

- (void) hide
{
	self.hidden = YES;
}

- (void) show 
{
	self.hidden = NO;
}


@end
