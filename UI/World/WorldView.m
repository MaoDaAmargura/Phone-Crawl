#import "WorldView.h"
#import "Tile.h"
#import "HomeTabViewController.h"

@implementation WorldView

@synthesize mapImageView, highlight, miniMapImageView;
@synthesize healthBar, shieldBar, manaBar;

#pragma mark -
#pragma mark Life Cycle

- (id) init {
	if(self = [super initWithNibName:@"WorldView"]) {
		highlight = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
		highlight.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.5];
		highlight.hidden = YES;
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
	[self.view addSubview:highlight];
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
 @method		pointIsInWorldView:
 @abstract		query method asks whether a point in world coordinate (pixel)
				is in the mapImageView bounds (ie, needs to be intercepted)
 */
- (BOOL) pointIsInWorldView: (CGPoint) point 
{
	CGSize s = mapImageView.bounds.size;
	return (point.x < s.width && point.y < s.height);
}

/*!
 @method		touchesBegan
 @abstract		callback for UIresponder. launches the tile highlighter if on a tile. reports the touch
 */
- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event 
{
	CGPoint loc = [[[touches allObjects] objectAtIndex: 0] locationInView: nil];
	if (![self pointIsInWorldView: loc])
	{
		[super touchesBegan:touches withEvent:event];
		return;
	}
	
	highlight.hidden = NO;
	
	[delegate worldView: self touchedAt: loc];
}

/*!
 @method		touchesMoved
 @abstract		UIResponder callback. notifies delegate of a new tile highlighted.
 */
- (void) touchesMoved: (NSSet*) touches withEvent: (UIEvent*) event 
{
	CGPoint loc = [[[touches allObjects] objectAtIndex: 0] locationInView: nil];
	
	if(![self pointIsInWorldView:loc])
	{
		[super touchesMoved:touches withEvent:event];
		return;
	}
	
	[delegate worldView: self touchedAt:loc];
}

/*!
 @method		touchesEnded
 @abstract		UIResponder callback. Notifies delegate of a touch ending. Hides highlight.
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint loc = [[[touches allObjects] objectAtIndex: 0] locationInView: nil];
	highlight.hidden = YES;
	if (![self pointIsInWorldView: loc])
	{
		[super touchesEnded:touches withEvent:event];
		return;
	}
	[delegate worldView: self selectedAt: loc];
}

/*!
 @method		touchesCancelled
 @abstract		UIResponder callback. Hides highlight. No notifications.
 */
- (void) touchesCancelled: (NSSet*) touches withEvent: (UIEvent*) event 
{
	highlight.hidden = YES;
}




@end
