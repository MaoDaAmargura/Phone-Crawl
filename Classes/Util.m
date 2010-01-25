#import "Util.h"


@implementation Coord

@synthesize X,Y,Z;

- (id) init {
	X = Y = Z = 0;
	return self;
}

- (NSString*) description {
	return [NSString stringWithFormat: @"X: %d, Y: %d, Z: %d", X, Y, Z];
}

+ (Coord*) newCoordWithX:(int)x Y:(int)y Z:(int)z
{
	Coord *ret = [[[Coord alloc] init] autorelease];
	ret.X = x;
	ret.Y = y;
	ret.Z = z;
	return ret;
}

@end

//@implementation Util
//
//@end
