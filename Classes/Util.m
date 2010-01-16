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

@end


//@implementation Util
//
//@end
