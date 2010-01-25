#import "WorldView.h"

@implementation WorldView

@synthesize mapImageView;
@synthesize healthBar, shieldBar, manaBar;


#pragma mark -
#pragma mark Life Cycle

- (id) init
{
	if(self = [super initWithNibName:@"WorldView"])
	{
		return self;
	}
	return nil;
}

- (void) setDelegate:(id<WorldViewDelegate>) idOfDelegate
{
	[delegate release];
	delegate = [idOfDelegate retain];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

	displayBarArray = [[NSArray arrayWithObjects:healthBar, shieldBar, manaBar, nil] retain];
	displayLabelArray = [[NSArray arrayWithObjects:healthLabel, shieldLabel, manaLabel, nil] retain];

	[delegate worldViewDidLoad:self];
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

#pragma mark -
#pragma mark Display 

- (void) setDisplay:(displayStatType) display withAmount:(float) amount ofMax:(float) max
{
	UIView *bar = [displayBarArray objectAtIndex:display];
	CGRect bnd = bar.frame;
	[bar setFrame:CGRectMake(bnd.origin.x, bnd.origin.y, (amount*100.0/max), bnd.size.height)];
	UILabel *label = [displayLabelArray objectAtIndex:display];
	label.text = [NSString stringWithFormat:@"%.0f / %.0f", amount, max];
}

#pragma mark -
#pragma mark UIResponder


- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event {
	CGPoint loc = [[[touches allObjects] objectAtIndex: 0] locationInView: nil];
	loc.x /= TILE_SIZE_PX, loc.y /= TILE_SIZE_PX;
	DLog (@"%d %d", (int)loc.x, (int)loc.y);


//	[delegate worldView: self touchedAt: CGPointMake(0.0, 0.0)];
	[super touchesBegan:touches withEvent:event];


//	[UIView beginAnimations:nil context: context];
//	[UIView setAnimationDuration: DROP_ANIM_DURATION];
//	[UIView setAnimationDelegate:self];
//	[UIView setAnimationDidStopSelector:@selector(finishedMoveOut:finished:context:)];
//	
//	CGPoint center = left.view.center;
//	
//	center.x -= 133.5;
//	left.view.center = center;
//	center = right.view.center;
//	center.x -= 133.5;
//	right.view.center = center;
//	
//	[UIView commitAnimations];
	
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
}

@end
