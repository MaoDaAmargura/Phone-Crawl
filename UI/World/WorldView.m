#import "WorldView.h"
#import "Tile.h"
#import "HomeTabViewController.h"

@implementation WorldView

@synthesize mapImageView, highlight;
@synthesize healthBar, shieldBar, manaBar;

#pragma mark -
#pragma mark Life Cycle

- (id) init {
	if(self = [super initWithNibName:@"WorldView"]) {
		highlight = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"blank.png"]];
		highlight.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.5];
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

/*!
 @abstract		highlight the Tile which the user is touching
 @discussion	arguments requiring points are to be given in terms of pixels.
				all touch events outside a rectangle (0,0,320,320) are ignored.
				if a drag event occurs outside this rectangle, the highlight is hidden.
 */

- (CGRect) rectAtPoint: (CGPoint) point {
	float x = (floor(point.x / TILE_SIZE_PX)) * TILE_SIZE_PX;
	float y = (floor(point.y / TILE_SIZE_PX)) * TILE_SIZE_PX;
	return CGRectMake (x, y, TILE_SIZE_PX, TILE_SIZE_PX);
}

- (bool) pointIsInWorldView: (CGPoint) point {
	return (point.x < WORLD_VIEW_SIZE_PX && point.y < WORLD_VIEW_SIZE_PX);
}

- (void) showHighLightAtPoint: (CGPoint) point {
	if ([delegate highlightShouldBeYellowAtPoint: point]) {
		highlight.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.5];
	}
	else {
		highlight.backgroundColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
	}
	
	highlight.frame = [self rectAtPoint: point];
	if (![highlight superview]) [self.view addSubview: highlight];
}

- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event {
	CGPoint loc = [[[touches allObjects] objectAtIndex: 0] locationInView: nil];
	if (![self pointIsInWorldView: loc]) return;

	[self showHighLightAtPoint: loc];

	[delegate worldView: self touchedAt: loc];
}

- (void) touchesMoved: (NSSet*) touches withEvent: (UIEvent*) event {
	CGPoint loc = [[[touches allObjects] objectAtIndex: 0] locationInView: nil];
	if (![self pointIsInWorldView: loc]) {
		[highlight removeFromSuperview];
	}
	else {
		[self showHighLightAtPoint: loc];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint loc = [[[touches allObjects] objectAtIndex: 0] locationInView: nil];
	[highlight removeFromSuperview];
	if (![self pointIsInWorldView: loc]) return;

	[delegate worldView: self selectedAt: loc];
}

- (void) touchesCancelled: (NSSet*) touches withEvent: (UIEvent*) event {
	[highlight removeFromSuperview];
}

@end
