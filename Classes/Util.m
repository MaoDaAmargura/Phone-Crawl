#import "Util.h"


@implementation Coord

@synthesize X,Y,Z,distance;


- (NSString*) description {
	return [NSString stringWithFormat: @"X: %d, Y: %d, Z: %d", X, Y, Z];
}

- (BOOL) equals:(Coord*)other
{
	if (self.X == other.X && self.Y == other.Y && self.Z == other.Z)
		return YES;
		
	return NO;
}

+ (Coord*) withX:(int)x Y:(int)y Z:(int)z {
	Coord *ret = [[Coord alloc] autorelease];
	ret.X = x;
	ret.Y = y;
	ret.Z = z;
	return ret;
}

@end


@implementation Rand

// blows up on assert if lowBound < highBound.
// negative lowBound works fine, I'm not sober enough to figure out a negative
// highBound that passes the assert just now, so shut up all of your head.  -Nate
+ (int) min: (int) lowBound max: (int) highBound {
	assert (lowBound < highBound);
	int range = highBound - lowBound + 1; // +1 is due to behavior of modulo
	return ((arc4random() % range) + lowBound);
}

@end
