#import "WorldView.h"
#import "Tile.h"

@implementation WorldView

@synthesize mapImageView, highlight;
@synthesize healthBar, shieldBar, manaBar;

#pragma mark -
#pragma mark Life Cycle

- (id) init
{
	if(self = [super initWithNibName:@"WorldView"])
	{
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
 @discussion	static UIImageView *highlight is a silly, hackish workaround, used only in these methods.
				it is to be removed when we know if a Tile has a UIButton / UIImage / whatever.
 */

// point argument is to be given in terms of pixels.
- (CGRect) rectAtPoint: (CGPoint) point {
	float x = (floor(point.x / TILE_SIZE_PX)) * TILE_SIZE_PX;
	float y = (floor(point.y / TILE_SIZE_PX)) * TILE_SIZE_PX;
	return CGRectMake (x, y, TILE_SIZE_PX, TILE_SIZE_PX);
}

- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event {
	CGPoint loc = [[[touches allObjects] objectAtIndex: 0] locationInView: nil];
	highlight.frame = [self rectAtPoint: loc];
	[self.view addSubview: highlight];

	[delegate worldView: self touchedAt: loc];
	[super touchesBegan:touches withEvent:event];
}

- (void) touchesMoved: (NSSet*) touches withEvent: (UIEvent*) event {
	CGPoint loc = [[[touches allObjects] objectAtIndex: 0] locationInView: nil];
	highlight.frame = [self rectAtPoint: loc];
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[highlight removeFromSuperview];
	[super touchesEnded:touches withEvent:event];
}

- (void) touchesCancelled: (NSSet*) touches withEvent: (UIEvent*) event {
	[highlight removeFromSuperview];
	[super touchesCancelled:touches withEvent:event];
}

@end
