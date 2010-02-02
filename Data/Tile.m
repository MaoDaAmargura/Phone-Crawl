#import "Tile.h"

#define TILE_M_NUMBER_OF_TILES 10

@implementation Tile

static NSMutableArray *tileImageArray;

@synthesize blockMove, blockView, type;


#pragma mark -
#pragma mark Life Cycle

- (id) init 
{
	blockMove = NO;
	blockView = NO;
	type = tileGrass;
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
		[tileImageArray addObject:[UIImage imageNamed:@"BlackSquare.png"]];
		[tileImageArray addObject:[UIImage imageNamed:@"grass.png"]];
		[tileImageArray addObject:[UIImage imageNamed:@"concrete.png"]];
		[tileImageArray addObject:[UIImage imageNamed:@"dirt.png"]];
		[tileImageArray addObject:[UIImage imageNamed:@"wood.png"]];
	}
}

+ (UIImage*) imageForType:(tileType)type
{
	return [tileImageArray objectAtIndex:type];
}

@end