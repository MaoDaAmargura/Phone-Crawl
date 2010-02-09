#import "Tile.h"

#define TILE_M_NUMBER_OF_TILES 10

@implementation Tile

static NSMutableArray *tileImageArray;

@synthesize blockMove, blockShoot, type, smashable, slope;


// level gen
@synthesize placementOrder, cornerWall;


#pragma mark -
#pragma mark Life Cycle

// extern'ed to LevelGen to track wall tiles in order of what building they are a part of
int placementOrderCountTotalForEntireClassOkayGuysNowThisIsHowYouProgramInObjectiveC = 1;


// DEPRECATED.  use initWithType instead.
- (id) init {
	blockMove = NO;
	blockShoot = NO;
	smashable = false;
	type = tileGrass;
	slope = slopeNone;

	cornerWall = false;

	return self;
}

- (Tile*) initWithTileType: (tileType) _type {
	type = _type;
	placementOrder = 0;	// dummy value, never occurs in a wall
	blockMove = false;
	blockShoot = false;
	smashable = false;

	switch (type) {
		case tileWoodWall:
			blockMove = true;
			blockShoot = true;
			placementOrder = placementOrderCountTotalForEntireClassOkayGuysNowThisIsHowYouProgramInObjectiveC;
			break;
		case tileRubble:
			blockMove = true;
			smashable = true;
			break;
		case tileWoodDoor:
			blockMove = true;
			blockShoot = true;
			smashable = true;
			break;
		case tileWoodDoorSaloon:
			blockShoot = true;
		case tilePit:
			blockMove = true;
			break;
		case tileSlopeDown:
			slope = slopeDown;
			break;
		case tileSlopeUp:
			slope = slopeUp;
			break;
		case tileRockWall:
			blockMove = true;
			blockShoot = true;
			break;
		default:
			break;
	}
	return self;
}

#pragma mark -
#pragma mark Static
/*!
 @method		initTileArray
 @abstract		helper function initializes the tile array
 @discussion	IMPORTANT: Elements MUST be added IN CORRESPONDING ORDER 
 to that which they are declared in the tileType enum in Tile.h
 @note			I used mutableArray because NSDictionary is keyed by string only
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
		ADD(@"wood-door-open.png");
		ADD(@"saloon-door.png");
		ADD(@"wood-door-broken.png");

		ADD(@"BlackSquare.png");
		ADD(@"staircase-down.png");
		ADD(@"staircase-up.png");
		ADD(@"wall-rock.gif");
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