#import <Foundation/Foundation.h>

@interface Coord : NSObject {
	int X;
	int Y;
	int Z;
}

@property (nonatomic) int X;
@property (nonatomic) int Y;
@property (nonatomic) int Z;

- (id) init;

@end
