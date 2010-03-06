#import "Util.h"


@implementation Coord

@synthesize X,Y,Z,pathing_distance,pathing_parentCoord;


- (NSString*) description {
	return [NSString stringWithFormat: @"X: %d, Y: %d, Z: %d", X, Y, Z];
}

- (BOOL) equals:(Coord*)other
{
	if (self.X == other.X && self.Y == other.Y && self.Z == other.Z)
		return YES;
		
	return NO;
}

- (BOOL) isEqual: (id)anObject {
	return [self equals:(Coord*) anObject];
}

+ (Coord*) withX:(int)x Y:(int)y Z:(int)z {
	Coord *ret = [[Coord alloc] autorelease];
	ret.X = x;
	ret.Y = y;
	ret.Z = z;
	return ret;
}

- (id) copyWithZone: (NSZone*) zone {
	Coord *retval = [[self class] allocWithZone: zone];
	retval.X = X;
	retval.Y = Y;
	retval.Z = Z;
    return retval;
	
//	return [[Coord withX: X Y: Y Z: Z] retain];
}

@end


@implementation Rand

+ (int) min: (int) lowBound max: (int) highBound {
	if (lowBound == highBound) return lowBound;
	assert (lowBound < highBound);
	int range = highBound - lowBound + 1; // +1 is due to behavior of modulo
	return ((arc4random() % range) + lowBound);
}

@end

@implementation Util

+ (int) point_distanceC1:(Coord *)c1 C2:(Coord *)c2
{
	return [Util point_distanceX1:c1.X Y1:c1.Y X2:c2.X Y2:c2.Y];
}

+ (int) point_distanceX1:(int)x1 Y1:(int)y1 X2:(int)x2 Y2:(int)y2
{
	return sqrt(pow(x1-x2,2)+pow(y1-y2,2));
}

@end
