//
//  NewGameFlowControl.m
//  Phone-Crawl
//
//  Created by Austin Kelley on 2/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NewGameFlowControl.h"

#define FIRST_DIALOGUE	@"Welcome, Adventurer, to the land of Tin'Foyel. A realm of dire monsters, dark dungeons and legendary weapons."
#define	SECOND_DIALOGUE	@"Woah, woah. Hold up there you! It's a schilling to tie up your boat in the dock. And I shall need to know your name."
#define THIRD_DIALOGUE	@"Welcome to Port Royal. Tell me a bit more about yourself. What do you look like?"

#define NAME_SELECTION 3
#define CHAR_SELECTION 5


@interface NewGameFlowControl (Private)

- (void) setDialogue;

@end



@implementation NewGameFlowControl


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)init
{
    if (self = [super initWithNibName:@"NewGameFlowControl"]) 
	{
        // Custom initialization
		[self.view addSubview:dialogueView];

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
}

- (void) flipToView:(UIView*) nView WithTransition:(UIViewAnimationTransition) transition
{
		
	[UIView beginAnimations: @"ViewFlip" context: NULL];
	[UIView setAnimationTransition: transition forView: self.view cache: NO];
	[UIView setAnimationDuration: 0.8];	
	[self.view bringSubviewToFront:nView];
	
	[UIView commitAnimations];
	
}

- (IBAction) nextState
{
	++state;
	switch (state) 
	{
		case 1:
			[mainTextLabel setText:FIRST_DIALOGUE];
			break;
		case 2:
			[mainTextLabel setText:SECOND_DIALOGUE];
			break;
		case NAME_SELECTION:
			nameSelect.hidden = NO;
			okayButton.userInteractionEnabled = NO;
			break;
		case 4:
			nameSelect.hidden = YES;
			[mainTextLabel setText:THIRD_DIALOGUE];
			break;
		case CHAR_SELECTION:
			
		default:
			break;
	}
}

- (void) begin
{
	state = 0;
	[self nextState];
	[self.view bringSubviewToFront:dialogueView];
	nameSelect.hidden = YES;
	okayButton.userInteractionEnabled = YES;
}
/*
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;        // return NO to disallow editing.
- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (void)textFieldDidEndEditing:(UITextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
*/

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if(textField.text.length > 3)
	{
		nameField = textField.text;
		[textField resignFirstResponder];
		okayButton.userInteractionEnabled = YES;
	}
	else
	{
		okayButton.userInteractionEnabled = NO;
	}

	return YES;
}





@end
