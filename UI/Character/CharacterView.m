#import "CharacterView.h"


@implementation CharacterView

- (id) init 
{
	if(self = [super initWithNibName:@"CharacterView"])
	{
		return self;
	}
	return nil;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
