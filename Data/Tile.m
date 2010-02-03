#import "Tile.h"

#define TILE_M_NUMBER_OF_TILES 10

@implementation Tile

static NSMutableArray *tileImageArray;

@synthesize blockMove, blockShoot, type, smashable;


// level gen
@synthesize placementOrder, cornerWall;


#pragma mark -
#pragma mark Life Cycle

// level gen
static int placementOrderCountTotalForEntireClassOkayGuysNowThisIsHowYouProgramInObjectiveC = 0;

- (id) init
{
	blockMove = NO;
	blockShoot = NO;
	smashable = false;
	type = tileGrass;


	// level gen
	placementOrder = placementOrderCountTotalForEntireClassOkayGuysNowThisIsHowYouProgramInObjectiveC++;
	cornerWall = false;


	return self;
}

#pragma mark -
#pragma mark Static
/*!
 @method		initTileArray
 @abstract		helper function initializes the tile array
 @discussion	IMPORTANT: Elements MUST be added IN CORRESPONDING ORDER 
 to that which they are declared in the tileType enum in Tile.h
 */

+ (void) initialize
{
	[super initialize];
	if(!tileImageArray)
	{
		tileImageArray = [[NSMutableArray alloc] initWithCapacity:TILE_M_NUMBER_OF_TILES];

		#define ADD(thing) [tileImageArray addObject: [UIImage imageNamed: thing]]

		ADD(@"BlackSquare.png");

		ADD(@"grass.png"    );
		ADD(@"concrete.png" );
		ADD(@"dirt.png"     );
		ADD(@"wall-wood.png");
		ADD(@"door-wood.png");

		ADD(@"wood.png");
	}
}

+ (UIImage*) imageForType:(tileType)type
{
	if (type >= [tileImageArray count]) {
		DLog (@"check your arguments: %d", type);
		return nil;
	}
	return [tileImageArray objectAtIndex:type];
}

@end