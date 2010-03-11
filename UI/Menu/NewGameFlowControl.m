#import "NewGameFlowControl.h"

#define FIRST_DIALOGUE	@"Welcome, Adventurer, to the land of Tin'Foyel. A realm of dire monsters, dark dungeons and legendary weapons."
#define	SECOND_DIALOGUE	@"Woah, woah. Hold up there you! It's a shilling to tie up your boat in the dock. And I shall need to know your name."
#define THIRD_DIALOGUE	@"Welcome to Port Royal. Tell me a bit more about yourself. What do you look like?"
#define FOURTH_DIALOGUE	@"Alright, brave Adventurer. Journey north from here. Save the village of Andor and take your place in history!"

#define NAME_SELECTION 3
#define CHAR_SELECTION 5

#define TOP_LEFT_ICON		@"knight.png"
#define TOP_RIGHT_ICON		@"female1.png"
#define BOTTOM_LEFT_ICON	@"male2.png"
#define BOTTOM_RIGHT_ICON	@"mage.png"

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
	topLeft.contentMode = UIViewContentModeScaleToFill;
	topRight.contentMode = UIViewContentModeScaleToFill;
	bottomLeft.contentMode = UIViewContentModeScaleToFill;
	bottomRight.contentMode = UIViewContentModeScaleToFill;
	[topLeft setBackgroundImage:[UIImage imageNamed:TOP_LEFT_ICON] forState:UIControlStateNormal];
	[topRight setBackgroundImage:[UIImage imageNamed:TOP_RIGHT_ICON] forState:UIControlStateNormal];
	[bottomLeft setBackgroundImage:[UIImage imageNamed:BOTTOM_LEFT_ICON] forState:UIControlStateNormal];
	[bottomRight setBackgroundImage:[UIImage imageNamed:BOTTOM_RIGHT_ICON] forState:UIControlStateNormal];
	


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

- (void) setButtonsHidden:(BOOL)hidden
{
	topLeft.hidden = hidden;
	topRight.hidden = hidden;
	bottomLeft.hidden = hidden;
	bottomRight.hidden = hidden;
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
			nameField = nameSelect.text;
			break;
		case CHAR_SELECTION:
			[self setButtonsHidden:NO];
			okayButton.userInteractionEnabled = NO;
			break;
		case 6:
			[mainTextLabel setText:FOURTH_DIALOGUE];
			okayButton.userInteractionEnabled = YES;
			break;
		case 7:
			[delegate newCharacterWithName:nameField andIcon:iconField];
			break;
		default:
			break;
	}
}

- (void) begin
{
	state = 0;
	nameSelect.hidden = YES;
	okayButton.userInteractionEnabled = YES;
	[self setButtonsHidden:YES];
	[self nextState];
	[self.view bringSubviewToFront:dialogueView];
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

- (void) selectedCharacterPicture:(NSString*)icon
{
	iconField = icon;
	[self setButtonsHidden:YES];
	[self nextState];
}

- (IBAction) topLeftButton
{
	[self selectedCharacterPicture: TOP_LEFT_ICON];
}

- (IBAction) topRightButton
{
	[self selectedCharacterPicture: TOP_RIGHT_ICON];
}

- (IBAction) bottomLeftButton
{
	[self selectedCharacterPicture: BOTTOM_LEFT_ICON];
}

- (IBAction) bottomRightButton
{
	[self selectedCharacterPicture: BOTTOM_RIGHT_ICON];
}



@end
