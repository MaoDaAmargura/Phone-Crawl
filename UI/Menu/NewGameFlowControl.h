//
//  NewGameFlowControl.h
//  Phone-Crawl
//
//  Created by Austin Kelley on 2/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCBaseViewController.h"

@interface NewGameFlowControl : PCBaseViewController <UITextFieldDelegate>
{
	int state;
	IBOutlet UILabel *mainTextLabel;
	
	IBOutlet UITextField *nameSelect;
	IBOutlet UIButton *okayButton;
	
	IBOutlet UIView *dialogueView;

	
	NSString *nameField;
}

- (void) begin;

- (IBAction) nextState;

@end
