//
//  LoadingView.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 3/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadingView : UIView 
{
	UIActivityIndicatorView *spinner;
}

- (void) startSpinner;
- (void) stopSpinner;

- (void) addToView:(UIView*)view;
- (void) show;
- (void) hide;


@end
